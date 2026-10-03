#!/usr/bin/env bash
# The clean-handoff check: a session is not done until this passes.
# It removes the session's throwaway files, then checks that the next session inherits
# a ready environment, every verification level passing (build, tests, startup, flows),
# nothing uncommitted, and progress notes that cover the active feature.
# Exits non-zero, listing what to fix, when the handoff is not clean.
set -euo pipefail
cd "$(dirname "$0")/.."

problems=()

if [[ -d .harness/scratch ]]; then
  echo "end-session: removing $(find .harness/scratch -type f | wc -l | tr -d ' ') throwaway files in .harness/scratch/"
  rm -rf .harness/scratch
fi

scripts/check-ready.sh >/dev/null || problems+=("the environment is not ready: run scripts/check-ready.sh and follow it")

dirty="$(git status --porcelain)"
if [[ -n "$dirty" ]]; then
  problems+=("uncommitted changes would be inherited by the next session: commit each finished or verified-partial unit, or discard it
$dirty")
fi

active="$(jq -r '.features[] | select(.state == "active") | .id' docs/features.json)"
if [[ -n "$active" ]]; then
  notes="$(awk '/^## /{inside = ($0 == "## Active feature notes"); next} inside' PROGRESS.md)"
  grep -qF "$active" <<<"$notes" ||
    problems+=("'$active' is active, but the Active feature notes in PROGRESS.md do not mention it: write how far it got and what is left")
fi

echo "end-session: running every verification level"
scripts/verify.sh >/dev/null 2>&1 ||
  problems+=("scripts/verify.sh fails, so the next session would start broken: run it and fix what it reports")

if ((${#problems[@]} > 0)); then
  printf 'end-session: not clean:\n' >&2
  printf -- '- %s\n' "${problems[@]}" >&2
  exit 1
fi
echo "end-session: clean handoff. Next session starts from $(git rev-parse --short HEAD)$([[ -n "$active" ]] && echo ", continuing '$active'")."
