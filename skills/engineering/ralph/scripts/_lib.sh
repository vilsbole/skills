#!/usr/bin/env bash
# Shared helpers for the Ralph scripts. Sourced by once.sh and afk.sh.
# Not meant to be run directly.

# Last 10 RALPH: commits — the loop's memory of work already done.
ralph_memory() {
  git log --grep="^RALPH:" -n 10 --format="%H%n%ad%n%B---" --date=short 2>/dev/null \
    || echo "No RALPH commits yet — this is the first iteration."
}

# Build the full prompt for one iteration, branching on RALPH_SOURCE:
#   prd    (default) → reads plans/prompt.md; the agent works plans/prd.md.
#   issues           → reads plans/prompt.issues.md; the agent works the open
#                      issue queue, injected fresh each iteration.
#
# Issues-mode env knobs:
#   RALPH_LABEL           triage label to pull (default: ready-for-agent)
#   RALPH_ISSUE_LIST_CMD  full command to list the queue (default: gh).
#                         Override for non-GitHub trackers, e.g. a Linear CLI.
ralph_build_prompt() {
  local source="${RALPH_SOURCE:-prd}"
  local memory; memory="$(ralph_memory)"

  if [ "$source" = "issues" ]; then
    local label="${RALPH_LABEL:-ready-for-agent}"
    local list_cmd="${RALPH_ISSUE_LIST_CMD:-gh issue list --state open --label \"$label\" --limit 50}"
    local issues
    issues="$(eval "$list_cmd" 2>/dev/null \
      || echo "(could not fetch issues — run the list command yourself before picking one)")"
    printf '@plans/prompt.issues.md\n\nOpen issues ready for Ralph (tracker query: %s):\n%s\n\nPrevious RALPH commits (work already done — note which issues they reference):\n%s\n' \
      "$list_cmd" "$issues" "$memory"
  else
    printf '@plans/prompt.md\n\nPrevious RALPH commits (your memory of work already done):\n%s\n' \
      "$memory"
  fi
}
