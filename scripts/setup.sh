#!/usr/bin/env bash
# Takes a fresh clone to a working dev environment. Safe to re-run.
# Needed once per checkout, and again only when scripts/check-ready.sh reports the environment changed.
set -euo pipefail
cd "$(dirname "$0")/.."

git config core.hooksPath .githooks

# TODO(project): Install the pinned runtime and dependencies (e.g. `nvm install && npm ci`, `uv sync`).

scripts/check-ready.sh --record
echo "setup: done"
