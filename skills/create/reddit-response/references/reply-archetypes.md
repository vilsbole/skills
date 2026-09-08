# Reply Archetypes

Read when drafting a shape not inlined in Step 3 of SKILL.md, or when a worked example would settle a
drafting question. The word caps live in the Step 3 table and are not repeated here.

All examples use a fictional product, **Kettle**, a shift-scheduling tool for restaurants. Every
specific in them (versions, dates, numbers, tenures) is invented for the example. Replace them with
facts the user can stand behind, or cut the sentence. Never carry an example's specifics into a real
reply.

---

## The four long-tail archetypes

### Launch, resource, or content share

**Trigger.** The user has something to announce.

**Reply?** Only inside the sub's designated channel. Many subs confine promotion to a weekly megathread
or a required flair, and some cap mentions at one per 60 days. A launch dropped as a comment on an
unrelated thread is the worst version of every archetype in this file. If the sub has no sanctioned
lane and its rules ban promotion, there is no post to write.

**Structure.** What it does in one line, who it is *not* for, the specific thing learned or the specific
number (churn, a pricing mistake, a conversion figure), then the link. A launch framed as a decision and
what it cost survives where "introducing X" does not.

**Failure mode.** Framing promotion as a question, a poll, or a lessons-learned post whose only lesson is
that the product exists. Communities classify that as manipulation rather than promotion, and it draws
bans where an honest promo post draws only downvotes.

### Shilling accusation or hostility

**Trigger.** "This is an ad," "you're a shill," "check this guy's post history," or plain hostility.

**Reply?** Once, if the accusation is visible and the answer is clean. Not at all if the account is
trolling, and not at all if the history genuinely does look like promotion — replying invites an audit
the user loses. Check whether the accusation is substantively correct before drafting anything.

**Structure.** Confirm the affiliation flatly, point to where it was already disclosed, restate the
substance of the original answer in one clause, stop.

**Failure mode.** Wounded tone. "I was just trying to help," any appeal to how much time the user spends
answering questions here, or a second reply to a second hostile comment.

### Wrong-fit disqualification

**Trigger.** An ICP-adjacent question where the product technically appears but genuinely does not fit:
wrong scale, wrong budget, wrong compliance regime, wrong stack.

**Reply?** Yes. This is the highest-leverage comment a founder can post, because it is the one thing a
shill structurally cannot say and readers know it. It also prevents a churning customer.

**Structure.** Disclose, state plainly that the product is not the answer here and why in one specific
sentence, recommend by name what actually fits, and optionally add the narrow condition under which the
user would be the right call — one clause, not a paragraph.

**Failure mode.** Disqualifying yourself with a compliment: "we're overkill for you," "you're too early
for us," "built for scale." A stated weakness that flatters the product is a pitch wearing a concession's
clothes. The weakness has to cost the lead.

### Expertise question outside your commercial category

**Trigger.** A question in the user's domain that their product does not solve — hiring, pricing
strategy, a technical decision, a regulatory question.

**Reply?** Yes, generously and often. This is the reply type that makes the others possible: it builds the
history that clears AutoMod gates, and it makes the name recognizable before any disclosure.

**Structure.** Direct answer in the first sentence, then the reasoning, then the specific numbers or the
specific case it was seen in, then what to check before acting.

**Failure mode.** The product name appearing at all, including in a closing line or a profile-bait phrase
like "DM me." Give the answer away completely.

---

## Worked examples

### 1. Tool recommendation

**Thread.** "Any decent scheduling software for a 3-location restaurant group? Currently doing it in
Sheets and it's chaos."

**Before**

> Great question! Scheduling is definitely a pain point for multi-location operators. There are several
> excellent options on the market. I'd recommend checking out Kettle — it's built specifically for
> restaurants and handles multi-location scheduling, labor cost forecasting, and compliance tracking all
> in one place. Happy to answer any questions!

**After**

> Vendor here, so weigh this accordingly. The thing that decides it at three locations is whether staff
> move between sites. If they do, you want one employee record across locations, and most cheap tools
> model each site separately, so you end up double-booking the same person. Ask any vendor to show you a
> cross-location shift swap before you pay.
>
> Sheets holds up longer than people say if the sites don't share staff. If they do, we build Kettle for
> exactly that case, and Homebase does it too at a lower price if you don't need labor forecasting.

Role tag first sentence, product named once in the final third, one alternative named that the user does
not own. Deletion test: strip both product names and the reply still answers the question and still
carries the cross-location test.

### 2. Complaint, bug, or outage

**Thread.** "Kettle dropped our published schedule Saturday night and nobody could see their shifts. Two
no-shows. Anyone else?"

**Before**

> We take reliability extremely seriously and we're sorry for any inconvenience caused. Our team is
> looking into this. Please reach out to our support team so we can investigate further.

**After**

> Founder of Kettle. Yes, this was us — published schedules stopped rendering on mobile between roughly
> 6pm and 9pm Saturday, and staff who had never opened the app that week saw an empty week instead of an
> error. Bad failure mode on our side.
>
> Cause was a caching change we shipped Friday. It's reverted. What I don't know yet is how many
> locations saw it, and I'll post the count in this thread once I do. If you want the no-show hours
> credited, message me your account name.

Named role, the specific breakage in the OP's terms, what is known and what is not, a commitment with a
place to land. No apology boilerplate, no "reach out to support."

### 3. X vs Y comparison

**Thread.** "7shifts vs Kettle for a single busy bar — anyone used both?"

**Before**

> I'm biased (I work at Kettle) but I'd say we're the better choice for most operators. 7shifts is a
> solid product, but our customers tell us our interface is more intuitive and our support is faster.

**After**

> Founder of one of the two, so discount this. 7shifts has the better POS integration list — if you're on
> Toast and want sales-per-labor-hour without exporting anything, pick them and stop reading. Their tip
> pooling is also more flexible than ours.
>
> We're the better pick if you're scheduling across more than one bar with shared staff. Single site,
> single POS, the reason to pick us gets thin.

One falsifiable sentence on what the competitor does better, one on who should pick them, one real
constraint on the user's own product.

### 4. Misinformation correction

**Thread.** A comment claims: "Kettle got acquired last year and they've stopped shipping."

**Before**

> This is completely false and frankly damaging. Kettle has NOT been acquired. We're growing faster than
> ever and shipping constantly. Please do your research before spreading misinformation.

**After**

> Founder here, so, correcting the fact rather than the tone: we haven't been acquired. We raised a seed
> round in March, which may be where the wires crossed. Changelog is public if you want to check the
> shipping claim: [link to changelog].

One factual correction, a primary source rather than a marketing page, no argument about tone, no second
comment in the thread.

### 5. Expertise question inside your commercial category

**Thread.** "How do you handle scheduling when half your staff are students with changing availability?"

**Before**

> This is such a common challenge! The key is to have a system that allows staff to update their
> availability in real time and gives managers visibility into constraints. Tools like Kettle can help
> automate this.

**After**

> I work on the vendor side of scheduling, so take this with the appropriate salt.
>
> The thing that actually breaks is availability going stale, not the scheduling itself. Students update
> their availability once at hire and then never again, so by week six the manager is scheduling against
> fiction and eating the swaps.
>
> What worked at the two groups I've watched do this well: a hard availability reset at the start of each
> term, three weeks before it starts, and shifts unpublished until every student has confirmed. It's
> annoying and it front-loads the fight into one week instead of spreading it across the term. Anything
> where availability is optional to update degrades to the same mess by month two.

Role tag, no product name anywhere, one sub-question answered concretely, a position taken.

### 6. Launch or resource share (in a megathread)

**Before**

> 🚀 Excited to introduce Kettle — the all-in-one scheduling platform built for modern restaurants!
> Features include: multi-location scheduling, labor forecasting, compliance tracking, and more. Check
> us out at kettle.example and let me know what you think!

**After**

> Built Kettle, scheduling for restaurant groups with staff who move between sites.
>
> It's wrong for you if you run one location — Sheets or the free tier of anything beats paying us, and
> I've told several single-site owners that directly.
>
> The thing I got wrong for a year: we charged per location, so the customers who benefited most (staff
> shared across sites) paid the most for it. Moved to per-employee in January and churn in the 2-4
> location band halved. [link]

Leads with what it is, names who it is wrong for, carries one specific number that cost the user
something.

### 7. Shilling accusation

**Thread.** A reply to the user's tool recommendation: "lmao this is an ad, check his post history."

**Before**

> I disclosed that I work there in my very first sentence. I've been active in this sub for two years and
> spend a lot of my time answering questions here for free. Not everything is an ad.

**After**

> Fair check. Yes, I'm the founder — said so in the first line of that comment. The cross-location test
> I mentioned holds whichever tool you pick.

Under 50 words, affiliation restated flatly, no defense of intentions, no second reply.

### 8. Wrong-fit disqualification

**Thread.** "Single food truck, two employees. Is Kettle worth it?"

**Before**

> Kettle can definitely work for smaller operations! That said, you might find it's more powerful than
> you need right now — a lot of our smallest customers grow into the features over time.

**After**

> Founder of Kettle, and no, don't buy us for this. Two employees is a text message. We price per
> employee with a floor, so you'd be paying the floor for something a shared Google Calendar does better,
> and our onboarding assumes a manager who isn't also cooking.
>
> When you're running two trucks and the same three people work both, that's the point it starts being a
> real problem. Come find me then.

Names a real reason the product loses (the pricing floor, the onboarding assumption), recommends what
actually fits, keeps the "come back if" clause to one sentence.

---

## Reddit-native openers

Use when the archetype allows acknowledgment, and only when the opener carries information.

- "Yeah, known issue on [version]." — states a fact in the first four words
- "Depends which [variable] you're on, but" — signals a branch rather than hedging
- "Same setup, different result:" — flags first-hand experience without a preamble
- "This is the part that got us:" — narrows to one sub-question
- "> [quoted line from the parent]" — quote-then-respond, the most reliably native move, and it renders
  identically on old Reddit, new Reddit, and every app

Banned openers, in every archetype: "Great question," "This is a really interesting problem," "Thanks for
sharing," "I've been thinking about this a lot," and any compliment to the post or the poster.

## Credential tags

Front tag, two or three words, ending in a period: "Plumber here." / "Line cook, 11 years." / "Vendor
here." / "Founder of one of these."

Closing tag, lowercase, no fanfare: "source: ran this for eight years" / "context: I've deployed this at
two places, both times badly the first time"

Never a paragraph of background, never a title in the first person plural, never a credential the user
cannot produce if asked.
