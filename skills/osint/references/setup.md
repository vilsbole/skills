# Setup, Configuration & Guardrails

This reference is read by the **orchestrator** during Step 0 (scope & setup). It covers
prerequisite checks, configuration, the optional recon account, and the legal/ethical and quality
guardrails that apply to every phase.

---

## Ethical Gate (run first, every time)

Before gathering any context, confirm the purpose is legitimate. Proceed only for purposes such
as hiring/recruiting due diligence, partnership or vendor vetting, journalism, self-audit
("what's my own footprint"), or security research with authorization.

**Refuse and stop** if the request appears aimed at:
- Harassment, stalking, intimidation, or doxxing
- Locating someone who does not want to be found (e.g. an ex-partner, a victim)
- Building a profile of a private individual to enable real-world contact against their wishes
- Any use that targets a private person's physical safety

If the purpose is ambiguous, ask the user to state it plainly before continuing. A stated
legitimate purpose is required to proceed.

---

## Required Target Context

Ask the user for as much of the following as possible — the more context, the better the
disambiguation:

1. **Full name** (and known aliases, maiden names, nicknames)
2. **Location** (city, country)
3. **Occupation / employer / title**
4. **Age range or approximate birth year**
5. **Any known usernames, handles, or profile URLs**
6. **Known email addresses**
7. **Education history**
8. **Any other distinguishing info** (publications, projects, public appearances)

**Minimum to proceed:** name + at least one disambiguator (location, employer, or known handle).
If the name is very common and no strong disambiguator is given, say so prominently and stay
conservative with attributions.

---

## Prerequisite Tool Checks

Run these silently. They are optional — the workflow degrades gracefully to web-search-only
methods if tools are missing.

```bash
which maigret  2>/dev/null && echo "maigret: OK"  || echo "maigret: NOT INSTALLED"
which sherlock 2>/dev/null && echo "sherlock: OK" || echo "sherlock: NOT INSTALLED"
which holehe   2>/dev/null && echo "holehe: OK"   || echo "holehe: NOT INSTALLED"
```

If tools are missing, inform the user once:
> For broader coverage install: `pipx install maigret`, `pipx install sherlock-project`,
> `pip install holehe`. Proceeding with web search methods.

| Tool | Install | What it does |
|------|---------|-------------|
| **Maigret** | `pipx install maigret` | Username → 3,000+ sites. Recursive PII extraction. JSON/HTML/PDF reports |
| **Sherlock** | `pipx install sherlock-project` | Username → 479 sites. Fast, reliable confirmation |
| **Holehe** | `pip install holehe` | Email → checks 120 services via forgot-password flow. Silent, no alert to target |
| **Blackbird** | GitHub clone | Username + email → 600 sites + AI profiling (optional) |

---

## Configuration File

Check for `~/.osint/config.json`. If present, read it for API keys and the optional `reports_dir`:

```json
{
  "pdl_api_key": "...",
  "hunter_api_key": "...",
  "github_token": "...",
  "reports_dir": "~/.osint/reports"
}
```

- **`reports_dir`** — where reports are written. Defaults to `~/.osint/reports` if unset. Always
  expand `~` and `mkdir -p` before writing.
- If the file doesn't exist, proceed without APIs and inform the user once:
  > No API keys found at ~/.osint/config.json. For richer results add PDL (peopledatalabs.com),
  > Hunter.io, and a GitHub token. Proceeding with web search methods.

### API keys (all free tier)
| Key | Source | Free tier | Provides |
|-----|--------|-----------|----------|
| `pdl_api_key` | peopledatalabs.com | 100 lookups/mo | Name → social URLs, usernames, employment, education. Contact data obfuscated on free tier; **social URLs included** |
| `hunter_api_key` | hunter.io | 50 credits/mo | Name + company domain → work email |
| `github_token` | github.com/settings/tokens | 5K req/hr | Lifts GitHub API rate limit; profile search by real name/email/location/org |

---

## Recon Account (optional, user-provided)

A dedicated burner account for platforms that gate content behind login. Session cookies/tokens
can be stored in the config file and used when fetching profile pages. Without it, coverage is
limited but the workflow still runs.

| Platform | Without login | With login |
|----------|--------------|------------|
| **LinkedIn** | Blurred/partial profile | Full work history, connections, activity |
| **Instagram** | 9–12 posts then login wall | Full posts, stories, followers |
| **Twitter/X** | Limited, aggressive login prompts | Full timeline, lists, likes |
| **Facebook** | Almost nothing useful | Friends, groups, check-ins, photos |
| **TikTok** | Fully public (least restrictive) | Comments, likes, following lists |

If the user has no recon account, note the affected platforms as "login-gated, partial data" in
the report rather than attempting to bypass any wall.

---

## Legal & Ethical Guidelines (apply to every phase)

- **Only use publicly available information.**
- **No hacking, social engineering, impersonation, or bypassing access controls.**
- **No contacting the target or their associates.**
- **Document every source** — every finding must trace to a public URL or API response.
- **Flag uncertainty** — if unsure an account belongs to the target, say so.
- **Respect privacy settings** — note private profiles but never attempt to bypass them.
- **Public figure vs private individual** — hold private individuals to a higher privacy bar.
- **Present findings neutrally** — no moral judgment, no psychoanalysis/diagnosis.

## Quality Guidelines (apply to every phase)

- Search each platform even when you expect nothing — document the negative result.
- Try multiple query variations (name with/without middle name, with location, with employer).
- Record exact URLs, not "found on LinkedIn."
- Note last-activity dates where visible.
- Flag inconsistencies between profiles (different locations, titles, photos).
- Never fabricate or assume — report only what is directly observed, and distinguish observation
  ("they posted X") from inference ("they likely believe Y").
- Account for platform norms (LinkedIn formal, Twitter casual, Reddit anonymous) and don't take
  clearly sarcastic content at face value.
