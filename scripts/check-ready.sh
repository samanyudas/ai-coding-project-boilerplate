#!/usr/bin/env bash
# Cheap readiness check for the start of a session: is the environment still the
# one scripts/setup.sh built? Fast and offline; scripts/restore-state.sh runs it.
# Exits non-zero, saying what to run, when the environment is not ready.
# Usage: check-ready.sh            check readiness
#        check-ready.sh --record   record the current environment (setup.sh calls this)
set -euo pipefail
cd "$(dirname "$0")/.."

# Files that define the environment. When one changes, setup must run again.
# TODO(project): Add the lockfiles and runtime pin, e.g. `package-lock.json .nvmrc` or `uv.lock .python-version`.
ENV_FILES=(scripts/setup.sh)

STAMP="$(git rev-parse --git-path setup-stamp)"

env_fingerprint() {
  local f
  for f in "${ENV_FILES[@]}"; do
    if [[ -e "$f" ]]; then echo "$f $(git hash-object "$f")"; else echo "$f missing"; fi
  done | git hash-object --stdin
}

check_runtime() {
  # TODO(project): Confirm the runtime matches its pin, e.g. `[[ "$(node --version)" == "v$(cat .nvmrc)" ]]`.
  :
}

if [[ "${1:-}" == "--record" ]]; then
  env_fingerprint >"$STAMP"
  exit 0
fi

problems=()
[[ "$(git config core.hooksPath || true)" == ".githooks" ]] || problems+=("git hooks are not enabled")
if [[ ! -f "$STAMP" ]]; then
  problems+=("setup has not run in this checkout")
elif [[ "$(cat "$STAMP")" != "$(env_fingerprint)" ]]; then
  problems+=("the environment changed since setup last ran (${ENV_FILES[*]})")
fi
check_runtime || problems+=("the runtime does not match its pinned version")

if ((${#problems[@]} > 0)); then
  printf 'not ready: %s\n' "${problems[@]}"
  echo "Run scripts/setup.sh, then this check again."
  exit 1
fi
echo "ready: environment matches the last setup"
