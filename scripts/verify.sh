#!/usr/bin/env bash
# The single verification command. Exits non-zero when any check fails.
set -euo pipefail
shopt -s nullglob
cd "$(dirname "$0")/.."

# Limits. Raise one only after trying to split the file it guards.
AGENTS_MAX_LINES=100
DOC_MAX_LINES=150
HARD_CONSTRAINTS_MAX=15

TODO_MARKER="TODO(project)"

section() {
  awk -v heading="## $1" '/^## /{inside = ($0 == heading); next} inside' AGENTS.md
}

# Every backticked path before the " - " on each repo map line.
map_paths() {
  section "Repo map" | grep '^- `' | sed -E 's/ - .*//' | grep -oE '`[^`]+`' | tr -d '`'
}

module_docs() {
  git ls-files --cached --others --exclude-standard |
    grep -E '(^|/)(ARCHITECTURE|CONSTRAINTS)\.md$' || true
}

check_repo_map() {
  local ok=0 path entry doc
  local paths
  paths="$(map_paths)"

  while IFS= read -r path; do
    if [[ ! -e "${path%/}" ]]; then
      echo "repo map: AGENTS.md lists '$path', which does not exist" >&2
      ok=1
    fi
  done <<<"$paths"

  for entry in * docs/*; do
    if ! grep -qE "^${entry}(/|$)" <<<"$paths"; then
      echo "repo map: '$entry' is missing from the repo map in AGENTS.md" >&2
      ok=1
    fi
  done

  while IFS= read -r doc; do
    if [[ -n "$doc" ]] && ! grep -qxF "$doc" <<<"$paths"; then
      echo "repo map: module doc '$doc' is missing from the repo map in AGENTS.md" >&2
      ok=1
    fi
  done <<<"$(module_docs)"

  return "$ok"
}

check_max_lines() {
  local file="$1" max="$2" lines
  lines="$(wc -l <"$file" | tr -d ' ')"
  if ((lines > max)); then
    echo "$file: $lines lines, limit is $max. Split it by topic and link the parts from the repo map." >&2
    return 1
  fi
}

check_doc_sizes() {
  local ok=0 doc
  check_max_lines AGENTS.md "$AGENTS_MAX_LINES" || ok=1
  while IFS= read -r doc; do
    if [[ -n "$doc" ]]; then
      check_max_lines "$doc" "$DOC_MAX_LINES" || ok=1
    fi
  done <<<"$(printf '%s\n' docs/*.md; module_docs)"
  return "$ok"
}

check_hard_constraints() {
  local count
  count="$(section "Hard constraints" | grep -cE '^[0-9]+\. ' || true)"
  if ((count > HARD_CONSTRAINTS_MAX)); then
    echo "AGENTS.md: $count hard constraints, limit is $HARD_CONSTRAINTS_MAX. Move topic or module rules to their docs, and tool-checkable ones into checks." >&2
    return 1
  fi
}

# A started project (harness/ deleted) must answer every slot, so a fresh session finds no gaps.
check_todo_slots() {
  [[ -d harness ]] && return 0
  local hits
  hits="$(git grep --untracked -nF "$TODO_MARKER:" || true)"
  if [[ -n "$hits" ]]; then
    echo "$hits" >&2
    echo "unfilled $TODO_MARKER slots above. Fill each one, or write why it does not apply yet." >&2
    return 1
  fi
}

run_project_checks() {
  # TODO(project): Add the format, lint, type-check, test, and build commands listed in AGENTS.md.
  :
}

echo "==> repo map"
check_repo_map
echo "==> doc sizes"
check_doc_sizes
echo "==> hard constraints"
check_hard_constraints
echo "==> project slots"
check_todo_slots
echo "==> project checks"
run_project_checks
echo "verify: all checks passed"
