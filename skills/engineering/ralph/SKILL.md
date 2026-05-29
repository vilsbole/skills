---
name: ralph
description: Run an autonomous "Ralph" loop — feed a fixed prompt to Claude Code repeatedly so it grinds through a PRD one small task per iteration, committing as it goes. Use when the user says "ralph this", "run it on a loop", "let it grind through the backlog", "autonomous agent loop", "AFK agent", or wants to hand a scoped PRD to an unattended loop and monitor progress.
---

# Ralph

A bounded, autonomous build loop. Each iteration starts a **fresh context window**, reads a fixed prompt + its task source + the last 10 `RALPH:` commits, picks **one small task**, builds it, runs the project's feedback loops, and commits. The loop repeats until the agent reports no work left, aborts on a blocker, or hits the iteration cap.

**Two task sources** (`RALPH_SOURCE`):

- **`prd`** (default) — Ralph breaks a `plans/prd.md` into tasks and grinds through them. Best for greenfield work written up as a single spec.
- **`issues`** — Ralph grinds an **existing issue backlog**: the open issues carrying your "ready for agent" triage label. Each iteration picks the top issue, advances it, and closes it when done so the queue shrinks. Best when the work already lives in your tracker (e.g. issues produced by `/to-issues` or `/to-prd` and marked `ready-for-agent` via `/triage`).

This skill is the **orchestrator's** entry point: you scaffold the loop, watch one iteration by hand, kick off the AFK run in the background, and monitor it from the parent session. It does not replace planning — Ralph is only as good as the PRD or the triaged issues you hand it.

Modeled on Matt Pocock's Ralph approach ([aihero.dev](https://www.aihero.dev/getting-started-with-ralph)) and Geoffrey Huntley's original ([ghuntley.com/ralph](https://ghuntley.com/ralph)). See `CREDITS.md`.

## Why these design choices (don't undo them)

- **Fresh context every iteration.** A bash loop relaunching `claude` beats one long-running session — context doesn't rot across tasks. This is the whole point; don't "optimise" it into a single session.
- **Git is the memory.** Each iteration commits with a `RALPH:` prefix and the next iteration is handed the last 10 such commits via `git log --grep`. There is no `progress.txt` to drift out of sync — the audit trail *is* the working memory.
- **Bounded, never infinite.** The loop takes a required iteration count. `while :;` is banned — an unattended infinite loop with edit permissions is how you wake up to 400 commits of nonsense.
- **One small task per iteration.** "Don't outrun your headlights." Small tasks keep each fresh context fully informed and keep commits revertible.
- **Feedback loops are backpressure.** Tests + typecheck/lint must pass before the commit. Without a blocking signal the loop happily commits broken code forever.
- **Two promises control flow.** The agent emits `<promise>NO MORE TASKS</promise>` (clean finish) or `<promise>ABORT</promise>` (blocked). The script greps the final result for these.

## Phase 1 — Pre-flight (do not skip)

Ralph amplifies whatever you give it. Before scaffolding, confirm:

- [ ] **Your task source is ready.**
  - *PRD mode*: a scoped `plans/prd.md` exists. If the work isn't written down, stop and write one first (`/to-prd`). A vague PRD produces a vague pile of commits.
  - *Issues mode*: the tracker is reachable (`gh auth status`), and the issues you want built **already exist and are triaged** to the ready-for-agent label — well-scoped, each an independently-buildable slice (that's what `/to-issues` + `/triage` produce). Ralph builds the queue; it does not triage it. Garbage-in issues → garbage-out commits.
- [ ] **The repo is a clean git checkout** on a branch you're happy to fill with commits (`git status` clean, ideally a dedicated `ralph/<feature>` branch). Ralph commits constantly; never run it on `main` with uncommitted work.
- [ ] **Feedback loops actually run.** You can run the project's tests and type/lint check from the repo root and they pass *now*. If they don't pass before Ralph starts, Ralph can't tell its own breakage from pre-existing breakage.
- [ ] **An `AGENTS.md` (or `CLAUDE.md`) states the quality bar** — is this a throwaway prototype, a library, or production code? What standards apply? Without this the agent mimics the quality of whatever code it sees. Matt Pocock flags this as the single highest-leverage context file.

Do not proceed until all four hold.

## Phase 2 — Scaffold

Copy the scripts + templates into a `plans/` directory in the **target repo**:

```bash
mkdir -p plans
cp <skill-dir>/scripts/*.sh   plans/        # once.sh, afk.sh, _lib.sh (sourced — copy it too)
cp <skill-dir>/templates/*.md plans/        # prompt.md, prompt.issues.md, prd.md
chmod +x plans/*.sh
```

(`<skill-dir>` is this skill's directory — read the scripts/templates from here.)

Then prepare the task source:

- **PRD mode**: edit `plans/prd.md` so it actually describes the feature — goal, concrete deliverables, constraints, what "done" looks like. The PRD is the only steering input the loop gets; spend real effort here. (`plans/prompt.issues.md` is unused in this mode — harmless to leave.)
- **Issues mode**: nothing to fill in — the queue *is* your triaged issues. Just confirm the label: the loop pulls `ready-for-agent` by default; override with `RALPH_LABEL` if your tracker uses a different string (`/init-repo` records your label vocabulary). Non-GitHub tracker? Set `RALPH_ISSUE_LIST_CMD` to your tracker's list command (see `plans/_lib.sh`).

Either way, review the prompt's feedback-loop commands if the project doesn't auto-detect (e.g. pin `pnpm test` / `cargo test` / `make check`).

## Phase 3 — Run one iteration by hand (HITL)

**Always watch one full iteration before going AFK.** This catches a bad PRD, wrong queue/label, wrong test command, or missing permission before it runs 20×.

```bash
bash plans/once.sh                       # PRD mode
RALPH_SOURCE=issues bash plans/once.sh   # issues mode (grinds the ready-for-agent queue)
```

Watch it: does it pick a sensibly small task / the right issue? Explore the right files? Run the real feedback loops? Produce a clean `RALPH:` commit (and, in issues mode, close the finished issue)? If any of that is off, fix the PRD / prompt / label / `AGENTS.md` and run `once.sh` again. Iterate on the loop before trusting the loop.

## Phase 4 — Go AFK (bounded autonomous loop)

Once a hand-run iteration looks right, launch the bounded loop. Pick the count by size: **5–10** for a small feature or short queue, **30–50** for a larger project. (Issues mode self-terminates when the queue empties, so erring high is cheap.)

```bash
bash plans/afk.sh 20                       # PRD mode
RALPH_SOURCE=issues bash plans/afk.sh 30   # issues mode — re-fetches the queue each iteration
```

For a genuinely unattended run, sandbox it so a misfire can't touch the host:

```bash
RALPH_SANDBOX=1 RALPH_SOURCE=issues bash plans/afk.sh 30   # wraps each iteration in `docker sandbox run`
```

As an orchestrator, launch this as a **background task** so you keep control of the parent session and can monitor (Phase 5):

- Run `bash plans/afk.sh 20` with `run_in_background: true` (the harness re-invokes you when it exits), or
- `bash plans/afk.sh 20 > plans/logs/run.out 2>&1 &` and poll.

The loop self-terminates on `<promise>NO MORE TASKS</promise>` (exit 0), `<promise>ABORT</promise>` (exit 1), or the iteration cap (exit 0 with a "reached cap" notice).

## Phase 5 — Monitor

From the parent session, monitor without interrupting the loop:

- **Progress / what's been built** — the commit log is the source of truth:
  ```bash
  git log --grep='^RALPH:' --oneline -20
  ```
- **Queue draining (issues mode)** — watch the backlog shrink as issues close:
  ```bash
  gh issue list --state open --label ready-for-agent   # should get shorter each iteration
  ```
- **Live narration** — the agent's streamed text per iteration:
  ```bash
  tail -f plans/logs/ralph.log
  ```
- **Health checks** while it runs, watch for:
  - **Stalling** — same task/issue in consecutive commits, or commits with no real diff. The task is too big or ambiguous; kill and re-scope (in issues mode, a done-but-not-closed issue gets redone — check it actually closed).
  - **Drift** — commits wandering away from the PRD. Tighten the PRD's scope/constraints.
  - **Green-but-wrong** — feedback loops passing but the build not matching intent. The PRD's "done" criteria are too loose.
- **Stop early** if needed: kill the background task (or `Ctrl-C`). Because every iteration commits, you lose at most the in-flight task. `git reset --hard <last-good-RALPH-commit>` to roll back drift.

## Phase 6 — Wrap up

When the loop ends:

- [ ] `git log --grep='^RALPH:'` reviewed — the commits collectively deliver the PRD.
- [ ] Feedback loops pass on the final state (run them yourself, don't trust the last iteration's word).
- [ ] Squash/clean the `RALPH:` history into a reviewable shape if this is going to a PR (`/to-issues` or a normal interactive rebase).
- [ ] If Ralph **aborted**: read the last commit's "blockers/notes" and the log tail — that's the agent's handoff. Resolve the blocker, then resume with another `afk.sh` run (it picks up from the commit history).
- [ ] If Ralph **finished but the PRD isn't fully met**: the PRD likely under-specified. Refine it and run again, or finish the remainder by hand.

Ralph builds; you still own the review. Never merge a Ralph branch without reading the diff.
