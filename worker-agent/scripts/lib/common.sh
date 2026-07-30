#!/usr/bin/env bash
set -euo pipefail

# cron strips container env, so entrypoint.sh dumps it here at startup
[ -f /app/.env.runtime ] && source /app/.env.runtime

: "${REPO:?REPO env var required (owner/name)}"
: "${GH_TOKEN:?GH_TOKEN env var required}"
: "${ANTHROPIC_API_KEY:?ANTHROPIC_API_KEY env var required}"

LABEL_READY="${LABEL_READY:-agent-ready}"
LABEL_IN_PROGRESS="${LABEL_IN_PROGRESS:-agent-in-progress}"
LABEL_DONE="${LABEL_DONE:-agent-done}"
LABEL_FAILED="${LABEL_FAILED:-agent-failed}"
WORKDIR="${WORKDIR:-/work}"

export GH_TOKEN REPO LABEL_READY LABEL_IN_PROGRESS LABEL_DONE LABEL_FAILED WORKDIR

# gh CLI commands (clone, issue, pr) pick up GH_TOKEN automatically, but
# plain `git push`/`git fetch` over https don't — wire the credential
# helper so those authenticate too. Idempotent, cheap to redo each run.
gh auth setup-git >/dev/null 2>&1 || true

log() { echo "[$(date -u +%FT%TZ)] $*"; }
