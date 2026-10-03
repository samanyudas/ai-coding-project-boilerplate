#!/usr/bin/env bash
# Takes a fresh clone to a working dev environment. Safe to re-run.
set -euo pipefail
cd "$(dirname "$0")/.."

git config core.hooksPath .githooks

# TODO(project): Install the pinned runtime and dependencies (e.g. `nvm install && npm ci`, `uv sync`).

echo "setup: done"
