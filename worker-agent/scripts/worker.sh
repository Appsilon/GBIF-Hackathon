#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"
source lib/common.sh

number="${1:?usage: worker.sh <issue-number>}"

issue_json=$(gh issue view "$number" --repo "$REPO" --json title,body)
title=$(echo "$issue_json" | jq -r '.title')
body=$(echo "$issue_json" | jq -r '.body')

clone_dir="$WORKDIR/issue-$number"
branch="agent/issue-$number"

log "issue #$number: cloning into $clone_dir"
rm -rf "$clone_dir"
gh repo clone "$REPO" "$clone_dir" -- --quiet
cd "$clone_dir"
git checkout -b "$branch"
start_sha=$(git rev-parse HEAD)

prompt=$(cat <<EOF
Resolve GitHub issue #$number in this repository.

Title: $title

$body

Make the necessary code changes and leave them staged/committed in the
working tree. Do not push or open a pull request yourself — that is
handled separately.

Your entire final reply must be ONLY the pull request "Change description"
text itself: a few plain sentences on what changed and why. No heading,
no preamble like "the change is committed", no commit hash, no restating
these instructions — just the description paragraph(s), since it gets
inserted directly under an existing "## Change description" heading.
EOF
)

log "issue #$number: running claude"
summary=$(claude -p "$prompt" \
  --dangerously-skip-permissions \
  ${CLAUDE_MODEL:+--model "$CLAUDE_MODEL"})
echo "$summary"

if [ -n "$(git status --porcelain)" ]; then
  git add -A
  git commit -m "fix: resolve #$number

Automated fix by worker-agent.

Closes #$number"
fi

if [ "$(git rev-parse HEAD)" = "$start_sha" ]; then
  log "issue #$number: no changes produced"
  exit 1
fi

# force: agent/issue-N is fully bot-owned and regenerated from a fresh
# clone each run, so a stale remote branch from a prior failed attempt
# is expected to be overwritten, not merged with
git push --force origin "$branch"

template=".github/PULL_REQUEST_TEMPLATE.md"
if [ -f "$template" ]; then
  pr_body=$(sed "s/^Closes\$/Closes #$number/" "$template")
  pr_body="${pr_body/"## Change description"/## Change description

$summary}"
  pr_body="${pr_body/"## Deployment link"/## Deployment link

N/A — automated fix, no deployment step}"
else
  pr_body="Closes #$number

## Change description

$summary"
fi

existing_pr_state=$(gh pr view "$branch" --repo "$REPO" --json state -q .state 2>/dev/null || echo "")
if [ "$existing_pr_state" = "OPEN" ]; then
  log "issue #$number: PR already open for $branch"
else
  gh pr create --repo "$REPO" \
    --head "$branch" \
    --title "Fix: $title (#$number)" \
    --body "$pr_body"
fi

log "issue #$number: PR opened"
