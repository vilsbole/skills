# Credits & Third-Party Notices

## mattpocock/skills (MIT)

The following skills are vendored from [mattpocock/skills](https://github.com/mattpocock/skills):

- `skills/engineering/*` — the engineering workflow suite (`diagnose`, `grill-with-docs`, `improve-codebase-architecture`, `prototype`, `tdd`, `to-issues`, `to-prd`, `triage`, `zoom-out`, and `init-repo`).
- `skills/core/{grill-me,handoff,write-a-skill}` — core productivity skills.

`init-repo` is a renamed copy of the upstream `setup-matt-pocock-skills` skill (folder, frontmatter `name`, and the `/setup-matt-pocock-skills` → `/init-repo` slash references were updated). Skill logic is otherwise unchanged.

> Note: `skills/engineering/ralph` is **not** vendored — it is originally authored for this repo (see below).

## skills/engineering/ralph (original — inspired by prior art)

`ralph` is written for this repo. Its loop design follows Matt Pocock's public "Ralph" approach ([aihero.dev](https://www.aihero.dev/getting-started-with-ralph)) — `RALPH:`-prefixed commits as the loop's memory, a bounded iteration count, `<promise>NO MORE TASKS</promise>` / `<promise>ABORT</promise>` control flow, and stream-json monitoring — and Geoffrey Huntley's original Ralph Wiggum technique ([ghuntley.com/ralph](https://ghuntley.com/ralph)). No upstream code is copied; the scripts and prompt are independent implementations of those ideas.

These files are distributed under the MIT License, reproduced below:

```
MIT License

Copyright (c) 2026 Matt Pocock

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```
