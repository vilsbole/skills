#!/usr/bin/env bash
# Ralph — bounded autonomous loop (AFK mode).
#
# Each iteration relaunches `claude` with a FRESH context window, hands it the
# fixed prompt + its task source + the last 10 RALPH: commits (its memory), and
# lets it complete ONE small task and commit. Repeats up to <iterations> times.
#
# This loop is BOUNDED ON PURPOSE. There is no `while :;` variant — an unattended
# infinite loop with edit permissions is a foot-gun. Always pass a count.
#
# Task source (RALPH_SOURCE):
#   prd    (default) → plans/prd.md
#   issues           → open issues with the ready-for-agent label (the queue is
#                      re-fetched every iteration, so closed issues drop out).
#
# Usage:
#   bash plans/afk.sh <iterations>                       # PRD mode, e.g. 20
#   RALPH_SOURCE=issues bash plans/afk.sh <iterations>   # issues mode
#   RALPH_SANDBOX=1 RALPH_SOURCE=issues bash plans/afk.sh 30   # sandboxed + issues
#
# Other knobs (issues mode): RALPH_LABEL, RALPH_ISSUE_LIST_CMD — see _lib.sh.
#
# Exit codes:
#   0  agent emitted <promise>NO MORE TASKS</promise>, or the iteration cap was reached
#   1  agent emitted <promise>ABORT</promise> (blocked — see last commit + log)
#  64  usage error

set -euo pipefail

if [ -z "${1:-}" ]; then
  echo "Usage: $0 <iterations>   (e.g. $0 20)" >&2
  exit 64
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/_lib.sh"

cd "$(git rev-parse --show-toplevel)"
mkdir -p plans/logs
log=plans/logs/ralph.log

iterations="$1"

# Runner: plain claude, or sandboxed when RALPH_SANDBOX=1 (recommended for true AFK).
runner=(claude)
if [ "${RALPH_SANDBOX:-0}" = "1" ]; then
  runner=(docker sandbox run claude . --)
fi

# jq filters over the stream-json output:
#   stream_text  — assistant text, for live narration
#   final_result — the terminal result block, which we grep for the promises
stream_text='select(.type=="assistant").message.content[]? | select(.type=="text").text // empty'
final_result='select(.type=="result").result // empty'

for ((i=1; i<=iterations; i++)); do
  header="------- ITERATION $i / $iterations (source=${RALPH_SOURCE:-prd}) --------"
  echo "$header"; echo "$header" >> "$log"

  tmpfile=$(mktemp)
  trap 'rm -f "$tmpfile"' EXIT

  # Built fresh each iteration so the issue queue reflects just-closed issues.
  prompt="$(ralph_build_prompt)"

  "${runner[@]}" \
    --verbose --print --output-format stream-json --permission-mode acceptEdits \
    "$prompt" \
    | grep --line-buffered '^{' \
    | tee "$tmpfile" \
    | jq --unbuffered -rj "$stream_text" \
    | tee -a "$log"

  result=$(jq -r "$final_result" "$tmpfile" 2>/dev/null || true)
  rm -f "$tmpfile"; trap - EXIT

  if [[ "$result" == *"<promise>NO MORE TASKS</promise>"* ]]; then
    msg="✅ Ralph complete — no more tasks after $i iteration(s)."
    echo "$msg"; echo "$msg" >> "$log"
    exit 0
  fi

  if [[ "$result" == *"<promise>ABORT</promise>"* ]]; then
    msg="🛑 Ralph aborted by the agent after $i iteration(s). Read the last RALPH: commit + $log."
    echo "$msg" >&2; echo "$msg" >> "$log"
    exit 1
  fi
done

msg="⏹  Reached iteration cap ($iterations). Review: git log --grep='^RALPH:' --oneline"
echo "$msg"; echo "$msg" >> "$log"
