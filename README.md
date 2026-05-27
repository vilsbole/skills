# kitt

vilsbole's personal [Claude Code](https://claude.com/claude-code) skill collection — content, growth/SEO, research, engineering workflow, and core productivity helpers — published as a plugin marketplace.

## Install

```
/plugin marketplace add vilsbole/skills
/plugin install kitt@vilsbole
```

Skills are invoked by bare name (e.g. `/tdd`, `/copywriting`, `/osint`). The plugin shows up as a `(kitt)` source tag in the `/` menu.

## Skills

Skills are organized into category folders (organizational only — categories don't appear in the `/` menu).

### create/ — content & copy
| Skill | What it does |
|-------|--------------|
| `copywriting` | Write, rewrite, or improve marketing copy for any page. |
| `copy-editing` | Edit, review, and tighten existing marketing copy. |
| `humanizer` | Make AI-generated text read like a human wrote it. |

### growth/ — SEO & growth
| Skill | What it does |
|-------|--------------|
| `ai-seo` | Optimize content to get cited by LLMs and AI search engines (AEO/GEO). |
| `programmatic-seo` | Generate SEO-driven pages at scale from templates + data. |
| `seo-audit` | Audit and diagnose technical/on-page SEO issues. |

### research/
| Skill | What it does |
|-------|--------------|
| `osint` | Open-source intelligence research workflow. |

### engineering/ — engineering workflow
| Skill | What it does |
|-------|--------------|
| `init-repo` | Scaffold per-repo config (`docs/agents/*`, `## Agent skills` block) the other engineering skills rely on. Run this first. |
| `tdd` | Test-driven development workflow. |
| `diagnose` | Systematic bug diagnosis with a human-in-the-loop. |
| `triage` | Triage issues into canonical roles. |
| `to-issues` | Turn work into well-formed issues. |
| `to-prd` | Turn an idea into a PRD. |
| `grill-with-docs` | Pressure-test decisions against ADRs/context docs. |
| `improve-codebase-architecture` | Architecture-improvement analysis and reporting. |
| `prototype` | Rapidly prototype logic and UI. |
| `zoom-out` | Step back and reassess the bigger picture. |

### core/ — productivity
| Skill | What it does |
|-------|--------------|
| `grill-me` | Interrogate your own thinking before committing. |
| `handoff` | Produce a context handoff for another session. |
| `write-a-skill` | Author a new Claude skill. |

## Credits

The `engineering/*` and `core/{grill-me,handoff,write-a-skill}` skills are vendored from [mattpocock/skills](https://github.com/mattpocock/skills) (MIT). See [CREDITS.md](./CREDITS.md).
