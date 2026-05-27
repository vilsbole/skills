# Repository conventions

This repo is a Claude Code plugin marketplace (`.claude-plugin/marketplace.json`) publishing a single plugin, **`kitt`** (marketplace **`vilsbole`**). Skills live under `skills/<category>/<skill-name>/SKILL.md`.

## Categories

Category folders are organizational only — they do **not** appear in the `/` menu (skills are invoked by their frontmatter `name:`, e.g. `/tdd`). Put new skills in the folder that fits:

- `create/` — content & copywriting (copy, editing, humanizing)
- `growth/` — SEO & growth (audits, AI/answer-engine SEO, page generation)
- `research/` — research workflows (OSINT, etc.)
- `engineering/` — engineering workflow (TDD, triage, diagnosis, PRDs, prototyping)
- `core/` — general productivity helpers

Add a new category folder only when a skill genuinely doesn't fit an existing one.

## Adding or moving a skill

1. The folder name should match the skill's frontmatter `name:` (kebab-case). Invocation depends on `name:`, not the path.
2. **Every listed skill needs a manifest entry.** After adding/moving a skill, add (or update) its `./skills/<category>/<name>` path in the `skills` array of `.claude-plugin/marketplace.json`. The array is explicit — folders not listed are ignored.
3. Don't list a skill whose `SKILL.md` is empty/stub (it's invalid). `skills/create/copy-linkedin` is currently a stub and is intentionally omitted from the manifest.
4. Use `git mv` when relocating an existing skill to preserve history.

## Vendored skills

`engineering/*` and `core/{grill-me,handoff,write-a-skill}` are vendored from [mattpocock/skills](https://github.com/mattpocock/skills) (MIT) — see `CREDITS.md`. When re-syncing from upstream, re-apply the `setup-matt-pocock-skills` → `init-repo` rename (folder, frontmatter `name:`, H1, and `/setup-matt-pocock-skills` slash references in `triage`, `to-issues`, `to-prd`).
