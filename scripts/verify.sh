#!/usr/bin/env bash
# The single verification command. Exits non-zero when any check fails.
set -euo pipefail
cd "$(dirname "$0")/.."

map_paths() {
  awk '/^## /{in_map = ($0 == "## Repo map"); next} in_map && /^- `/' AGENTS.md |
    sed -E 's/^- `([^`]+)`.*/\1/'
}

check_repo_map() {
  local ok=0 path entry
  local paths
  paths="$(map_paths)"

  while IFS= read -r path; do
    if [[ ! -e "${path%/}" ]]; then
      echo "repo map: AGENTS.md lists '$path', which does not exist" >&2
      ok=1
    fi
  done <<<"$paths"

  for entry in *; do
    if ! grep -qE "^${entry}(/|$)" <<<"$paths"; then
      echo "repo map: '$entry' is missing from the repo map in AGENTS.md" >&2
      ok=1
    fi
  done

  return "$ok"
}

run_project_checks() {
  # TODO(project): Add the format, lint, type-check, and test commands listed in AGENTS.md.
  :
}

echo "==> repo map"
check_repo_map
echo "==> project checks"
run_project_checks
echo "verify: all checks passed"
