#!/usr/bin/env bash
# The single verification command: the Definition of Done, checked in levels.
#   0 harness            the repo's own rules: map, doc sizes, constraints, decisions, features,
#                        architecture file, slots, temporary debug code, graph paths
#   1 static             architecture rules, format, lint, type-check
#   2 tests and startup  unit and integration tests, and the project starts
#   3 end to end         every passing feature's end-to-end flow, re-run
# Levels run in order and stop at the first that fails, because a later level
# means nothing while an earlier one is broken.
# Every run leaves a log per check and a summary.json under .harness/runs/ (latest: .harness/runs/latest),
# and a failure prints the end of the failing check's log with the path to the rest.
# Usage: verify.sh [--upto <level>]   e.g. --upto 1 for a fast inner loop
set -euo pipefail
shopt -s nullglob
cd "$(dirname "$0")/.."

UPTO=3
if [[ "${1:-}" == "--upto" ]]; then
  [[ "${2:-}" =~ ^[0-3]$ ]] || { echo "verify: --upto takes a level from 0 to 3" >&2; exit 2; }
  UPTO="$2"
fi

source scripts/lib/runs.sh
RUN_DIR="$(new_run_dir verify)"
ln -sfn "$(basename "$RUN_DIR")" "$RUNS_DIR/latest"
printf 'level\tcheck\tstatus\tseconds\tlog\n' >"$RUN_DIR/checks.tsv"

source scripts/lib/limits.sh

TODO_MARKER="TODO(project)"
TEMP_MARKER="TEMP(debug)"

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
      echo "repo map: AGENTS.md lists '$path', which does not exist, so the map misleads every session. Fix the path or delete the line." >&2
      ok=1
    fi
  done <<<"$paths"

  for entry in * docs/*; do
    if ! grep -qE "^${entry}(/|$)" <<<"$paths"; then
      echo "repo map: '$entry' is missing from the repo map in AGENTS.md, and agents only find what the map lists. Add a line saying what it is and when to read it." >&2
      ok=1
    fi
  done

  while IFS= read -r doc; do
    if [[ -n "$doc" ]] && ! grep -qxF "$doc" <<<"$paths"; then
      echo "repo map: module doc '$doc' is missing from the repo map in AGENTS.md, so no agent will read it before changing that module. Add a line for it." >&2
      ok=1
    fi
  done <<<"$(module_docs)"

  return "$ok"
}

check_max_lines() {
  local file="$1" max="$2" lines
  lines="$(wc -l <"$file" | tr -d ' ')"
  if ((lines > max)); then
    echo "$file: $lines lines, limit is $max; past it, agents skim and miss rules. Split it by topic and link the parts from the repo map." >&2
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
    echo "AGENTS.md: $count hard constraints, limit is $HARD_CONSTRAINTS_MAX; past it, each one gets less attention. Move topic or module rules to their docs, and tool-checkable ones into checks." >&2
    return 1
  fi
}

# Each DECISIONS.md entry needs a dated heading and all four fields, so its reasoning survives.
check_decisions() {
  awk '
    function finish() {
      if (title == "") return
      for (i = 1; i <= 4; i++) if (!(label[i] in seen)) {
        printf "DECISIONS.md: \"%s\" is missing **%s:**, so a future session cannot tell why it holds. Add the field.\n", title, label[i] > "/dev/stderr"; bad = 1
      }
      delete seen
    }
    BEGIN { split("Decision Why Rejected Constraints", label, " ") }
    /^```/ { fenced = !fenced; next }
    fenced { next }
    /^## / {
      finish(); title = substr($0, 4)
      if ($0 !~ /^## [0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]: ./) {
        printf "DECISIONS.md: heading \"%s\" must read \"YYYY-MM-DD: Title\"\n", title > "/dev/stderr"; bad = 1
      }
      next
    }
    title != "" {
      for (i = 1; i <= 4; i++) if (index($0, "- **" label[i] ":**") == 1) seen[label[i]] = 1
    }
    END { finish(); exit bad }
  ' DECISIONS.md
}

# docs/features.json: each feature well formed, and WIP = 1.
check_features() {
  local started problems
  if [[ -d harness ]]; then started=false; else started=true; fi
  if ! problems="$(jq -r --argjson started "$started" '
    def bad(msg): "docs/features.json: \(msg)";
    .features as $f
    | if ($f | type) != "array" then bad("needs a \"features\" array") else
        ( $f[] | . as $x
          | ( if (.id | type) == "string" and (.id | test("^[a-z0-9][a-z0-9-]*$")) then empty
              else bad("feature id \(.id | tojson) must be a lowercase slug") end ),
            ( ("title", "behavior", "verify") as $k
              | if ($x[$k] | type) == "string" and $x[$k] != "" then empty else bad("\($x.id): missing \($k)") end ),
            ( if .state | IN("not_started", "active", "blocked", "passing") then empty
              else bad("\(.id): unknown state \(.state | tojson)") end ),
            ( if (.verify // "") | test("verify\\.sh") then bad("\(.id): verify must be a focused test, not scripts/verify.sh, which re-runs it") else empty end ),
            ( if .state == "blocked" and ((.blocked_by // "") == "") then bad("\(.id): blocked without blocked_by") else empty end ),
            ( if .state == "passing" and .evidence == null
              then bad("\(.id): passing without evidence; only scripts/feature.sh verify marks a feature passing") else empty end )
        ),
        ( [$f[].id] | group_by(.) | map(select(length > 1))[] | bad("duplicate id \(.[0])") ),
        ( [$f[] | select(.state == "active")] | length
          | if . > 1 then bad("\(.) features are active, and WIP = 1 allows one") else empty end ),
        ( if $started and ($f | length) == 0 then bad("no features yet; write them as docs/initialization.md describes") else empty end )
      end
  ' docs/features.json 2>&1)"; then
    echo "docs/features.json: not valid JSON: $problems" >&2
    return 1
  fi
  if [[ -n "$problems" ]]; then
    echo "$problems" >&2
    return 1
  fi
}

# A past pass does not prove a feature still works, so every passing feature's flow re-runs.
reverify_features() {
  local id cmd log ok=0
  log="$(mktemp)"
  while IFS=$'\t' read -r id cmd; do
    [[ -n "$id" ]] || continue
    echo "    re-verifying $id"
    if ! bash -c "$cmd" >"$log" 2>&1; then
      tail -20 "$log" >&2
      echo "docs/features.json: passing feature '$id' no longer passes: $cmd" >&2
      ok=1
    fi
  done < <(jq -r '.features[] | select(.state == "passing") | [.id, .verify] | @tsv' docs/features.json)
  rm "$log"
  return "$ok"
}

# docs/graph.md describes the process; every path it names must exist, so the graph cannot drift from the code silently.
check_graph() {
  local token path ok=0
  while IFS= read -r token; do
    path="${token%% *}"
    [[ "$path" =~ ^[A-Za-z0-9._-]+(/[A-Za-z0-9._-]+)+/?$ || "$path" =~ ^[A-Za-z0-9._-]+\.(md|json|sh|yml)$ ]] || continue
    [[ -e "${path%/}" ]] && continue
    git check-ignore -q "${path%/}" && continue # created at runtime, such as .harness/runs/
    echo "docs/graph.md names '$path', which does not exist, so the graph no longer matches the code. Fix the graph or the code." >&2
    ok=1
  done < <(grep -oE '`[^`]+`' docs/graph.md | tr -d '`' | sort -u)
  return "$ok"
}

# Temporary debug code is marked so it cannot be forgotten; none may reach a commit.
check_temp_markers() {
  local hits
  hits="$(git grep --untracked -nF "$TEMP_MARKER:" -- ':!*.md' || true)"
  if [[ -n "$hits" ]]; then
    echo "$hits" >&2
    echo "temporary debug code above is still marked $TEMP_MARKER, and committing it leaves debt for the next session. Remove it, or make it permanent and drop the marker." >&2
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

# docs/architecture.json: components, integration test paths, and rules that each say why and how to fix.
check_architecture_file() {
  local problems
  if ! problems="$(jq -r '
    def bad(msg): "docs/architecture.json: \(msg)";
    def str: type == "string" and . != "";
    if (.components | type) != "array" or (.integration_tests | type) != "array" or (.rules | type) != "array"
    then bad("needs \"components\", \"integration_tests\", and \"rules\" arrays") else
      ( .components[] | select((.name | str | not) or (.path | str | not)) | bad("component \(tojson) needs a name and a path") ),
      ( .integration_tests[] | select(str | not) | bad("integration test path \(tojson) must be a non-empty string") ),
      ( .rules[] | . as $r | ("name", "forbid", "why", "fix")
        | select($r[.] | str | not) | bad("rule \($r.name // "?" | tojson) needs \(.)") ),
      ( .rules[] | select((.files | type) != "array" or (.files | length) == 0) | bad("rule \(.name // "?" | tojson) needs a non-empty files array") )
    end
  ' docs/architecture.json 2>&1)"; then
    echo "docs/architecture.json: not valid JSON: $problems" >&2
    return 1
  fi
  [[ -z "$problems" ]] || { echo "$problems" >&2; return 1; }
  local path ok=0
  while IFS= read -r path; do
    [[ -z "$path" || -e "${path%/}" ]] && continue
    echo "docs/architecture.json: '$path' does not exist, so checks built on it see nothing. Fix the path or remove it." >&2
    ok=1
  done < <(jq -r '.components[].path, .integration_tests[]' docs/architecture.json)
  return "$ok"
}

# Each rule forbids a pattern in a set of files; a hit prints what broke, why, and how to fix it.
check_architecture() {
  local name forbid why fix files hits ok=0
  while IFS=$'\t' read -r name forbid why fix files; do
    [[ -n "$name" ]] || continue
    local -a specs=()
    while IFS= read -r glob; do specs+=(":(glob)$glob"); done < <(jq -r '.[]' <<<"$files")
    hits="$(git grep --untracked -nE -e "$forbid" -- "${specs[@]}" || true)"
    if [[ -n "$hits" ]]; then
      printf 'architecture: rule "%s" broken:\n%s\n  why: %s\n  fix: %s\n' "$name" "$hits" "$why" "$fix" >&2
      ok=1
    fi
  done < <(jq -r '.rules[] | [.name, .forbid, .why, .fix, (.files | tojson)] | @tsv' docs/architecture.json)
  return "$ok"
}

# Each project check runs under `set -e`, so the first failing command fails it.
run_static() {
  # TODO(project): The format check, lint, and type-check commands, one per line.
  :
}

run_tests() {
  # TODO(project): The unit and integration test commands.
  :
}

run_startup() {
  # TODO(project): Start the project, call its health check (docs/observability.md), and stop it.
  :
}

# Writes summary.json for this run: <result> [failed level] [failed checks].
finish_run() {
  jq -Rn --arg result "$1" --arg level "${2:-}" --arg failed "${3:-}" --argjson upto "$UPTO" \
    --arg at "$(date -u +%Y-%m-%dT%H:%M:%SZ)" --arg commit "$(git rev-parse --short HEAD)" '
    [inputs | split("\t")][1:] as $rows
    | { command: "scripts/verify.sh", upto: $upto, finished_at: $at, commit: $commit, result: $result,
        failed_level: (if $level == "" then null else ($level | tonumber) end),
        failed_checks: (if $failed == "" then [] else ($failed | split(" ")) end),
        checks: [$rows[] | {level: (.[0] | tonumber), check: .[1], status: .[2], seconds: (.[3] | tonumber), log: .[4]}] }
  ' <"$RUN_DIR/checks.tsv" >"$RUN_DIR/summary.json"
}

# Runs every check in a level, each in its own `set -e` subshell with its output in its own log,
# then stops if any failed, showing the end of each failing log.
run_level() {
  local n="$1" name="$2" check status log started failed=()
  shift 2
  ((n <= UPTO)) || return 0
  echo "==> level $n: $name"
  for check in "$@"; do
    log="$RUN_DIR/$check.log"
    started=$SECONDS
    set +e
    (set -e; "$check") >"$log" 2>&1
    status=$?
    set -e
    if ((status == 0)); then
      printf '%s\t%s\tpassed\t%s\t%s\n' "$n" "$check" "$((SECONDS - started))" "$log" >>"$RUN_DIR/checks.tsv"
    else
      printf '%s\t%s\tfailed\t%s\t%s\n' "$n" "$check" "$((SECONDS - started))" "$log" >>"$RUN_DIR/checks.tsv"
      failed+=("$check")
      echo "--- $check failed; the end of $log:" >&2
      tail -n 30 "$log" >&2
    fi
  done
  if ((${#failed[@]} > 0)); then
    finish_run failed "$n" "${failed[*]}"
    local skipped=""
    ((n < 3)) && skipped="; later levels did not run"
    echo "verify: level $n ($name) failed in ${failed[*]}. Fix what is reported above and re-run$skipped." >&2
    echo "verify: full logs and summary.json in $RUN_DIR" >&2
    exit 1
  fi
}

run_level 0 "harness" check_repo_map check_doc_sizes check_hard_constraints check_decisions check_features check_architecture_file check_todo_slots check_temp_markers check_graph
run_level 1 "static" check_architecture run_static
run_level 2 "tests and startup" run_tests run_startup
run_level 3 "end to end" reverify_features
finish_run passed
echo "verify: levels 0 to $UPTO passed (evidence in $RUN_DIR)"
