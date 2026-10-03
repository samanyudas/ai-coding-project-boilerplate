#!/usr/bin/env bash
# Warns when files in a module changed but its ARCHITECTURE.md or CONSTRAINTS.md did not.
# A reminder, not a gate: it always exits 0.
# Usage: check-module-docs.sh <git diff args>, e.g. `--cached` or `<base> HEAD`.
set -euo pipefail
cd "$(dirname "$0")/.."

changed="$(git diff --name-only "$@")"
[[ -z "$changed" ]] && exit 0

{ git ls-files | grep -E '(^|/)(ARCHITECTURE|CONSTRAINTS)\.md$' || true; } | while IFS= read -r doc; do
  dir="$(dirname "$doc")"
  [[ "$dir" == "." ]] && continue
  grep -qxF "$doc" <<<"$changed" && continue
  if grep -q "^$dir/" <<<"$changed"; then
    message="$dir/ changed but $doc did not. Check whether it still holds."
    if [[ -n "${GITHUB_ACTIONS:-}" ]]; then
      echo "::warning file=$doc::$message"
    else
      echo "module docs: $message" >&2
    fi
  fi
done
