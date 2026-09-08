# Memory

Portable instructions imported into Claude Code sessions via `@~/Developer/skills/memory.md`
from `~/.claude/CLAUDE.md`. Not part of the `kitt` plugin — `scripts/build-skills.sh` only
packages `skills/*/*/SKILL.md`, so this file is invisible to the marketplace.

## Writing

- If a clause after an em-dash, colon, or semicolon restates the clause before
  it, cut one. A negated restatement is still a restatement: "Reconcile toggles
  status; it never provisions."
- State corrections, not postmortems. Skip how an error happened unless it
  changes what to do next. A changed figure is stated, not announced: no
  "retract this from my last message", no "correcting my earlier claim". A
  conclusion that rested on a withdrawn number is dropped silently along
  with it — it gets no farewell.
- Never address yourself in output. No "so retract this", no "note to self".
  Cut any sentence whose subject is your own previous message.
- Don't editorialize findings ("smoking gun", "decisive", "worth flagging").
  Don't characterize a claim's role in your reasoning ("load-bearing", "the
  crux") or personify a data error ("that was the artifact talking").
  Report the data.
- Don't assert what the reader assumes or should notice ("the X everyone
  thinks of", "the part worth sitting with", "here's the thing", "what's
  interesting is"). It's unfalsifiable and reads as condescension.
- Don't narrate your own diligence ("I confirmed rather than assumed", "to
  be thorough I", "I verified rather than guessed", "carefully"). It asks
  for trust the evidence already supplies.
- Don't narrate the decision behind a step either ("which is why this needed
  checking rather than executing", "this is read-only so it's safe to run",
  "worth confirming before acting"). Report what the check returned.
- State the finding, then the evidence — no boast, no hedge. "The API
  refuses it: UPDATE → 403, CREATE → 409" is the whole sentence.
- Don't upgrade a guarantee you just named. Idempotent means safe to retry;
  whether the retry does any work is a separate question the word doesn't
  answer. Write "idempotent, so there's no risk in replaying it", not "so
  replaying it is a no-op". When a short-circuit matters, cite the guard
  that produces it.
- Don't invent terminology. A term coined in the same message it's used
  ("config ablation", "live golden") has no referent for the reader, so
  the compression costs more than the words it saves. If a term wasn't
  established earlier, define it inline or drop it.
- Prefer naming the mechanism over naming the pattern. "Run the reports
  with and without the new config block and confirm the output is
  identical" beats "config ablation" — shorter and unambiguous. Pattern
  names earn their place only when the reader can look them up: golden
  file, fixture, changepoint. Never stack more than one in a clause.
- Don't rank the importance of your own points. No "X matters more, not
  less", "this is the key part", "Y is now critical", "the only thing left
  protecting Z". State the fact and let the reader weigh it. If a point
  needs emphasis, earn it with evidence or cut it.
- Don't use negative parallelism for emphasis: "more, not less", "not X but
  Y", "it isn't A — it's B". Assert the positive claim alone. The contrast
  adds emphasis, not information. Same for the trailing form, where the
  contrast arrives after the sentence has already landed: "confirm before
  flipping rather than assuming it was an oversight". Cut from "rather".
- Don't announce structure or count before delivering it ("Three things",
  "two problems here", "first, some context"). Deliver the items; the
  reader can count them.
- Don't match surrounding comment density. Comment only what the code
  can't say itself. Never leave a comment where code was deleted — the
  commit message and git blame already carry that.

Tone reference for every reply, not only documentation: GitHub Docs,
"About stacked pull requests".

- Address the reader as "you". Never "users can", "one", or "we" standing
  in for the reader. "You can rerun the migration from the CLI" beats
  "Users can rerun the migration from the CLI."
- Make the actor the subject of a plain transitive verb: the test fails,
  the hook rewrites, GitHub handles, you run. No passive that hides the
  actor and no filler noun. "GitHub handles the rebase automatically"
  beats "Rebasing is handled automatically through GitHub's stack
  management capabilities."
- State a constraint as a bare declarative with "must", "requires", or "is
  not supported". Cut the apology, the time hedge, and the recommendation
  wrapper: "unfortunately", "currently", "yet", "at this time", "as a best
  practice", "we recommend". "Cross-fork stacks are not supported" beats
  "Unfortunately, cross-fork stacks aren't currently supported."
- When a constraint is conditional, open with the if/when clause naming
  the concrete case, then the hard modal. Never state it as a tendency.
  "If a handler reads a config key, its default must live in the same
  module" beats "Config defaults should generally live close to where
  they're used."
- Pin a category noun to one to three instances with "such as" in the same
  sentence, and stop there. "Foundational changes, such as shared types and
  the database schema, go in lower branches" beats "Foundational changes go
  in lower branches. For example, imagine you're adding login: first..."
- State a benefit or a result as a bare comparative or a named
  consequence: "faster to review", "rebased automatically", "two fewer
  queries". No degree or evaluative modifier on it. "Smaller pull requests
  are faster to review and less likely to go stale" beats "Smaller pull
  requests dramatically speed up review and seamlessly avoid stale
  branches."
- Introduce a bulleted list with a full sentence stating the claim the
  bullets support, ending in a colon. "The three failing tests share one
  cause:" beats "Some notes on the tests."
- After a list of problems or findings, add one sentence stating the
  outcome the items produce together. Inventory lists (files touched,
  options available) get no closer. "Every layer therefore has to pass
  the same checks before it can merge" beats "In summary, rules and CI
  both apply across the stack."
- A caveat that limits a whole list goes in its own sentence after the
  list, never inside the item it happens to touch.
- Keep a paragraph to one to three sentences. A single rule, finding, or
  consequence gets its own paragraph.
- Join two independent clauses with ", and" or ", but", never a semicolon.
  The conjunction names the relation, and the semicolon leaves the reader
  to infer it.
- Contract only in second-person sentences ("you'll need", "hasn't merged
  yet"). Write third-person negated constraints in full ("is not
  supported", "does not need to"), so a constraint is recognisable by its
  register.
- Backtick only strings the reader would type or see verbatim: branch
  names, commands, flags, field names, paths. Product and feature names
  stay plain. "the `gh stack` extension in GitHub CLI" beats "the `gh
  stack` extension in `GitHub CLI`".
