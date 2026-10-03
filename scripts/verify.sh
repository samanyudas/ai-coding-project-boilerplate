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

# Each DECISIONS.md entry needs a dated heading and all four fields, so its reasoning survives.
check_decisions() {
  awk '
    function finish() {
      if (title == "") return
      for (i = 1; i <= 4; i++) if (!(label[i] in seen)) {
        printf "DECISIONS.md: \"%s\" is missing **%s:**\n", title, label[i] > "/dev/stderr"; bad = 1
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

# docs/features.json: each feature well formed, WIP = 1, and every passing feature re-verified,
# because a past pass does not prove it still works.
check_features() {
  local started problems id cmd log ok=0
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
echo "==> decisions"
check_decisions
echo "==> features"
check_features
echo "==> project slots"
check_todo_slots
echo "==> project checks"
run_project_checks
echo "verify: all checks passed"
