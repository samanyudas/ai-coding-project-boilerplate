#!/usr/bin/env bash
# A Claude Code PreToolUse hook for Bash: blocks commands that bypass the harness or cannot be undone.
# A written rule can be argued with. This check runs on every command, silent on success and loud on failure.
# Blocks, in any simple command that starts with git or rm:
# - skipping the pre-commit hook (`--no-verify`, or overriding core.hooksPath);
# - a forced push, except `--force-with-lease` to a branch other than main or master;
# - a recursive delete of the filesystem root or the home directory.
# A guardrail against mistakes, not a security boundary: it splits on newlines, ;, &&, ||, and |,
# so text that only mentions a command (echo, a heredoc, a commit message) passes.
# Input: the hook's JSON on stdin. Exit 2 blocks the command and shows stderr to the agent.
# Usage: guard-command.sh < hook-input.json, or guard-command.sh --command '<command>' to test one.
set -euo pipefail

if [[ "${1:-}" == "--command" ]]; then
  cmd="${2:-}"
else
  cmd="$(jq -r '.tool_input.command // empty')"
fi

block() {
  echo "guard: blocked: $1" >&2
  echo "  why: $2" >&2
  echo "  fix: $3" >&2
  exit 2
}

check_git() {
  # Quoted text, such as a commit message, only mentions flags.
  local seg
  seg="$(sed -E "s/\"[^\"]*\"//g; s/'[^']*'//g" <<<"$1")"
  if [[ "$seg" =~ (^|[[:space:]])--no-verify([[:space:]]|$) || "$seg" =~ core\.hooksPath ]]; then
    block "the command skips the git hooks." \
      "Commits go through the pre-commit hook (hard constraint 3 in AGENTS.md), which runs scripts/verify.sh." \
      "Fix what scripts/verify.sh reports, then commit normally."
  fi
  [[ "$seg" =~ (^|[[:space:]])push([[:space:]]|$) ]] || return 0
  if [[ "$seg" =~ (^|[[:space:]])(-f|--force)([[:space:]]|$) || "$seg" =~ [[:space:]]\+[^[:space:]]+ ]]; then
    block "a forced push." \
      "A forced push rewrites shared history, and other agents and people lose work built on it." \
      "Push a new commit instead. To update your own feature branch after a rebase, use --force-with-lease."
  fi
  if [[ "$seg" =~ --force-with-lease && "$seg" =~ (^|[[:space:]:/])(main|master)([[:space:]]|$) ]]; then
    block "a forced push to main or master." \
      "Main reaches people only through a reviewed pull request (docs/graph.md)." \
      "Open a pull request with a new commit instead."
  fi
}

check_rm() {
  local seg="$1"
  if [[ "$seg" =~ ^rm[[:space:]]+(-[a-zA-Z]*[rR][a-zA-Z]*|--recursive)([[:space:]]+-[a-zA-Z-]+)*[[:space:]]+(\"?(/|~|\$HOME|\$\{HOME\})/?\*?\"?)([[:space:]]|$) ]]; then
    block "a recursive delete of / or the home directory." \
      "It cannot be undone, and no task here needs it." \
      "Delete the specific path you mean, inside the repo or .harness/scratch/."
  fi
}

# One simple command per line: split on newlines and the shell's list and pipe operators.
segments="$(printf '%s\n' "$cmd" | awk '{ gsub(/&&|\|\||;|\|/, "\n"); print }')"
prefix='^([A-Za-z_][A-Za-z0-9_]*=[^[:space:]]*|sudo|env|command|exec)[[:space:]]+'
while IFS= read -r seg; do
  # Strip leading spaces, environment assignments, and command prefixes such as sudo or env.
  seg="${seg#"${seg%%[![:space:]]*}"}"
  while [[ "$seg" =~ $prefix ]]; do seg="${seg:${#BASH_REMATCH[0]}}"; done
  case "$seg" in
    git | git[[:space:]]*) check_git "$seg" ;;
    rm[[:space:]]*) check_rm "$seg" ;;
  esac
done <<<"$segments"
exit 0
