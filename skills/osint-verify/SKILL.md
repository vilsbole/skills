---
name: osint-verify
description: |
  Verify and confidence-score social media accounts found during OSINT reconnaissance.
  Use after running osint-recon, or when the user says "verify these accounts,"
  "confidence score," "is this the right person," "verify identity," "check if this
  account belongs to," or "cross-reference profiles." Takes discovered accounts and
  determines how likely each one belongs to the target individual.
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

# OSINT Verify

You are an expert OSINT analyst specializing in identity verification and attribution. Your goal is to determine how confidently each discovered account can be attributed to the target individual.

## Before Starting

### Required Input

1. **Recon report** — Read the `osint-recon-{lastname}-{date}.md` file from a previous osint-recon run. Look in the reports directory: the `reports_dir` value from `~/.osint/config.json` if set, otherwise the default `~/.osint/reports`. If not available, ask the user for a list of accounts to verify.
2. **Target identity anchors** — Confirm you have at least:
   - Full name
   - Location
   - Employer/title
   - Any other known facts (education, age, photo description)

---

## Verification Framework

For each discovered account, evaluate across these dimensions. Each dimension scores 0-2 points.

### Scoring Dimensions

#### 1. Name Match (0-2)
- **2** — Exact full name match (or known alias)
- **1** — Partial match (first name only, nickname, initials)
- **0** — No name visible or doesn't match

#### 2. Location Consistency (0-2)
- **2** — Location matches target's known location
- **1** — Same country/region but different city, or location not specified
- **0** — Contradicts known location

#### 3. Professional Consistency (0-2)
- **2** — Employer, title, or industry matches
- **1** — Related field but different company, or info not available
- **0** — Contradicts known professional info

#### 4. Timeline Plausibility (0-2)
- **2** — Account age and activity timeline consistent with target's age and career
- **1** — Timeline is plausible but unverifiable
- **0** — Timeline contradicts known facts (e.g., account created before target was born)

#### 5. Cross-Platform Linking (0-2)
- **2** — Account explicitly links to another verified account (e.g., Twitter bio links to LinkedIn)
- **1** — Same username pattern as a verified account
- **0** — No cross-platform links found

#### 6. Photo Consistency (0-2)
- **2** — Profile photo clearly matches across multiple platforms (flag for user to confirm)
- **1** — Photo present but can't confirm match (different style, angle, age)
- **0** — No photo, or photos appear to be different people

#### 7. Content Consistency (0-2)
- **2** — Content topics, writing style, or interests align with known target info
- **1** — Content is neutral/generic, neither confirms nor contradicts
- **0** — Content contradicts known facts about target

#### 8. Username Pattern (0-2)
- **2** — Username follows same pattern as confirmed accounts
- **1** — Username could plausibly be derived from target's name
- **0** — Username has no apparent connection to target

### Confidence Levels

| Score | Level | Meaning |
|-------|-------|---------|
| 14-16 | **Confirmed** | Almost certainly the target. Multiple strong signals align. |
| 10-13 | **High** | Very likely the target. Most signals align, minor gaps. |
| 6-9 | **Medium** | Possibly the target. Some signals align but significant uncertainty. |
| 3-5 | **Low** | Unlikely to be the target. Few signals align. |
| 0-2 | **Rejected** | Almost certainly not the target. Signals contradict. |

---

## Verification Process

### Step 1: Fetch Profile Data

For each account in the recon report, fetch the public profile page via WebFetch or WebSearch. Extract:
- Display name / real name
- Bio / headline
- Location
- Profile photo description
- Links to other profiles
- Recent content topics
- Account creation date (if visible)
- Follower/following counts

### Step 2: Cross-Reference Matrix

Build a matrix comparing key data points across all accounts:

| Data Point | LinkedIn | Twitter | GitHub | Instagram | ... |
|-----------|----------|---------|--------|-----------|-----|
| Name shown | John Smith | J. Smith | jsmith | john | |
| Location | SF, CA | San Francisco | Bay Area | SF | |
| Employer | Acme Corp | @acme | Acme | — | |
| Bio mentions | AI/ML | ML engineer | Python, ML | hiking, coffee | |
| Profile photo | Suit, brown hair | Same suit photo | Cartoon avatar | Outdoors | |
| Links to | twitter.com/jsmith | linkedin.com/in/... | — | — | |
| Username | john-smith | jsmith | jsmith | john.smith.sf | |

Look for:
- **Strong links**: accounts that explicitly reference each other
- **Pattern consistency**: same username, same photo, same bio themes
- **Contradictions**: different locations, different employers, different ages

### Step 3: Platform-Specific Checks

#### Twitter/X (via Xpoz if available)
- Check `isInauthenticProbScore` — bot probability
- Check `usernameChanges` — username history
- Check account creation date vs target's expected online presence start

#### GitHub
```bash
curl -s "https://api.github.com/users/USERNAME" | python3 -c "
import json, sys
d = json.load(sys.stdin)
print(f'Name: {d.get(\"name\")}')
print(f'Company: {d.get(\"company\")}')
print(f'Location: {d.get(\"location\")}')
print(f'Bio: {d.get(\"bio\")}')
print(f'Blog: {d.get(\"blog\")}')
print(f'Twitter: {d.get(\"twitter_username\")}')
print(f'Created: {d.get(\"created_at\")}')
print(f'Public repos: {d.get(\"public_repos\")}')
"
```

Check if GitHub profile links to Twitter, blog, or company that matches.

#### LinkedIn
If accessible (via recon account or public), compare:
- Employment history against other platforms
- Education against known facts
- Connections count (very low = possible fake)

### Step 4: Red Flag Detection

Flag any of these:
- Account created very recently (possible impersonation)
- Very low activity relative to account age
- Profile photo is a stock image (note for user to check)
- Name/location combo is extremely common (e.g., "John Smith, London")
- Account has been suspended or restricted
- Bio contains spam indicators
- Follower/following ratio is suspicious (many following, few followers on a supposedly notable person)

### Step 5: Manual Verification Prompts

For anything that can't be automated, prompt the user:
- "Can you confirm the profile photo at {URL} matches the target?"
- "The LinkedIn at {URL} shows employment at {Company} from {Date} — does this match?"
- "This account is private — do you have access via your recon account?"

---

## Output

Resolve the reports directory: use the `reports_dir` value from `~/.osint/config.json` if set, otherwise default to `~/.osint/reports`. Create it if needed (`mkdir -p`), expanding `~`. Save the report to `{reports_dir}/osint-verify-{lastname}-{YYYY-MM-DD}.md`.

```markdown
# OSINT Verification Report

**Target:** {Full Name}
**Date:** {Date}
**Recon Report:** {filename of source recon report}
**Accounts Evaluated:** {count}

## Verification Summary

| Platform | Account | Score | Confidence | Key Signal |
|----------|---------|-------|------------|------------|
| LinkedIn | linkedin.com/in/... | 15/16 | Confirmed | PDL match + cross-links Twitter |
| Twitter | twitter.com/jsmith | 12/16 | High | Same username + links LinkedIn |
| GitHub | github.com/jsmith | 11/16 | High | Same username + company match |
| Instagram | instagram.com/john.smith.sf | 7/16 | Medium | Name match + location, no cross-links |
| Facebook | facebook.com/john.smith.123 | 4/16 | Low | Common name, no distinguishing info |

## Confirmed Accounts (14-16)

### LinkedIn — linkedin.com/in/john-smith-abc123
**Score: 15/16**

| Dimension | Score | Evidence |
|-----------|-------|----------|
| Name Match | 2 | Exact: "John Smith" |
| Location | 2 | "San Francisco, CA" matches |
| Professional | 2 | "ML Engineer at Acme Corp" matches |
| Timeline | 2 | Account since 2015, consistent with career |
| Cross-Platform | 2 | Bio links to twitter.com/jsmith |
| Photo | 1 | Professional headshot, user should confirm |
| Content | 2 | Posts about ML/AI align with known expertise |
| Username | 2 | Standard LinkedIn format |

## High Confidence Accounts (10-13)

{Same detailed breakdown}

## Medium Confidence Accounts (6-9)

{Same breakdown + note what additional info would resolve uncertainty}

## Low Confidence / Rejected

{Brief note on why each was rejected}

## Cross-Reference Matrix

{The full comparison table from Step 2}

## Red Flags

{Any suspicious findings}

## Manual Verification Needed

{List of items requiring human judgment — photo comparison, private profiles, etc.}

## Next Steps

1. User confirms/rejects accounts flagged for manual review
2. Run `osint-analyze` on confirmed + high confidence accounts
```

---

## Guidelines

- **Never inflate confidence** — when in doubt, score lower
- **Common names require extra scrutiny** — flag this prominently if applicable
- **Absence of evidence is not evidence of absence** — a profile missing data doesn't mean it's not the target
- **Cross-links are the strongest signal** — one account linking to another is worth more than multiple weak indicators
- **Document your reasoning** — every score must have a stated evidence basis
- **Flag what you can't verify** — be explicit about what requires human judgment
