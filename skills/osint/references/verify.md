# Verify Methods — Confidence-Score Each Account

This reference is read by **Phase 2 verify workers**. Each worker is dispatched one account (or a
small batch) plus the target identity anchors, scores the 8 dimensions, and returns a structured
scorecard. The orchestrator assembles the cross-reference matrix and overall verdicts.

Goal: determine how confidently each discovered account can be attributed to the target.

---

## Scoring Dimensions (each 0–2 points, 16 max)

**1. Name Match** — 2: exact full name (or known alias) · 1: partial (first name, nickname,
initials) · 0: no name visible or doesn't match.

**2. Location Consistency** — 2: matches known location · 1: same country/region or not specified
· 0: contradicts known location.

**3. Professional Consistency** — 2: employer/title/industry matches · 1: related field or info
unavailable · 0: contradicts known professional info.

**4. Timeline Plausibility** — 2: account age and activity consistent with target's age/career ·
1: plausible but unverifiable · 0: contradicts known facts (e.g. created before target was born).

**5. Cross-Platform Linking** — 2: explicitly links to another verified account (e.g. Twitter bio
links LinkedIn) · 1: same username pattern as a verified account · 0: no cross-links.

**6. Photo Consistency** — 2: photo clearly matches across platforms (flag for user confirm) · 1:
photo present, can't confirm (different style/angle/age) · 0: no photo or appears to be different
people.

**7. Content Consistency** — 2: topics/style/interests align with known info · 1: neutral/generic
· 0: contradicts known facts.

**8. Username Pattern** — 2: same pattern as confirmed accounts · 1: plausibly derived from name ·
0: no apparent connection.

---

## Confidence Levels

| Score | Level | Meaning |
|-------|-------|---------|
| 14–16 | **Confirmed** | Almost certainly the target. Multiple strong signals align. |
| 10–13 | **High** | Very likely. Most signals align, minor gaps. |
| 6–9 | **Medium** | Possibly. Some signals align, significant uncertainty. |
| 3–5 | **Low** | Unlikely. Few signals align. |
| 0–2 | **Rejected** | Almost certainly not the target. Signals contradict. |

---

## Verification Process

### Step 1 — Fetch profile data
For each account, fetch the public profile via WebFetch/WebSearch. Extract: display/real name,
bio/headline, location, profile-photo description, links to other profiles, recent content
topics, account creation date (if visible), follower/following counts.

### Step 2 — Platform-specific checks

**GitHub**
```bash
curl -s "https://api.github.com/users/USERNAME" | python3 -c "
import json, sys
d = json.load(sys.stdin)
for k in ['name','company','location','bio','blog','twitter_username','created_at','public_repos']:
    print(f'{k}: {d.get(k)}')
"
```
Check whether the GitHub profile links to Twitter/blog/company that matches.

**LinkedIn** (if accessible via recon account or public) — compare employment history and
education against other platforms; very low connection count can indicate a fake.

**Twitter/X** — note account creation date vs expected online-presence start; flag obvious
bot/inauthentic signals (default avatar, spammy bio, extreme following:follower ratio).

### Step 3 — Red flag detection
Flag any of: account created very recently (possible impersonation); very low activity relative
to account age; stock-image profile photo; extremely common name/location combo; suspended or
restricted account; spam indicators in bio; suspicious follower/following ratio for a supposedly
notable person.

### Step 4 — Items needing human judgment
Surface (do not guess) anything that needs the user:
- "Confirm the profile photo at {URL} matches the target?"
- "LinkedIn at {URL} shows {Company} from {Date} — does this match?"
- "This account is private — do you have access via your recon account?"

---

## Cross-Reference Matrix (assembled by orchestrator)

| Data point | LinkedIn | Twitter | GitHub | Instagram | … |
|-----------|----------|---------|--------|-----------|---|
| Name shown | | | | | |
| Location | | | | | |
| Employer | | | | | |
| Bio mentions | | | | | |
| Profile photo | | | | | |
| Links to | | | | | |
| Username | | | | | |

Look for **strong links** (accounts referencing each other), **pattern consistency** (same
username/photo/bio themes), and **contradictions** (different locations/employers/ages).

---

## Scoring Guidelines

- **Never inflate confidence** — when in doubt, score lower.
- **Common names require extra scrutiny** — flag prominently if applicable.
- **Absence of evidence ≠ evidence of absence** — missing data doesn't disprove the target.
- **Cross-links are the strongest signal** — one account linking to another beats several weak
  indicators.
- **Document reasoning** — every dimension score needs a stated evidence basis.

---

## Worker Return Format (verify)

Each verify worker returns **only** this structure per account:

```
## Verify: {platform} — {url}

score: {N}/16 → {Confirmed|High|Medium|Low|Rejected}
key_signal: {one-line strongest evidence}

dimensions:
- name_match: {0-2} — {evidence}
- location: {0-2} — {evidence}
- professional: {0-2} — {evidence}
- timeline: {0-2} — {evidence}
- cross_platform: {0-2} — {evidence}
- photo: {0-2} — {evidence}
- content: {0-2} — {evidence}
- username: {0-2} — {evidence}

profile_data:
  name_shown / location / employer / bio / photo_desc / links_to / username / created / followers

red_flags:
- {flag, or "none"}

needs_human:
- {item requiring user judgment, or "none"}
```
