#!/usr/bin/env bash
# The only way a feature's state changes in docs/features.json.
# Usage:
#   feature.sh list                  every feature with its state
#   feature.sh start <id>            make a not_started or blocked feature active (WIP = 1)
#   feature.sh verify <id>           levels 0-2 of scripts/verify.sh, then its end-to-end flow;
#                                    only a pass marks it passing, with evidence
#   feature.sh block <id> <reason>   mark it blocked, with what it waits on
#   feature.sh remaining             a loop's stop condition: exits 0 once every feature is passing or blocked
set -euo pipefail
cd "$(dirname "$0")/.."

FEATURES=docs/features.json
source scripts/lib/runs.sh

die() {
  echo "feature: $*" >&2
  exit 1
}

field() {
  jq -r --arg id "$1" ".features[] | select(.id == \$id) | .$2 // empty" "$FEATURES"
}

# Applies a jq update to one feature, keeping the file's permissions.
update() {
  local id="$1" expr="$2" tmp
  shift 2
  tmp="$(mktemp)"
  jq --arg id "$id" "$@" "(.features[] | select(.id == \$id)) |= ($expr)" "$FEATURES" >"$tmp"
  cat "$tmp" >"$FEATURES"
  rm "$tmp"
}

require() {
  [[ -n "${1:-}" ]] || die "missing feature id. Run 'scripts/feature.sh list' to see them."
  [[ -n "$(field "$1" id)" ]] || die "no feature '$1' in $FEATURES"
}

cmd_list() {
  jq -r '
    if (.features | length) == 0 then "No features yet."
    else .features[] | "\(.state)\t\(.id)\t\(.title)" + (if .state == "blocked" then "  (blocked by: \(.blocked_by))" else "" end)
    end
  ' "$FEATURES"
}

cmd_start() {
  local id="$1" state active
  require "$id"
  state="$(field "$id" state)"
  [[ "$state" == "not_started" || "$state" == "blocked" ]] || die "'$id' is $state; only a not_started or blocked feature can start."
  active="$(jq -r '.features[] | select(.state == "active") | .id' "$FEATURES")"
  [[ -z "$active" ]] || die "'$active' is already active, and WIP = 1 allows one. Verify it or block it first."
  update "$id" '.state = "active" | .blocked_by = null'
  echo "feature: '$id' is active. Its behavior: $(field "$id" behavior)"
}

cmd_verify() {
  local id="$1" state cmd log summary dirty
  require "$id"
  state="$(field "$id" state)"
  [[ "$state" == "active" || "$state" == "passing" ]] || die "'$id' is $state; start it before verifying it."
  cmd="$(field "$id" verify)"
  echo "feature: levels 0 to 2 must pass before '$id' runs its end-to-end flow"
  scripts/verify.sh --upto 2 || die "levels 0 to 2 failed, so '$id' stays $state. Fix them first."
  log="$(new_run_dir "feature-$id")/flow.log"
  echo "feature: verifying '$id' end to end with: $cmd"
  if ! bash -c "$cmd" >"$log" 2>&1; then
    tail -40 "$log"
    die "'$id' failed its verification and stays $state. Full log: $log. Diagnose the cause from it before retrying, or block the feature."
  fi
  summary="$(sed -e "s/$(printf '\033')\[[0-9;]*m//g" -e '/^[[:space:]]*$/d' "$log" | tail -1 | cut -c1-200)"
  if [[ -n "$(git status --porcelain)" ]]; then dirty=true; else dirty=false; fi
  update "$id" '.state = "passing" | .blocked_by = null | .evidence = {
      result: "passed", command: $cmd, summary: $summary, verified_at: $at,
      commit: $commit, uncommitted_changes: $dirty }' \
    --arg cmd "$cmd" --arg summary "$summary" --arg at "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
    --arg commit "$(git rev-parse --short HEAD)" --argjson dirty "$dirty"
  echo "feature: '$id' is passing. Commit it, with its code and tests, as one unit."
}

cmd_block() {
  local id="$1" reason="${2:-}"
  require "$id"
  [[ -n "$reason" ]] || die "say what '$id' waits on: scripts/feature.sh block $id \"<reason>\""
  update "$id" '.state = "blocked" | .blocked_by = $reason' --arg reason "$reason"
  echo "feature: '$id' is blocked by: $reason"
}

# The machine-checkable stop condition for a goal loop over the feature list.
cmd_remaining() {
  local total open blocked
  total="$(jq '.features | length' "$FEATURES")"
  ((total > 0)) || { echo "feature: no features yet, so there is no goal to reach. Write them first."; return 1; }
  open="$(jq -r '.features[] | select(.state == "not_started" or .state == "active") | "\(.state)\t\(.id)\t\(.title)"' "$FEATURES")"
  blocked="$(jq -r '[.features[] | select(.state == "blocked")] | length' "$FEATURES")"
  if [[ -n "$open" ]]; then
    echo "feature: $(wc -l <<<"$open" | tr -d ' ') of $total features remain; next is the first:"
    echo "$open"
    return 1
  fi
  echo "feature: goal reached: every feature is passing$( ((blocked > 0)) && echo " or blocked; $blocked blocked need a human")."
}

case "${1:-}" in
  list) cmd_list ;;
  start) cmd_start "${2:-}" ;;
  verify) cmd_verify "${2:-}" ;;
  block) cmd_block "${2:-}" "${3:-}" ;;
  remaining) cmd_remaining ;;
  *) sed -n '2,9p' "$0" | sed 's/^# \{0,1\}//' >&2; exit 2 ;;
esac
