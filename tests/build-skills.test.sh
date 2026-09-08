#!/usr/bin/env bash
# Test for scripts/build-skills.sh and the artifacts it produces.
# Runs the build, then asserts on build/ output. Exits non-zero on any failure.
#
# Note: we never pipe `unzip` into `grep -q`. Under `set -o pipefail`, grep -q
# closes the pipe on first match, unzip dies with SIGPIPE, and the pipeline is
# reported as failed. Instead we capture each listing into a variable and match
# it with a here-string.
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD="$ROOT/build"

# Skills that MUST be packaged (every manifest skill outside engineering/).
EXPECTED=(copywriting copy-editing humanizer reddit-response ai-seo programmatic-seo seo-audit \
          osint grill-me handoff write-a-skill mac-cleanup chef)
# Engineering skills that MUST NOT be packaged.
EXCLUDED=(diagnose grill-with-docs improve-codebase-architecture prototype \
          init-repo tdd to-issues to-prd triage zoom-out)

fails=0
pass() { printf '  ok   %s\n' "$1"; }
fail() { printf '  FAIL %s\n' "$1"; fails=$((fails + 1)); }
# ok <desc> <cmd...> : run cmd, pass if it succeeds.
ok()   { if "${@:2}"; then pass "$1"; else fail "$1"; fi; }

command -v zip   >/dev/null 2>&1 || { echo "zip not found"; exit 2; }
command -v unzip >/dev/null 2>&1 || { echo "unzip not found"; exit 2; }

echo "==> building"
bash "$ROOT/scripts/build-skills.sh" >/dev/null || { echo "build script failed"; exit 1; }

echo "==> count"
got=$(find "$BUILD" -maxdepth 1 -name '*.skill' | wc -l | tr -d ' ')
ok "produces ${#EXPECTED[@]} .skill files (got $got)" test "$got" -eq "${#EXPECTED[@]}"

echo "==> expected skills present, well-formed, correctly named"
for name in "${EXPECTED[@]}"; do
  skill="$BUILD/kitt-$name.skill"
  if [ ! -f "$skill" ]; then fail "kitt-$name.skill exists"; continue; fi
  pass "kitt-$name.skill exists"
  ok "kitt-$name.skill is a valid zip" unzip -tqq "$skill"

  listing="$(unzip -Z1 "$skill" 2>/dev/null)"   # one entry per line, no pipe to grep
  # Skill folder must sit at the archive root: kitt-<name>/SKILL.md
  if grep -qx "kitt-$name/SKILL.md" <<<"$listing"; then
    pass "kitt-$name.skill has kitt-$name/SKILL.md at root"
  else
    fail "kitt-$name.skill has kitt-$name/SKILL.md at root"
  fi
  # Internal frontmatter name must be kitt-<name>, not the bare source name.
  # (The uploader strips anything outside [a-z0-9-], so a hyphen is required.)
  nameline=$(unzip -p "$skill" "kitt-$name/SKILL.md" 2>/dev/null | grep -m1 '^name:')
  if [ "$nameline" = "name: kitt-$name" ]; then
    pass "kitt-$name.skill name: is 'kitt-$name'"
  else
    fail "kitt-$name.skill name: is 'kitt-$name' (got '${nameline:-<none>}')"
  fi
done

echo "==> engineering skills excluded"
for name in "${EXCLUDED[@]}"; do
  ok "kitt-$name.skill NOT present" test ! -f "$BUILD/kitt-$name.skill"
done

echo "==> bundled resources travel with the skill"
chef_list="$(unzip -Z1 "$BUILD/kitt-chef.skill" 2>/dev/null)"
if grep -qx "kitt-chef/scripts/render.py" <<<"$chef_list"; then
  pass "kitt-chef.skill includes scripts/render.py"
else
  fail "kitt-chef.skill includes scripts/render.py"
fi
copy_list="$(unzip -Z1 "$BUILD/kitt-copywriting.skill" 2>/dev/null)"
if grep -q "^kitt-copywriting/references/" <<<"$copy_list"; then
  pass "kitt-copywriting.skill includes references/"
else
  fail "kitt-copywriting.skill includes references/"
fi

echo "==> source SKILL.md files are NOT mutated by the build"
src_name=$(grep -m1 '^name:' "$ROOT/skills/create/copywriting/SKILL.md")
if [ "$src_name" = "name: copywriting" ]; then
  pass "source copywriting name: stays bare"
else
  fail "source copywriting name: stays bare (got '$src_name')"
fi

echo
if [ "$fails" -eq 0 ]; then
  echo "PASS — all checks green"
  exit 0
else
  echo "FAIL — $fails check(s) failed"
  exit 1
fi
