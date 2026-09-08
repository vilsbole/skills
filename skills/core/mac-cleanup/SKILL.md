---
name: mac-cleanup
description: Find and remove leftover files on macOS from apps that are no longer installed — stale Application Support, Preferences, Containers, Caches, LaunchAgents, and dotfiles. Use when the user says "clean up my Mac", "free up disk space", "what's eating my disk", "leftover app files", "uninstall leftovers", "stale caches", "my disk is full", or asks why an uninstalled app still has data on disk.
---

# macOS Stale App Cleanup

Reclaim disk space by removing files left behind by apps that are gone. macOS
uninstalls leave data in `~/Library` indefinitely; nothing garbage-collects it.

**macOS only.** If `uname` is not `Darwin`, say so and stop.

## Safety rules

These are not negotiable — deletion here is destructive and often irreversible.

1. **Never delete without showing the user the list first.** Present a table of
   candidates with size, path, and why each is believed stale. Get explicit
   approval. Approval of one batch does not extend to the next.
2. **Prefer the Trash over `rm`.** Use `trash <path>` if the `trash` CLI is
   installed, otherwise `mv <path> ~/.Trash/`. Reserve `rm -rf` for caches, and
   only when the user asks for it. Say which you used.
3. **Never touch `com.apple.*`** or anything under `/System`.
4. **Inspect before removing anything under Application Support, Containers, or
   Group Containers.** These hold irreplaceable user data — databases, license
   keys, exported projects, message history. `ls -la` the directory and report
   what's inside before proposing removal.
5. **"Not in `/Applications`" is not proof of stale.** CLI tools, LaunchAgents,
   PWAs, and apps living elsewhere all leave Library entries. Treat an unmatched
   entry as a question for the user, not a verdict.

## Workflow

```
Enumerate  →  Cross-reference  →  Confirm with user  →  Remove  →  Verify
```

### 1. Enumerate + cross-reference

Run the bundled scanner. It sizes every candidate entry, builds an index of what
is actually installed, and splits the results into two sections:

- **STALE-APP CANDIDATES** — entries whose name matched nothing installed
- **TOOL CACHES** — live developer tooling with a native prune command

```sh
bash skills/core/mac-cleanup/scripts/scan.sh
```

If that path does not exist, the skill is installed as a plugin — resolve
`scripts/scan.sh` relative to this SKILL.md's own directory.

Options (environment variables):

- `MIN_KB=1024` — skip entries smaller than this (default 1MB; raise to cut noise)
- `SHOW_ALL=1` — include matched entries too, not just unmatched

The index it matches against covers: app bundles in `/Applications`,
`/System/Applications`, `~/Applications` (both name and `CFBundleIdentifier`),
`brew list --formula`, `brew list --cask`, every executable on `PATH`, running
process names, and `launchctl list` labels.

Tool caches are usually the larger number and the easier win — an Xcode
`iOS DeviceSupport` or an `~/.npm` can be several GB each, and pruning them
loses nothing. Do those first, before proposing any deletion.

### 2. Confirm with the user

Group the scanner's output by safety tier and present largest-first:

| Tier | Directories | Handling |
|------|-------------|----------|
| Safe | Caches, Logs, Saved Application State, HTTPStorages, WebKit | Batch-approve is fine |
| Inspect | Application Support, Containers, Group Containers, `~/.config`, home dotdirs | `ls` each one, report contents, approve individually |
| Never | anything `com.apple.*`, `/System` | Excluded by the scanner; do not override |

For anything in the Inspect tier, name the app and what the data looks like
("`~/Library/Application Support/Postgres` — 4 database clusters, 2.1 GB") so
the user can make a real decision.

### 3. Remove

Run the prune commands from the TOOL CACHES section first — they are safe and
well-defined. A few the scanner does not surface, worth checking by hand:

```sh
go clean -modcache            # module sources, not just build cache
docker system prune -a        # ask first: removes unused images and volumes
xcrun simctl delete unavailable
```

Then move approved stale directories to the Trash, largest first.

### 4. Verify

Re-run the scanner, and report space reclaimed:

```sh
df -h / | awk 'NR==2 {print $4" available"}'
du -sh ~/Library/Application\ Support ~/Library/Caches ~/Library/Containers 2>/dev/null
```

State the actual number reclaimed. If a removal failed (permissions, SIP,
file in use), say which one and why rather than reporting a clean sweep.

## Notes

- Some entries are shared: `~/Library/Group Containers/group.com.foo` may back
  several apps, one of which is still installed. Check the whole group prefix.
- Preferences plists are tiny. Removing them is cosmetic, not space recovery —
  only worth it when the user wants a clean slate for a reinstall.
- Cache directories regenerate. If the user's goal is recurring space, the answer
  is usually a large cache with a native prune command, not deletion.
