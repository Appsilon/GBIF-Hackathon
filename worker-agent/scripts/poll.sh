#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"
source lib/common.sh

# outputs the list of open issues awaiting an agent, as JSON
gh issue list \
  --repo "$REPO" \
  --label "$LABEL_READY" \
  --state open \
  --json number,title,body \
  --limit 100
