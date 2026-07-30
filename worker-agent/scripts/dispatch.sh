#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"
source lib/common.sh

issues=$(./poll.sh)
count=$(echo "$issues" | jq 'length')
log "found $count issue(s) labeled '$LABEL_READY'"

echo "$issues" | jq -c '.[]' | while read -r issue; do
  number=$(echo "$issue" | jq -r '.number')

  # relabel first, atomically claiming the issue so a later poll (or a
  # concurrent run) doesn't pick it up again while a worker is on it
  if ! gh issue edit "$number" --repo "$REPO" \
        --remove-label "$LABEL_READY" --add-label "$LABEL_IN_PROGRESS" 2>/dev/null; then
    log "issue #$number: failed to claim, skipping"
    continue
  fi

  log "issue #$number: claimed, dispatching worker"
  if ./worker.sh "$number"; then
    gh issue edit "$number" --repo "$REPO" \
      --remove-label "$LABEL_IN_PROGRESS" --add-label "$LABEL_DONE"
    log "issue #$number: done"
  else
    log "issue #$number: worker failed"
    gh issue edit "$number" --repo "$REPO" \
      --remove-label "$LABEL_IN_PROGRESS" --add-label "$LABEL_FAILED"
  fi
done
