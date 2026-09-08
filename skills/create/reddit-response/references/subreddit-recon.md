# Subreddit Recon

Read on demand. Nothing here is on the always-path of SKILL.md: reach for it when a comment has
disappeared, when the user wants to know where the rules hide, when they ask how to find threads, or
when they ask to automate any of this.

Figures below were checked in **September 2026**. Reddit changes them without notice, and several are
reported by third parties rather than published by Reddit. Where a number is illustrative it says so.

---

## Where the rules actually live

Five places, and only reading all five gives the real picture:

1. **Sidebar rules** — numbered, and `old.reddit.com/r/<sub>` shows sidebar text that new Reddit hides
2. **The wiki** — `/wiki/index` and `/wiki/rules`, usually the long-form version the sidebar summarizes
3. **Pinned or stickied mod posts** — where a promo policy change is announced and never folded back
   into the sidebar
4. **The post-flair list** — some subs sanction vendor participation only under a specific flair
5. **AutoModerator removal messages** — the operative rule for anything automated, and often stricter
   than the written one

Also search the sub for `self-promotion` and for `AI`, restricted to Meta-flaired posts.

A survey of 49 subreddits founders commonly pitch in found 39% ban self-promotion outright and 61%
either ban it or allow it only under a ratio constraint, with roughly half stricter than their
reputation suggests. Reputation is not a proxy for rules. Read the text for every sub, including the
ones "known" to be founder-friendly.

The 9:1 or 90/10 ratio is retired sitewide guidance. Many individual subs still write it into their own
rules, and where a sub states it, it is a hard constraint. It is never a Reddit rule.

## The removal diagnostic ladder

Run in order when a comment seems to have vanished. AutoModerator removal is silent: the comment renders
normally for its author while being invisible to everyone else.

1. **Open the comment permalink in a logged-out incognito window.** Visible to the author but absent
   there means removed, filtered, or shadowbanned. Visible in both means it posted and is simply
   downvoted or collapsed.
2. **Open the user profile logged out.** A 404 on the profile itself is a sitewide shadowban, which is
   an account-level state, not a subreddit action.
3. **Check whether the invisibility is one sub or everywhere.** One sub means AutoModerator, the
   subreddit's spam filter, or Crowd Control. Everywhere means the sitewide spam filter or a shadowban.
4. **Message modmail once**, politely, asking what rule the comment hit and whether it can be approved.
   Once. Never repost, never edit-and-repost, never create a second account, which is ban evasion and
   costs the account rather than the comment.

If step 2 shows a shadowban, the levers are account hygiene rather than appeals: verified email, no
VPN or datacenter IP, and ordinary non-promotional activity over weeks.

## The gates that filter before a human reads

Four separate mechanisms, all invisible from outside, all configured per subreddit:

- **AutoModerator age and karma thresholds.** Illustrative only, since configs are private: mid-size
  subs commonly sit around 30 days of account age and double-digit comment karma, and large subs
  demand more. Treat any number as a guess. There is no published list and no sitewide minimum.
- **Contributor Quality Score (CQS).** An account-level score AutoModerator can filter on. Karma and
  age can both pass while CQS blocks the comment. It cannot be checked or appealed. It moves with
  verified email, account security, non-VPN posting, and normal activity accumulated over weeks.
- **Crowd Control.** Suppresses comments from users with no history in that specific community,
  independent of sitewide karma. A first-ever comment in a sub is a low-probability post however strong
  the account.
- **Domain filters.** Per-domain and account-wide. Some subs run invisible domain blocklists where the
  comment posts, renders for the author, and is already gone.

Because none of this is testable from outside, never tell a user a comment will post. The incognito
check after posting is the only real test.

## What trips the sitewide spam filter

The same behaviors Reddit's own spam tooling and its builder rules target:

- Identical or near-identical text posted to more than one subreddit
- One domain repeated across subs, or a standing link in every comment
- Automated posting cadence, or comments spaced by seconds rather than minutes
- Automated voting or messaging
- An account whose entire history discusses one product

Reddit reports removing roughly 25,000 spammy posts and comments a day, with detection aimed
specifically at marketing-shaped text: superlative-stuffed language, narratives with tight clean arcs,
copy that reads as SEO output, and vote-to-reply mismatches.

## Finding threads worth answering

**Google, not Reddit search, and not an agent's built-in search.** Reddit's robots.txt disallows
crawlers and since July 2024 Google is effectively the only engine indexing it, so a Bing-backed search
tool returns nothing useful. Have the user run these themselves:

    site:reddit.com inurl:comments "best [category] tool"
    site:reddit.com inurl:comments "[competitor] alternative"
    site:reddit.com inurl:comments "[competitor]" (sucks OR "switching from" OR "cancel")
    site:reddit.com inurl:comments "[category]" "any recommendations"
    site:reddit.com/r/[sub] inurl:comments "[keyword]"

Add a time range through Google's Tools menu; `before:`/`after:` are Google operators and do not work
inside Reddit's own search box.

**Reddit's own search** is the fallback for recency: keyword plus `subreddit:`, sorted by New with a
time filter. It also supports `author:`, `title:`, `selftext:`, `self:`, and `flair_name:`.

**Monitoring tools**, current as of September 2026:

| Tool | Cost | Use it for | Limits |
|------|------|-----------|--------|
| F5Bot | Free | Push alerts on keywords | 5 keywords, 20 alerts/day, up to 2h delay |
| Reddit Pro Trends | Free | First-party discovery dashboard | No alerts, no export, no historical search |
| Syften | From ~$30/mo | Sub-minute alerts, archive search | 3 community filters on the entry plan |
| Brand24 | From ~$199/mo | Cross-channel brand listening | 12h update lag; too slow for reply hunting |

GummySearch shut down on 30 November 2025. If the user mentions it, say so and offer the stack above.

F5Bot plus Reddit Pro covers the free floor: Pro for discovery, F5Bot for the actual push. Pick narrow
keywords for F5Bot; a generic category term burns the 20-alert cap before mid-morning.

**Triage a thread before drafting:** is it archived or locked; does it rank in Google for a query the
user cares about; when was the most recent comment; is the OP still replying; comment count against the
size of the sub. A thread whose last comment is more than roughly a day old is not worth a promotional
reply unless it ranks.

## The automation boundary

**Discovery can be automated. Posting cannot.**

Reading Reddit programmatically is gated on the user already holding approved access: self-service app
registration closed under the Responsible Builder Policy, unauthenticated `.json` endpoints and plain
fetches now return 403, and free API access is limited to non-commercial use. A business monitoring its
own mentions through the API needs a negotiated agreement. Reported rates are 100 queries per minute
with OAuth against 10 without, and roughly $0.24 per 1,000 calls commercially.

Posting is a different question, and this skill's answer does not depend on the API terms. A comment
posted from a person's account makes a first-person claim under their name, so a human reads it, edits
it, and posts it. Reddit labels automated accounts with an `[App]` tag on the profile and reports
removing around 100,000 unauthorized bot accounts a day, so a bot posting first-person marketing copy
is both visible and short-lived. The per-action write throttle is separate from the read limits and
returns a server-specified wait of up to 600 seconds; if the user hits "You're doing that too much,"
they wait it out rather than retrying.

Refuse, every time: automated posting, automated voting, automated DMs, account creation, alt accounts
for promotion, and re-entry into a sub the user was banned from.

The precedent that settles the drafting question is the 2025 University of Zurich experiment on
r/changemyview, where undisclosed AI comments carrying fabricated lived experience produced account
bans, a formal complaint from the moderators, and legal threats. The workflow that survives is: AI
drafts, the human rewrites it in their own voice, the human posts it from their own account.
