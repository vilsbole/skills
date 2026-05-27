# OSINT Report — {Full Name}

**Target:** {Full Name}
**Date:** {YYYY-MM-DD}
**Analysis Purpose:** {stated purpose}
**Disambiguation Anchors:** {context used — location, employer, known handles}
**Data Sources Used:** {tools/APIs available and used}
**Phases Completed:** {Recon | Recon+Verify | Recon+Verify+Analyze}

> This is a single, incrementally-written report. Phase 1 writes the **Reconnaissance** section,
> Phase 2 appends **Verification**, Phase 3 appends **Analysis**. The presence of each section is
> what tells a resumed run where to continue.

---

# 1. Reconnaissance
*(written after Phase 1)*

## Executive Summary
{2–3 sentences: number of accounts found, primary platforms, notable findings or gaps}

## Discovered Accounts

### Tier 1 — Primary Socials
For each of LinkedIn, Twitter/X, Instagram, TikTok, GitHub/GitLab:
- **URL:** {url}
- **Username/Handle:** {handle}
- **Display Name:** {name as shown}
- **Headline/Bio:** {text}
- **Location:** {location}
- **Last Active:** {date/estimate}
- **Source:** {PDL / Google dork / Maigret / GitHub API / ...}
- **Preliminary Confidence:** {High|Medium|Low} — {one-line reason}

#### Email Addresses
| Email | Source | Registered Services (Holehe) |
|-------|--------|------------------------------|
| {email} | {source} | {services} |

### Tier 2 — Secondary Platforms
{Same structure: Facebook, YouTube, Reddit, Medium/Substack, personal site/blog, WeChat/Weibo, VK, Telegram}

### Tier 3 — Professional & Publications
{Same structure: Google Scholar, ResearchGate, Crunchbase, AngelList, Patents, podcasts, talks, news mentions}

## Username Map
| Username | Found On |
|----------|----------|
| {handle} | {Platform 1, Platform 2, …} |

## Platforms Searched — No Results
{Every platform searched that returned nothing — important for completeness.}

## Raw Data Sources (recon)
{Every search query, API call, and tool invocation — for auditability.}

---

# 2. Verification
*(appended after Phase 2)*

**Accounts Evaluated:** {count}

## Verification Summary
| Platform | Account | Score | Confidence | Key Signal |
|----------|---------|-------|------------|------------|
| LinkedIn | {url} | 15/16 | Confirmed | {signal} |
| Twitter | {url} | 12/16 | High | {signal} |

## Confirmed Accounts (14–16)
### {Platform} — {url}  **Score: N/16**
| Dimension | Score | Evidence |
|-----------|-------|----------|
| Name Match | | |
| Location | | |
| Professional | | |
| Timeline | | |
| Cross-Platform | | |
| Photo | | |
| Content | | |
| Username | | |

## High Confidence (10–13)
{Same detailed breakdown}

## Medium Confidence (6–9)
{Same breakdown + what additional info would resolve the uncertainty}

## Low / Rejected
{Brief note on why each was excluded}

## Cross-Reference Matrix
| Data point | {Platform A} | {Platform B} | … |
|-----------|--------------|--------------|---|
| Name shown | | | |
| Location | | | |
| Employer | | | |
| Bio mentions | | | |
| Profile photo | | | |
| Links to | | | |
| Username | | | |

## Red Flags
{Suspicious findings, or "none"}

## Manual Verification Needed
{Items requiring human judgment — photo comparison, private profiles, etc. Note user decisions.}

---

# 3. Analysis
*(appended after Phase 3)*

**Accounts Analyzed:** {list with confidence levels}

## Executive Summary
{3–5 sentences: who this person appears to be, key findings, strengths/concerns, overall presence.}

## Activity Profile
| Platform | Status | Frequency | Since | Primary Use |
|----------|--------|-----------|-------|-------------|
| | | | | |

### Engagement Patterns
{Creation vs consumption, audience interaction, per platform}

## Content Analysis
### Top Themes
1. {Theme} — {platforms}, {frequency}
### Voice & Tone
{How they communicate}
### Original vs Shared
{Ratio and pattern}

## Developer Profile (if applicable)
- **Primary languages:** {list}
- **Specialization:** {area}
- **OSS contributions:** {summary}
- **Notable projects:** {list}
- **Contribution pattern:** {consistency, volume, trajectory}
- **Technical reputation:** {stars, forks, followers}

## Professional Timeline
| Period | Role | Organization | Source |
|--------|------|-------------|--------|
| | | | |

### Education
{Degrees, certifications}
### Publications & Speaking
{Papers, talks, podcasts, articles}

## Network Analysis
### Key Connections
{Notable public connections/interactions}
### Affiliations
{Organizations, communities, groups}

## Stance Analysis
| Topic | Stance | Confidence | Evidence |
|-------|--------|------------|----------|
| {Topic} | {Strong advocate/...} | {High/Med/—} | {links} |

### Detailed Stance Breakdown
#### {Topic}
**Stance: {classification}**
- {link} — "{quote}"
- Pattern: {since when, how consistent}

## Red Flags & Risk Assessment
### Flags Found
{Concerns with evidence and severity}
### No Flags Found In
{Areas checked with clean results}

## Digital Presence Score
| Dimension | Rating | Notes |
|-----------|--------|-------|
| Professional visibility | High/Med/Low | |
| Content quality | High/Med/Low | |
| Network strength | High/Med/Low | |
| Cross-platform consistency | High/Med/Low | |
| Authenticity signals | High/Med/Low | |
| Risk level | High/Med/Low | |

## Limitations
{What couldn't be assessed — private accounts, platforms not checked, tools unavailable, common-name disambiguation.}

## Raw Sources (analysis)
{All URLs, searches, and API calls used in the analysis.}
