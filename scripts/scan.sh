#!/usr/bin/env bash
# The weekly full-system scan: a Markdown report of drift and accumulated debt that no single
# commit check sees. .github/workflows/maintenance.yml posts it as the weekly cleanup issue;
# docs/cleanup.md says how to work through it. Read-only; always exits 0.
set -uo pipefail
cd "$(dirname "$0")/.."
source scripts/lib/limits.sh
shopt -s nullglob

echo "# Weekly cleanup report"
echo
echo "Scanned \`$(git rev-parse --short HEAD)\` on $(date -u +%Y-%m-%d). Work through it with the weekly checklist in \`docs/cleanup.md\`."

echo
echo "## Verification"
echo
if scripts/verify.sh >/dev/null 2>&1; then
  echo "Every level passes."
else
  jq -r '"Fails at level \(.failed_level) in \(.failed_checks | join(", ")). Fix this first."' .harness/runs/latest/summary.json
fi

echo
echo "## Size pressure"
echo
echo "Files at 80% of their limit or more; split them before they reach it."
echo
pressure() { # <file> <lines> <limit>
  (($2 * 100 >= $3 * 80)) && echo "- \`$1\`: $2 of $3 lines"
}
found=false
pressure AGENTS.md "$(wc -l <AGENTS.md | tr -d ' ')" "$AGENTS_MAX_LINES" && found=true
for doc in docs/*.md $(git ls-files | grep -E '(^|/)(ARCHITECTURE|CONSTRAINTS)\.md$'); do
  pressure "$doc" "$(wc -l <"$doc" | tr -d ' ')" "$DOC_MAX_LINES" && found=true
done
constraints="$(awk '/^## /{inside = ($0 == "## Hard constraints"); next} inside' AGENTS.md | grep -cE '^[0-9]+\. ')"
pressure "AGENTS.md hard constraints" "$constraints" "$HARD_CONSTRAINTS_MAX" && found=true
$found || echo "- None."

echo
echo "## Debt markers"
echo
markers="$(git grep -nwE '(TODO|FIXME|HACK|XXX)' -- ':!*.md' ':!scripts/scan.sh' | grep -vF 'TODO(project)' | cut -d: -f1 | sort | uniq -c | sort -rn | head -10 || true)"
if [[ -n "$markers" ]]; then
  echo "Files with the most TODO, FIXME, HACK, or XXX markers; fix each or turn it into a \`not_started\` feature:"
  echo
  awk '{printf "- `%s`: %s\n", $2, $1}' <<<"$markers"
else
  echo "- None."
fi

echo
echo "## Features"
echo
jq -r '
  (.features | map(select(.state == "blocked"))) as $blocked
  | (.features | map(select(.state == "active"))) as $active
  | "- \(.features | length) features: \(.features | map(select(.state == "passing")) | length) passing, \($active | length) active, \($blocked | length) blocked.",
    ($active[] | "- Active: `\(.id)`, \(.title)."),
    ($blocked[] | "- Blocked: `\(.id)`, by \(.blocked_by). Is that still true?")
' docs/features.json

echo
echo "## Review warnings this week"
echo
base="$(git rev-list -1 --before="1 week ago" HEAD)"
if [[ -n "$base" ]]; then
  warnings="$(scripts/review-change.sh "$base" HEAD 2>&1)"
  if [[ -n "$warnings" ]]; then sed 's/^review: /- /' <<<"$warnings"; else echo "- None."; fi
else
  echo "- The history is younger than a week; nothing to compare yet."
fi

echo
echo "## Benchmarks"
echo
run_benchmarks() {
  # TODO(project): Run the benchmarks, compare them with the recorded baseline, and print each regression beyond tolerance, or "No drift.".
  echo "- None configured yet."
}
run_benchmarks
