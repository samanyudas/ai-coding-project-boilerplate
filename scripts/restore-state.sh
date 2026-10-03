#!/usr/bin/env bash
# Prints the saved state a new or compacted session needs: the features, PROGRESS.md, the
# DECISIONS.md headings, the git checkpoint, the last verification result, and environment readiness.
# Read-only; safe to run anytime.
# Claude Code runs it at every session start, including after compaction.
set -euo pipefail
cd "$(dirname "$0")/.."

echo "# Restored state"
echo
echo "## Features (scripts/feature.sh list; the behavior and verification are in docs/features.json)"
echo
scripts/feature.sh list
echo
echo "## PROGRESS.md"
echo
cat PROGRESS.md
echo
echo "## DECISIONS.md headings (open the entries that bear on your task)"
echo
grep -E '^## [0-9]{4}-[0-9]{2}-[0-9]{2}: ' DECISIONS.md || echo "No decisions recorded yet."
echo
echo "## Git checkpoint"
echo
echo "Branch: $(git branch --show-current)"
git log --oneline -5
dirty="$(git status --short)"
if [[ -n "$dirty" ]]; then
  echo
  echo "Uncommitted changes, from this session or an interrupted one."
  echo "Finish and commit them as one unit, or discard them; do not build on them blindly:"
  echo "$dirty"
fi
echo
echo "## Last verification"
echo
summary=.harness/runs/latest/summary.json
if [[ -f "$summary" ]]; then
  jq -r '"\(.result) at \(.finished_at) on \(.commit), levels 0 to \(.upto)"
    + (if .result == "failed" then
        "\nFailed at level \(.failed_level) in \(.failed_checks | join(", ")). Read these logs before retrying:\n"
        + ([.checks[] | select(.status == "failed") | "  " + .log] | join("\n"))
      else "" end)' "$summary"
elif [[ -L .harness/runs/latest ]]; then
  echo "The last run did not finish (interrupted); its logs are in .harness/runs/latest/."
else
  echo "No verification has run in this checkout yet."
fi
echo
echo "## Environment"
echo
scripts/check-ready.sh || true
