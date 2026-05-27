# Recon Methods — Name → Usernames → All Platforms

This reference is read by **Phase 1 recon workers**. Each worker is dispatched a *subset* of the
methods below (one method family per worker) plus the target context, and returns structured
findings. The orchestrator merges, dedupes, and runs recursive rounds.

Goal: discover and catalog all online presence for the target using only publicly available
information and legal methods.

---

## Data Sources Overview

### Primary (free, no/high limits)
| Source | Method | Provides |
|--------|--------|----------|
| **Google dorks** | WebSearch | LinkedIn, Twitter, GitHub profiles from name; publications, news, talks |
| **GitHub API** | REST, 5K req/hr with token | Developer profiles by real name, email, location, org. Full profile JSON |
| **Reddit API** | REST, 100 req/min, no auth | User profiles, karma, activity |
| **TikTok** | Public URLs, no login | Profile data, videos |

### Secondary (free tier with limits)
| Source | Free tier | Provides |
|--------|-----------|----------|
| **PDL (People Data Labs)** | 100 lookups/mo | Name → social URLs, usernames, employment, education. Contact data obfuscated on free tier; social URLs included |
| **Hunter.io** | 50 credits/mo | Name + company domain → work email |
| **SEON** | 5/day | Email → presence on 90+ platforms |

### CLI tools (free, local, no keys) — availability is checked in setup
| Tool | Provides |
|------|----------|
| **Maigret** | Username → 3,000+ sites, recursive PII extraction |
| **Sherlock** | Username → 479 sites, fast confirmation |
| **Holehe** | Email → 120 services via silent forgot-password flow |

---

## Worker A — Google Dorks (WebSearch, always available)

Run these searches. Substitute `Full Name`, `Company`, `Location`.

**LinkedIn**
- `site:linkedin.com/in/ "Full Name" "Company"`
- `site:linkedin.com/in/ "Full Name" "Location"`

**Twitter/X**
- `site:twitter.com "Full Name" "Company"`
- `site:x.com "Full Name"`

**Instagram / TikTok / GitHub / Facebook**
- `site:instagram.com "Full Name"`
- `site:tiktok.com "Full Name"`
- `site:github.com "Full Name"`
- `site:facebook.com "Full Name" "Location"`

**Professional / publications**
- `"Full Name" "Company" site:medium.com OR site:substack.com OR site:dev.to`
- `"Full Name" site:scholar.google.com`
- `"Full Name" site:crunchbase.com OR site:wellfound.com`
- `"Full Name" speaker OR keynote OR podcast OR interview`
- `"Full Name" site:researchgate.net OR site:academia.edu`
- `"Full Name" "Company" blog OR portfolio OR about`

**Regional (if applicable)**
- `site:vk.com "Full Name"` (Russian) · `site:weibo.com "Full Name"` (Chinese)

---

## Worker B — GitHub API (Bash/curl, always available)

```bash
curl -s "https://api.github.com/search/users?q=FULLNAME+in:name+location:LOCATION" \
  -H "Accept: application/vnd.github.v3+json" \
  ${GITHUB_TOKEN:+-H "Authorization: token $GITHUB_TOKEN"}
```

For each matching user, fetch the full profile:
```bash
curl -s "https://api.github.com/users/USERNAME"
```
Extract: `login`, `name`, `bio`, `company`, `location`, `blog`, `twitter_username`, `email`,
`public_repos`, `created_at`.

---

## Worker C — CLI Sweep (Bash; only if tools installed)

Collect all usernames found so far. Deduplicate. For each unique username:

```bash
# Maigret — broad sweep, also extracts new usernames from profile pages
maigret USERNAME --json simple --timeout 15 2>/dev/null

# Sherlock — fast confirmation supplement
sherlock USERNAME --print-found --timeout 10 2>/dev/null
```

For each email found:
```bash
holehe EMAIL --no-color 2>/dev/null   # which services the email is registered on
```

Maigret may surface **additional usernames** from profile pages — return these separately so the
orchestrator can queue a recursive round.

---

## Worker D — PDL + Hunter (Bash/curl; only if keys present)

```bash
# PDL enrichment — name resolution
curl -s "https://api.peopledatalabs.com/v5/person/enrich?api_key=${PDL_API_KEY}&name=${FULL_NAME}&company=${COMPANY}&location=${LOCATION}" | python3 -m json.tool
```
Extract: `linkedin_url`/`linkedin_username`, `twitter_url`/`twitter_username`,
`github_url`/`github_username`, `facebook_url`/`facebook_username`, the `profiles[]` array (each
with `username`, `url`, `network`), and employment/education history for cross-referencing.

```bash
# Hunter.io — work email discovery
curl -s "https://api.hunter.io/v2/email-finder?domain=${COMPANY_DOMAIN}&first_name=${FIRST}&last_name=${LAST}&api_key=${HUNTER_API_KEY}"
```
Extract: email, confidence score, sources.

---

## Username Pattern Generation (fallback)

If the workers above find few results, generate candidate usernames from the name and feed the
top candidates back through Worker C. Be conservative — only report results with corroborating
evidence.

- `{first}{last}` → johnsmith
- `{first}.{last}` → john.smith
- `{first}_{last}` → john_smith
- `{first}{last}{YY}` → johnsmith91 (if birth year known)
- `{f}{last}` → jsmith
- `{last}{first}` → smithjohn
- `{first}{l}` → johns

---

## Recursive Discovery (orchestrator-controlled)

When workers surface new usernames or emails not in the original set:
1. Queue new usernames → another CLI-sweep round (Worker C).
2. Queue new emails → another Holehe round.
3. **Cap at 2 recursive rounds** to avoid rabbit holes.

---

## Platform Coverage Checklist

Workers should attempt every applicable platform and the orchestrator records negatives.

**Tier 1 — high priority:** LinkedIn, Twitter/X, Instagram, TikTok, Email, GitHub/GitLab
**Tier 2 — secondary:** Facebook, YouTube, Reddit, Medium/Substack, personal site/blog,
WeChat/Weibo, VK/Odnoklassniki, Telegram
**Tier 3 — professional & publications:** Google Scholar, ResearchGate/Academia.edu,
Crunchbase/AngelList, Patents (Google Patents), podcast/conference appearances, news mentions,
court records (public only)

---

## Worker Return Format (recon)

Each recon worker returns **only** this structure — no narration, no report prose:

```
## Recon worker: {A|B|C|D}

### Accounts found
- platform: {LinkedIn}
  url: {exact url}
  username: {handle}
  display_name: {name as shown}
  bio_excerpt: {short}
  location: {if shown}
  source_method: {Google dork query / GitHub API / Maigret / PDL / ...}
  preliminary_confidence: {High|Medium|Low} — {one-line reason}
{repeat}

### Emails found
- email: {addr} · source: {method} · registered_services: {Holehe list or "n/a"}

### New usernames/emails to recurse
- {handle or email}  (where seen)

### Platforms searched, no result
- {platform: query/method that returned nothing}

### Raw queries/calls run
- {exact query or API call, for auditability}
```
