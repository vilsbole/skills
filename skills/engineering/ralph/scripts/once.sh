#!/usr/bin/env bash
# Ralph — single human-in-the-loop iteration.
# Run this and WATCH IT before going AFK with afk.sh. One clean pass here
# catches a bad PRD / wrong queue / wrong test command / missing permission cheaply.
#
# Usage:
#   bash plans/once.sh                       # PRD mode — works plans/prd.md
#   RALPH_SOURCE=issues bash plans/once.sh   # issues mode — works the ready-for-agent queue
#
# Effect: picks ONE small task, builds it, runs the project's feedback loops,
#         makes one RALPH: commit (and, in issues mode, closes the issue when done).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/_lib.sh"

cd "$(git rev-parse --show-toplevel)"

claude --permission-mode acceptEdits "$(ralph_build_prompt)"
