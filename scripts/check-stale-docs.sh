#!/usr/bin/env bash
# Warns when a change leaves docs behind:
# - a module's files changed but its ARCHITECTURE.md or CONSTRAINTS.md did not;
# - in a started project (no harness/), PROGRESS.md was not updated.
# A reminder, not a gate: it always exits 0.
# Usage: check-stale-docs.sh <git diff args>, e.g. `--cached` or `<base> HEAD`.
set -euo pipefail
cd "$(dirname "$0")/.."

changed="$(git diff --name-only "$@")"
[[ -z "$changed" ]] && exit 0

warn() {
  if [[ -n "${GITHUB_ACTIONS:-}" ]]; then
    echo "::warning file=$1::$2"
  else
    echo "stale docs: $2" >&2
  fi
}

{ git ls-files | grep -E '(^|/)(ARCHITECTURE|CONSTRAINTS)\.md$' || true; } | while IFS= read -r doc; do
  dir="$(dirname "$doc")"
  [[ "$dir" == "." ]] && continue
  grep -qxF "$doc" <<<"$changed" && continue
  if grep -q "^$dir/" <<<"$changed"; then
    warn "$doc" "$dir/ changed but $doc did not. Check whether it still holds."
  fi
done

if [[ ! -d harness ]] && ! grep -qxF PROGRESS.md <<<"$changed"; then
  warn PROGRESS.md "PROGRESS.md was not updated. Record what this unit of work finished and what comes next."
fi
