# Analyze Methods — Deep Profile from Verified Accounts

This reference is read by **Phase 3 analyze workers**. Each worker is dispatched one module below
plus the list of Confirmed/High accounts and the configured key topics, and returns structured
findings. The orchestrator synthesizes them into the analysis section of the report.

Goal: produce a comprehensive, evidence-based behavioral and professional profile. Only analyze
accounts rated **Confirmed** or **High** (Medium only if the user explicitly opts in).

---

## Module 1 — Activity Profile

**Posting frequency:** Active (multiple/week) · Moderate (weekly–monthly) · Sparse (<monthly) ·
Dormant (none in 6+ months) · Ghost (exists, ~never posted).

**Timeline:** account creation; first meaningful post; gaps (career changes, life events,
abandonment); peak activity periods; trend up/down/stable.

**Engagement:** creates vs reshares vs replies; typical engagement received; whether they reply to
their audience; who they engage with most (key connections).

## Module 2 — Content Analysis

For each platform, analyze recent content (last 50–100 posts where available) via WebFetch:
- Top 5 topics; professional vs personal ratio; tone (formal/casual/provocative/educational/
  humorous); original vs reshared.

Platform-usage norms: **LinkedIn** professional signaling/thought leadership · **Twitter/X**
real-time opinions/commentary · **Instagram** lifestyle/visual · **TikTok** entertainment/trends ·
**GitHub** technical projects/OSS · **Medium/Substack** long-form · **Reddit** anonymous
opinions/interests outside professional identity.

## Module 3 — Developer Profile (if GitHub/GitLab present)

```bash
# Public repos
curl -s "https://api.github.com/users/USERNAME/repos?sort=updated&per_page=30" \
  ${GITHUB_TOKEN:+-H "Authorization: token $GITHUB_TOKEN"} | python3 -c "
import json, sys
for r in json.load(sys.stdin):
    print(f'{r[\"name\"]:30} {r[\"language\"] or \"-\":15} Stars:{r[\"stargazers_count\"]:4} Forks:{r[\"forks_count\"]:4} {r[\"updated_at\"][:10]}')
"

# Contribution activity
curl -s "https://api.github.com/users/USERNAME/events/public?per_page=100" \
  ${GITHUB_TOKEN:+-H "Authorization: token $GITHUB_TOKEN"} | python3 -c "
import json, sys
from collections import Counter
for t, c in Counter(e['type'] for e in json.load(sys.stdin)).most_common():
    print(f'{t}: {c}')
"
```
Assess: primary/secondary languages; project types (libraries, apps, tools, learning, forks);
contribution pattern (consistent vs burst); OSS involvement (PRs, issues, community); code-quality
signals (docs, tests, CI); learning trajectory; starred repos (interests).

## Module 4 — Professional Timeline

Reconstruct from all sources: employment history (LinkedIn primary, cross-referenced); education;
career progression and transitions; side projects/entrepreneurial activity; publications,
patents, talks; awards. Flag gaps or inconsistencies between platforms.

## Module 5 — Network Analysis

Key connections (frequent @mentions, co-authors, mutual endorsements); affiliations (companies,
orgs, communities); influencers they follow/engage (information diet); geography of network
(local/national/international).

## Module 6 — Stance Analysis

For each configured key topic:

1. **Find content:**
   - `"Full Name" site:twitter.com "{topic}"`
   - `"Full Name" site:linkedin.com "{topic}"`
   - `"Full Name" "{topic}" opinion OR view OR think OR believe`
   - plus posts/articles already fetched in Module 2.
2. **Classify stance:** Strong advocate · Leaning positive · Neutral/No signal · Leaning negative
   · Strong critic · Mixed/Evolving.
3. **Evidence basis:** link specific posts/articles/statements; note whether evidence is strong
   (direct statement) or inferred (liked/shared); note professional consensus vs personal
   conviction.

## Module 7 — Red Flags & Risk Assessment

Scan for: controversial/inflammatory statements; legal mentions (lawsuits, court records,
regulatory actions); employment disputes; credibility issues (fabricated credentials,
contradictions across platforms); security concerns (oversharing, poor opsec); reputation risk
(association with controversial figures/orgs); account anomalies (purchased followers, bot-like or
coordinated inauthentic behavior). Also record **areas checked with clean results** — important
for completeness.

---

## Analytical Standards

- **Evidence-based only** — every claim links to a specific URL or data point.
- **Observation vs inference** — "they posted X" vs "they likely believe Y."
- **No psychoanalysis** — describe behavior/content, don't diagnose personality.
- **Balanced** — include positive signals and concerns.
- **Recency matters** — a 2014 tweet is less indicative than a recent one.
- **Satire/humor** — don't take clearly sarcastic content at face value.
- **Platform-selection bias** — note when findings are skewed by which platforms were available.
- **Refuse** if the analysis purpose shifts toward harassment/stalking.

---

## Worker Return Format (analyze)

Each analyze worker returns **only** this structure for its module:

```
## Analyze module: {1-7 name}

findings:
- {structured finding with evidence URL}
{repeat}

evidence_urls:
- {url} — {what it supports}

limitations:
- {what couldn't be assessed for this module and why}
```

For Module 6 specifically, return per-topic rows: `topic | stance | confidence | evidence links`.
