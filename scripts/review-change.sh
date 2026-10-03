#!/usr/bin/env bash
# Automated review of a change: what a reviewer would flag that is not worth blocking a commit.
# Blocking checks belong in scripts/verify.sh; a review issue raised twice becomes one of these, or a gate.
# - a module's files changed but its ARCHITECTURE.md or CONSTRAINTS.md did not;
# - in a started project (no harness/), neither docs/features.json nor PROGRESS.md was updated;
# - the change spans two or more components in docs/architecture.json, but no integration or end-to-end test changed;
# - the contract (behavior or verify) of a feature that was passing changed: a frozen target only a human may move.
# A reminder, not a gate: it always exits 0.
# Usage: review-change.sh <git diff args>, e.g. `--cached` or `<base> HEAD`.
set -euo pipefail
cd "$(dirname "$0")/.."

changed="$(git diff --name-only "$@")"
[[ -z "$changed" ]] && exit 0

warn() {
  if [[ -n "${GITHUB_ACTIONS:-}" ]]; then
    echo "::warning file=$1::$2"
  else
    echo "review: $2" >&2
  fi
}

touches() {
  grep -q "^${1%/}/" <<<"$changed"
}

{ git ls-files | grep -E '(^|/)(ARCHITECTURE|CONSTRAINTS)\.md$' || true; } | while IFS= read -r doc; do
  dir="$(dirname "$doc")"
  [[ "$dir" == "." ]] && continue
  grep -qxF "$doc" <<<"$changed" && continue
  if touches "$dir"; then
    warn "$doc" "$dir/ changed but $doc did not. Check whether it still holds."
  fi
done

if [[ ! -d harness ]] && ! grep -qxE 'PROGRESS\.md|docs/features\.json' <<<"$changed"; then
  warn PROGRESS.md "Neither docs/features.json nor PROGRESS.md changed. Record what this unit finished and how far the active feature got."
fi

# The revisions of docs/features.json being compared, for the --cached and <base> <head> forms.
old_spec="" new_spec=""
if [[ "$#" -eq 1 && "$1" == "--cached" ]]; then
  old_spec="HEAD:docs/features.json" new_spec=":docs/features.json"
elif [[ "$#" -eq 2 ]]; then
  old_spec="$1:docs/features.json" new_spec="$2:docs/features.json"
fi
if [[ -n "$old_spec" ]] && grep -qxF docs/features.json <<<"$changed"; then
  moved="$(jq -rn --argjson a "$(git show "$old_spec" 2>/dev/null || echo '{"features":[]}')" \
    --argjson b "$(git show "$new_spec" 2>/dev/null || echo '{"features":[]}')" '
    $a.features[] | select(.state == "passing") | . as $o
    | ([$b.features[] | select(.id == $o.id)] | first) as $n
    | if $n == null then "\($o.id) (removed)"
      elif $n.behavior != $o.behavior or $n.verify != $o.verify then $o.id
      else empty end' | paste -sd, - | sed 's/,/, /g')"
  if [[ -n "$moved" ]]; then
    warn docs/features.json "The contract of passing feature(s) $moved changed. A weaker behavior or verify makes the metric rise while the real outcome gets worse (Goodhart), so this target is frozen: get the approval of the human who owns it, and call it out in the pull request."
  fi
fi

touched=()
while IFS=$'\t' read -r name path; do
  [[ -n "$name" ]] && touches "$path" && touched+=("$name")
done < <(jq -r '.components[] | [.name, .path] | @tsv' docs/architecture.json)
if ((${#touched[@]} >= 2)); then
  covered=false
  while IFS= read -r tests; do
    [[ -n "$tests" ]] && touches "$tests" && covered=true
  done < <(jq -r '.integration_tests[]' docs/architecture.json)
  if [[ "$covered" == false ]]; then
    warn docs/architecture.json "This change spans components ${touched[*]}, and no integration or end-to-end test changed. Unit tests cannot see what breaks between components (interfaces, state, permissions, environment). Add or extend a test in $(jq -r '.integration_tests | join(", ") | if . == "" then "an integration test path (none declared in docs/architecture.json)" else . end' docs/architecture.json) that crosses them, or confirm an existing feature flow does."
  fi
fi
