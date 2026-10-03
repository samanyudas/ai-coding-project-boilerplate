# Run evidence for the harness scripts, sourced by scripts/verify.sh and scripts/feature.sh.
# Each run gets a directory under .harness/runs/ (git-ignored) holding its logs, so a failure
# can be diagnosed from what happened instead of guessed at.

RUNS_DIR=.harness/runs
RUNS_KEPT=30

# Creates a run directory for <kind>, prunes the oldest beyond RUNS_KEPT, and prints its path.
new_run_dir() {
  local dir d i dirs=()
  dir="$RUNS_DIR/$(date -u +%Y%m%dT%H%M%SZ)-$1-$$"
  mkdir -p "$dir"
  while IFS= read -r d; do dirs+=("$d"); done < <(find "$RUNS_DIR" -mindepth 1 -maxdepth 1 -type d | sort)
  for ((i = 0; i < ${#dirs[@]} - RUNS_KEPT; i++)); do rm -rf "${dirs[i]}"; done
  echo "$dir"
}
