#!/usr/bin/env bash
# Enumerate macOS app-leftover candidates and flag the ones with no matching
# installed app, brew package, CLI binary, running process, or launchd label.
#
#   MIN_KB=1024  skip entries smaller than this (default 1MB)
#   SHOW_ALL=1   also print entries that matched something installed
#
# Read-only. Prints two sections: stale-app candidates, then tool caches.

set -uo pipefail

[ "$(uname)" = "Darwin" ] || { echo "mac-cleanup: macOS only (uname=$(uname))" >&2; exit 1; }

MIN_KB=${MIN_KB:-1024}
SHOW_ALL=${SHOW_ALL:-0}

INDEX=$(mktemp -t mac-cleanup-index)
ROWS=$(mktemp -t mac-cleanup-rows)
TOOLS=$(mktemp -t mac-cleanup-tools)
trap 'rm -f "$INDEX" "$ROWS" "$TOOLS"' EXIT

# ---------- index of what is actually installed / running ----------
{
  for d in /Applications /System/Applications "$HOME/Applications"; do
    [ -d "$d" ] || continue
    while IFS= read -r app; do
      basename "$app" .app
      /usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "$app/Contents/Info.plist" 2>/dev/null
    done < <(find "$d" -maxdepth 3 -name '*.app' -prune -print 2>/dev/null)
  done

  if command -v brew >/dev/null 2>&1; then
    brew list --formula 2>/dev/null
    brew list --cask 2>/dev/null
  fi

  # CLI binaries on PATH — many dotdirs belong to a tool, not an .app
  printf '%s\n' "${PATH//:/$'\n'}" | while IFS= read -r d; do
    [ -d "$d" ] && ls "$d" 2>/dev/null
  done

  ps -Ao comm= 2>/dev/null | sed 's|.*/||'
  launchctl list 2>/dev/null | awk 'NR>1 {print $3}'
} | tr '[:upper:]' '[:lower:]' | tr -cd '[:alnum:].\n-' | sed '/^$/d' | sort -u > "$INDEX"

# ---------- tool caches with a native prune command ----------
# These belong to live tooling; they are not stale-app leftovers.
tool_prune() {   # tool_prune <basename> <full path>
  case "$1" in
    .npm)              echo "npm cache clean --force" ;;
    .cargo)            echo "cargo cache --autoclean  (or rm -rf ~/.cargo/registry/cache)" ;;
    .rustup)           echo "rustup toolchain list — remove unused toolchains" ;;
    .gradle)           echo "rm -rf ~/.gradle/caches" ;;
    .m2)               echo "rm -rf ~/.m2/repository" ;;
    .bun)              echo "bun pm cache rm" ;;
    .deno)             echo "deno clean" ;;
    Homebrew)          echo "brew cleanup --prune=all" ;;
    go-build)          echo "go clean -cache" ;;
    pnpm|pnpm-store)   echo "pnpm store prune" ;;
    Yarn)              echo "yarn cache clean" ;;
    pip)               echo "pip cache purge" ;;
    uv)                echo "uv cache clean" ;;
    node-gyp)          echo "rm -rf ~/Library/Caches/node-gyp" ;;
    ms-playwright)     echo "npx playwright uninstall --all" ;;
    typescript)        echo "rm -rf ~/Library/Caches/typescript" ;;
    DerivedData)       echo "rm -rf ~/Library/Developer/Xcode/DerivedData/*" ;;
    *"DeviceSupport")  echo "rm -rf \"$2\"/*  (Xcode re-downloads on next device connect)" ;;
    CoreSimulator)     echo "xcrun simctl delete unavailable" ;;
    *) return 1 ;;
  esac
}

# ---------- is an entry name accounted for? ----------
known() {
  local name key
  name=$(printf '%s' "$1" | tr '[:upper:]' '[:lower:]' \
    | sed -E 's/\.(plist|savedstate|binarycookies|lockfile)$//' \
    | tr -cd '[:alnum:].-')
  [ -n "$name" ] || return 0

  # full name, then each component of a bundle id / hyphenated name
  for key in "$name" $(printf '%s' "$name" | tr '.-' '\n\n' | awk 'length($0)>=4'); do
    [ ${#key} -ge 4 ] || continue
    grep -qF -- "$key" "$INDEX" && return 0
  done
  return 1
}

emit() {           # emit <tier> <path>
  local tier=$1 path=$2 base kb status prune
  base=$(basename "$path")
  case "$base" in
    com.apple.*|group.com.apple.*|.|..) return ;;
  esac

  kb=$(du -sk "$path" 2>/dev/null | awk '{print $1}')
  [ -n "$kb" ] || return
  [ "$kb" -ge "$MIN_KB" ] || return

  if prune=$(tool_prune "$base" "$path"); then
    printf '%s\t%s\t%s\n' "$kb" "$path" "$prune" >> "$TOOLS"
    return
  fi

  if known "$base"; then
    status=KNOWN
    [ "$SHOW_ALL" = "1" ] || return
  else
    status=UNMATCHED
  fi

  printf '%s\t%s\t%s\t%s\n' "$kb" "$tier" "$status" "$path" >> "$ROWS"
}

scan_dir() {       # scan_dir <tier> <dir>
  local tier=$1 dir=$2 e
  [ -d "$dir" ] || return
  for e in "$dir"/*; do
    [ -e "$e" ] || continue
    emit "$tier" "$e"
  done
}

scan_dir SAFE    "$HOME/Library/Caches"
scan_dir SAFE    "$HOME/Library/Logs"
scan_dir SAFE    "$HOME/Library/Saved Application State"
scan_dir SAFE    "$HOME/Library/HTTPStorages"
scan_dir SAFE    "$HOME/Library/WebKit"

scan_dir INSPECT "$HOME/Library/Application Support"
scan_dir INSPECT "$HOME/Library/Containers"
scan_dir INSPECT "$HOME/Library/Group Containers"
scan_dir INSPECT "$HOME/Library/Preferences"
scan_dir INSPECT "$HOME/Library/LaunchAgents"
scan_dir INSPECT "$HOME/.config"
scan_dir INSPECT "$HOME/Library/Developer/Xcode"

for e in "$HOME"/.[!.]*; do
  [ -d "$e" ] && emit INSPECT "$e"
done

echo "=== STALE-APP CANDIDATES ==="
sort -rn -k1,1 "$ROWS" 2>/dev/null | awk -F'\t' '
  function h(kb) {
    if (kb >= 1048576) return sprintf("%.1fG", kb/1048576)
    if (kb >= 1024)    return sprintf("%.0fM", kb/1024)
    return sprintf("%dK", kb)
  }
  BEGIN { printf "%-8s  %-7s  %-9s  %s\n", "SIZE", "TIER", "STATUS", "PATH" }
  { printf "%-8s  %-7s  %-9s  %s\n", h($1), $2, $3, $4
    if ($3 == "UNMATCHED") total += $1 }
  END { printf "\n%.1f GB across UNMATCHED entries.\n", total/1048576 }
'

echo
echo "=== TOOL CACHES (live tooling — prune, do not delete blind) ==="
sort -rn -k1,1 "$TOOLS" 2>/dev/null | awk -F'\t' '
  function h(kb) {
    if (kb >= 1048576) return sprintf("%.1fG", kb/1048576)
    if (kb >= 1024)    return sprintf("%.0fM", kb/1024)
    return sprintf("%dK", kb)
  }
  BEGIN { printf "%-8s  %-45s  %s\n", "SIZE", "PATH", "PRUNE WITH" }
  { p = $2; sub(ENVIRON["HOME"], "~", p)
    printf "%-8s  %-45s  %s\n", h($1), p, $3; total += $1 }
  END { printf "\n%.1f GB across tool caches.\n", total/1048576 }
'

echo
echo "UNMATCHED = no installed app, brew package, CLI binary, running process, or"
echo "launchd label matched the name. It is a lead, not a verdict — verify first."
