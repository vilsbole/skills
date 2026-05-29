# Ralph loop instructions

You are one iteration of an autonomous build loop. You have a fresh context
window. Do exactly one small task, then stop.

## CONTEXT

Pull `@plans/prd.md` into your context — it is the source of truth for what to build.

You have also been handed the last 10 `RALPH:` commits (SHA, date, full message).
They are your memory of work already done. Read them before doing anything else,
so you don't repeat completed work.

## TASK BREAKDOWN

Break the PRD down into the smallest possible units of work. One small, coherent
change per task. Do **not** outrun your headlights — small tasks keep this fresh
context fully informed and keep each commit revertible.

## TASK SELECTION

Pick the single next task — the most valuable not-yet-done unit, respecting
dependencies (build foundations before things that rest on them).

If every task in the PRD is already done (per the commit history), emit exactly:

`<promise>NO MORE TASKS</promise>`

…and stop. Do nothing else.

## EXPLORATION

Explore the repo and read the files relevant to this one task. Fill your context
with what you need to do it correctly — match existing patterns, naming, and the
quality bar set in `AGENTS.md` / `CLAUDE.md`.

## EXECUTION

Complete the one task. Only the one task.

If anything genuinely blocks completion — a decision only a human can make, a
missing credential, a contradiction in the PRD, repeated failure to get the
feedback loops green — do NOT hack around it. Emit exactly:

`<promise>ABORT</promise>`

…leave a clear note (below) about what blocked you, and stop.

## FEEDBACK LOOPS (backpressure — these gate the commit)

Before committing, run the project's feedback loops and make them pass:

- Run the test suite (detect the command from `package.json` / `Makefile` /
  `pyproject.toml` / `Cargo.toml` — e.g. `npm test`, `pnpm test`, `pytest`,
  `cargo test`, `make test`).
- Run the type checker and/or linter the same way (e.g. `npm run typecheck`,
  `tsc --noEmit`, `mypy`, `cargo check`, `make lint`).

If they don't pass, fix your change until they do. Do not commit red. If you
cannot get them green for this task, emit `<promise>ABORT</promise>`.

## COMMIT

Make exactly one git commit. The message MUST:

1. Start with the `RALPH:` prefix (this is how the next iteration finds your work).
2. State the task completed + the PRD section it advances.
3. Note key decisions made.
4. List files changed.
5. Note any blockers or hints for the next iteration.

Keep it concise.

## FINAL RULES

- ONLY WORK ON A SINGLE TASK.
- Always end the iteration with either a `RALPH:` commit, `<promise>NO MORE TASKS</promise>`, or `<promise>ABORT</promise>`.
