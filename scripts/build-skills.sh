#!/usr/bin/env bash
# Package each non-engineering kitt skill into build/kitt-<name>.skill (a zip)
# for the Claude DESKTOP and iOS apps: Settings -> Skills -> upload.
#
# The internal frontmatter name, the output file, and the zip's root folder all
# become "kitt-<name>". A hyphen is the only separator the desktop/iOS uploader
# keeps -- it strips anything outside [a-z0-9-] (a colon collapses kitt:chef ->
# kittchef). Source SKILL.md files are never modified -- the name rewrite
# happens on a staged copy.
#
# The skill folder is the archive root (the zip contains kitt-<name>/SKILL.md,
# kitt-<name>/..., which is what the uploader expects. Engineering skills are
# excluded. Driven off the marketplace manifest's explicit skills list, so the
# copy-linkedin stub is skipped automatically.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MANIFEST="$ROOT/.claude-plugin/marketplace.json"
BUILD="$ROOT/build"
STAGE="$BUILD/.stage"

rm -rf "$BUILD"
mkdir -p "$STAGE"

paths="$(python3 -c '
import json, sys
m = json.load(open(sys.argv[1]))
for p in m["plugins"][0]["skills"]:
    print(p)
' "$MANIFEST")"

count=0
while IFS= read -r rel; do
  [ -z "$rel" ] && continue
  case "$rel" in */engineering/*) echo "skip (engineering): $rel" >&2; continue;; esac
  dir="$ROOT/${rel#./}"
  name="$(basename "$dir")"
  if [ ! -s "$dir/SKILL.md" ]; then
    echo "skip (no/empty SKILL.md): $rel" >&2
    continue
  fi
  staged="$STAGE/kitt-$name"
  cp -R "$dir" "$staged"
  # Rewrite only the FIRST `name:` line (the frontmatter one) on the staged copy.
  awk -v repl="name: kitt-$name" '
    /^name:/ && !done { print repl; done=1; next } { print }
  ' "$dir/SKILL.md" > "$staged/SKILL.md"
  ( cd "$STAGE" && zip -rq "$BUILD/kitt-$name.skill" "kitt-$name" -x '*/.DS_Store' '.DS_Store' )
  echo "built: build/kitt-$name.skill"
  count=$((count + 1))
done <<< "$paths"

rm -rf "$STAGE"
echo ""
echo "Done -- $count skill(s) in build/"
echo "Upload each .skill at: Claude desktop/iOS -> Settings -> Skills."
