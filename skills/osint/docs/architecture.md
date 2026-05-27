# OSINT Skill — Architecture

## Overview

A single Claude Code skill (`osint`) that performs OSINT background checks on individuals. It
discovers social/online accounts from a name, confidence-scores each against the target identity,
and analyzes activity, content, and stance — all in one orchestrated, checkpointed workflow.

This skill replaces three earlier sibling skills (`osint-recon`, `osint-verify`, `osint-analyze`)
that the user had to invoke separately. They are now phases of one workflow.

## Why one skill instead of three

- The three skills already described a strictly sequential pipeline, each reading the previous
  one's report — so the user paid re-establishment cost three times.
- The heavy work *inside* each phase is embarrassingly parallel (many platforms, many usernames,
  independent lookups) and was not being exploited.
- One orchestrator can fan that work out to subagents, keep the noisy CLI/API output out of the
  main context, checkpoint between phases, and still let the user enter mid-workflow.

## Orchestrator + Explore-worker model

```
SKILL.md (orchestrator)            has: Agent, Write, Bash, WebSearch, WebFetch, Read, Edit, AskUserQuestion
   │  spawns (subagent_type: Explore)
   ├── worker ──┐
   ├── worker   │   Explore agents: Bash, WebSearch, WebFetch, Read — but NO Write, NO Agent
   ├── worker   │   → read-only by construction: can't write reports, can't spawn runaway sub-agents
   └── worker ──┘   → return structured findings only; orchestrator merges, decides, and writes
```

The orchestrator is the **only** component with `Write`, so it is the single thing that produces
the report. Workers are dispatched a scoped task + the relevant `references/*.md` + the target
context, and return findings in a fixed structured format. This gives de-facto least-privilege
without shipping separate agent definitions, and keeps the whole skill self-contained.

## Pipeline

```
Step 0  Scope & setup ── ethical gate, target context (name + ≥1 disambiguator),
        tool/config checks, analysis purpose + key topics, detect fresh vs resume
   │
   ▼
Phase 1 RECON   parallel Explore workers:
        A: Google dorks (WebSearch)   B: GitHub API (Bash)
        C: CLI sweep Maigret/Sherlock/Holehe (Bash)   D: PDL+Hunter (Bash, if keys)
        → merge, dedupe, ≤2 recursive sweep rounds → write Recon section
   │  ── CHECKPOINT: show discovered accounts, confirm ──
   ▼
Phase 2 VERIFY  parallel Explore workers (per account/batch):
        fetch profile, score 8 dimensions (0–2 each, 16 max) → confidence level
        → assemble scorecard + cross-ref matrix → append Verify section
   │  ── CHECKPOINT: show scores, confirm/reject manual-review flags ──
   ▼
Phase 3 ANALYZE parallel Explore workers (per module): activity, content, dev profile,
        timeline, network, stance, red flags — Confirmed/High accounts only
        → synthesize → append Analysis section → final report
```

## Directory layout

```
skills/osint/
  SKILL.md                 orchestrator: scope intake, phase dispatch, checkpoints, report writing
  references/
    setup.md               tool/config checks, recon account, ethical + quality guardrails
    recon.md               Phase 1 methods + worker return format
    verify.md              Phase 2 scoring framework + worker return format
    analyze.md             Phase 3 modules + worker return format
  templates/
    report.md              one consolidated, incrementally-written report
  docs/
    architecture.md        this file
```

## Report & resumption

One consolidated file `{reports_dir}/osint-{lastname}-{YYYY-MM-DD}.md`, written incrementally
(Recon section after Phase 1, Verify appended after Phase 2, Analysis after Phase 3).
`reports_dir` resolves from `~/.osint/config.json` (`reports_dir` key) or defaults to
`~/.osint/reports`. A resumed run reads the existing report (or a user-supplied one) and continues
from the first missing section — so the user can start at Verify or Analyze with prior output.

## Data sources & tools

Free/low-cost only. APIs (PDL, Hunter, GitHub token) are optional and read from
`~/.osint/config.json`; CLI tools (Maigret, Sherlock, Holehe) are optional and detected at
startup. The workflow degrades gracefully to web-search-only methods when nothing else is
available. See `references/setup.md` and `references/recon.md` for the full source tables.

## Guardrails

The ethical gate runs before any data gathering (refuse harassment/stalking/doxxing; require a
stated legitimate purpose). Legal/ethical and quality guidelines in `references/setup.md` apply to
every phase: public information only; no bypassing access controls; document every source; flag
uncertainty; distinguish observation from inference; no psychoanalysis or moral judgment.

## Packaging note

`.claude-plugin/marketplace.json` ("writing-skills") does not register the OSINT skills — OSINT is
off-theme for that marketplace and the prior skills were never listed there. The `osint` skill is
self-contained and usable on its own from `skills/osint/`.
