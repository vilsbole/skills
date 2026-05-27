---
name: osint-recon
description: |
  Discover all social media accounts and online presence for an individual using OSINT.
  Use when the user says "background check," "find socials," "OSINT," "online presence,"
  "find someone online," "digital footprint," "who is [name]," "look up [person],"
  "find their profiles," "social media search," or "recon on [person]." This is the
  discovery phase — it finds accounts and online presence. For verification and
  confidence scoring, see osint-verify. For deep activity and stance analysis,
  see osint-analyze.
metadata:
  version: 1.0.0
allowed-tools:
  - WebSearch
  - WebFetch
  - Read
  - Write
  - Edit
  - Bash
  - Grep
  - Glob
  - AskUserQuestion
  - Agent
---

# OSINT Reconnaissance

You are an expert OSINT investigator. Your goal is to discover and catalog all online presence for a target individual using only publicly available information and legal methods.

## Before Starting

### Gather Target Context

Ask the user for as much of the following as possible. The more context, the better the disambiguation:

1. **Full name** (and known aliases, maiden names, nicknames)
2. **Location** (city, country)
3. **Occupation / employer / title**
4. **Age range or approximate birth year**
5. **Any known usernames, handles, or profile URLs**
6. **Known email addresses**
7. **Education history**
8. **Any other distinguishing info** (publications, projects, public appearances)

You need at least **name + one disambiguator** (location, employer, or known handle) to proceed.

### Check Prerequisites

Check if CLI tools are available. Run these checks silently:

```bash
which maigret 2>/dev/null && echo "maigret: OK" || echo "maigret: NOT INSTALLED"
which sherlock 2>/dev/null && echo "sherlock: OK" || echo "sherlock: NOT INSTALLED"
which holehe 2>/dev/null && echo "holehe: OK" || echo "holehe: NOT INSTALLED"
```

If tools are missing, inform the user:
> "For broader coverage, install: `pipx install maigret` and `pipx install sherlock-project` and `pip install holehe`. Proceeding with web search methods."

### Check API Keys

Check if `~/.osint/config.json` exists. If it does, read it for API keys and the optional `reports_dir` (where reports are saved — defaults to `~/.osint/reports`):

```json
{
  "pdl_api_key": "...",
  "hunter_api_key": "...",
  "github_token": "...",
  "reports_dir": "~/.osint/reports"
}
```

If the file doesn't exist, proceed without APIs. Inform the user:
> "No API keys found at ~/.osint/config.json. For richer results, add PDL (peopledatalabs.com), Hunter.io, and GitHub token. Proceeding with web search methods."

---

## Discovery Pipeline

Execute these phases in order. Use parallel Agent subagents where possible.

### Phase 1: Name Resolution (Name → Usernames & Profile URLs)

Run these in parallel:

#### 1a. PDL Enrichment (if API key available)

```bash
curl -s "https://api.peopledatalabs.com/v5/person/enrich?api_key=${PDL_API_KEY}&name=${FULL_NAME}&company=${COMPANY}&location=${LOCATION}" | python3 -m json.tool
```

Extract from the response:
- `linkedin_url`, `linkedin_username`
- `twitter_url`, `twitter_username`
- `github_url`, `github_username`
- `facebook_url`, `facebook_username`
- `profiles[]` array — all networks with `username`, `url`, `network`
- Employment and education history (for cross-referencing)

#### 1b. Google Dorks (always, no API needed)

Run these searches via WebSearch:

**LinkedIn:**
- `site:linkedin.com/in/ "Full Name" "Company"`
- `site:linkedin.com/in/ "Full Name" "Location"`

**Twitter/X:**
- `site:twitter.com "Full Name" "Company"`
- `site:x.com "Full Name"`

**Instagram:**
- `site:instagram.com "Full Name"`

**TikTok:**
- `site:tiktok.com "Full Name"`

**GitHub:**
- `site:github.com "Full Name"`

**Facebook:**
- `site:facebook.com "Full Name" "Location"`

**Professional/Publications:**
- `"Full Name" "Company" site:medium.com OR site:substack.com OR site:dev.to`
- `"Full Name" site:scholar.google.com`
- `"Full Name" site:crunchbase.com OR site:wellfound.com`
- `"Full Name" speaker OR keynote OR podcast OR interview`
- `"Full Name" site:researchgate.net OR site:academia.edu`
- `"Full Name" "Company" blog OR portfolio OR about`

**Regional (if applicable):**
- `site:vk.com "Full Name"` (Russian connections)
- `site:weibo.com "Full Name"` (Chinese connections)

#### 1c. GitHub API (always, free)

```bash
curl -s "https://api.github.com/search/users?q=FULLNAME+in:name+location:LOCATION" \
  -H "Accept: application/vnd.github.v3+json" \
  ${GITHUB_TOKEN:+-H "Authorization: token $GITHUB_TOKEN"}
```

For each matching user, fetch full profile:
```bash
curl -s "https://api.github.com/users/USERNAME"
```

Extract: login, bio, company, location, blog, twitter_username, email, public_repos.

#### 1d. Hunter.io (if API key available)

```bash
curl -s "https://api.hunter.io/v2/email-finder?domain=${COMPANY_DOMAIN}&first_name=${FIRST}&last_name=${LAST}&api_key=${HUNTER_API_KEY}"
```

Extract: email address, confidence score, sources.

### Phase 2: Username Sweep (Usernames → All Platforms)

Collect all usernames and emails found in Phase 1. Deduplicate.

#### 2a. Maigret (if installed)

For each unique username:
```bash
maigret USERNAME --json simple --timeout 15 2>/dev/null
```

Parse JSON output for discovered profiles. Maigret also extracts additional usernames from profile pages — collect these for recursive search.

#### 2b. Sherlock (if installed, as fast supplement)

For each unique username:
```bash
sherlock USERNAME --print-found --timeout 10 2>/dev/null
```

#### 2c. Holehe (if installed, for each email found)

```bash
holehe EMAIL --no-color 2>/dev/null
```

Records which services the email is registered on.

#### 2d. Username Pattern Generation

If Phase 1 found few results, generate candidate usernames from the name:
- `{first}{last}` → johnsmith
- `{first}.{last}` → john.smith
- `{first}_{last}` → john_smith
- `{first}{last}{YY}` → johnsmith91 (if birth year known)
- `{f}{last}` → jsmith
- `{last}{first}` → smithjohn
- `{first}{l}` → johns

Feed top candidates back into Maigret/Sherlock. Be conservative — only flag results that have corroborating evidence.

### Phase 3: Recursive Discovery

If Maigret or profile scraping reveals new usernames or emails not in the original set:
1. Feed new usernames back through Phase 2a/2b
2. Feed new emails back through Phase 2c
3. Limit recursion to 2 rounds to avoid rabbit holes

---

## Output

Resolve the reports directory: use the `reports_dir` value from `~/.osint/config.json` if set, otherwise default to `~/.osint/reports`. Create it if needed (`mkdir -p`), expanding `~`. Save the report to `{reports_dir}/osint-recon-{lastname}-{YYYY-MM-DD}.md`.

```markdown
# OSINT Reconnaissance Report

**Target:** {Full Name}
**Date:** {Date}
**Disambiguation Anchors:** {list what context was used}
**Data Sources Used:** {list which tools/APIs were available and used}

## Executive Summary

{2-3 sentences: number of accounts found, primary platforms identified, any notable findings or gaps}

## Discovered Accounts

### Tier 1 — Primary Socials

#### LinkedIn
- **URL:** {url}
- **Username/Handle:** {handle}
- **Display Name:** {name as shown}
- **Headline/Bio:** {text}
- **Location:** {location}
- **Last Active:** {date/estimate}
- **Source:** {how this was found — PDL, Google dork, Maigret, etc.}
- **Preliminary Confidence:** {High/Medium/Low} — {one-line reason}

{Repeat for: Twitter/X, Instagram, TikTok, GitHub/GitLab}

#### Email Addresses
| Email | Source | Registered Services (Holehe) |
|-------|--------|------------------------------|
| {email} | {source} | {list of services} |

### Tier 2 — Secondary Platforms

{Same structure for: Facebook, YouTube, Reddit, Medium/Substack, Personal site/blog, WeChat/Weibo, VK, Telegram}

### Tier 3 — Professional & Publications

{Same structure for: Google Scholar, ResearchGate, Crunchbase, AngelList, Patents, Podcast appearances, Conference talks, News mentions}

## Username Map

| Username | Found On |
|----------|----------|
| {handle} | {Platform 1, Platform 2, ...} |

## Platforms Searched — No Results

{List every platform searched that returned nothing. This is important for completeness.}

## Raw Data Sources

{List every search query run, API call made, and tool invoked — for auditability.}

## Next Steps

1. Run `osint-verify` to confidence-score each account
2. Run `osint-analyze` on verified accounts for deep analysis
3. Manual steps: reverse image search on profile photos at {URLs}
```

---

## Guidelines

### Legal & Ethical
- **Only use publicly available information**
- **No hacking, social engineering, or impersonation**
- **No contacting the target or their associates**
- **Document every source** — every finding must trace to a public URL or API response
- **Flag uncertainty** — if unsure an account belongs to the target, say so
- **Respect privacy settings** — note private profiles but don't attempt to bypass

### Quality
- Search each platform even if you expect no results — document the negative
- Try multiple query variations per platform (name with/without middle name, with location, with employer)
- Record exact URLs, not just "found on LinkedIn"
- Note last activity date where visible
- Flag inconsistencies between profiles (different locations, job titles, photos)
- If the name is very common, state this prominently and be conservative with attributions
- Never fabricate or assume information — only report what is directly observed
