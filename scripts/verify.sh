#!/usr/bin/env bash
# The single verification command. Exits non-zero when any check fails.
set -euo pipefail
shopt -s nullglob
cd "$(dirname "$0")/.."

AGENTS_MAX_LINES=100
TODO_MARKER="TODO(project)"

map_paths() {
  awk '/^## /{in_map = ($0 == "## Repo map"); next} in_map && /^- `/' AGENTS.md |
    sed -E 's/^- `([^`]+)`.*/\1/'
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

check_agents_length() {
  local lines
  lines="$(wc -l <AGENTS.md | tr -d ' ')"
  if ((lines > AGENTS_MAX_LINES)); then
    echo "AGENTS.md: $lines lines, limit is $AGENTS_MAX_LINES. Move detail into docs/ and point to it from the repo map." >&2
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
echo "==> AGENTS.md length"
check_agents_length
echo "==> project slots"
check_todo_slots
echo "==> project checks"
run_project_checks
echo "verify: all checks passed"
