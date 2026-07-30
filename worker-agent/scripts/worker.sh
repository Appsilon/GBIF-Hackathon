#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"
source lib/common.sh

number="${1:?usage: worker.sh <issue-number>}"

issue_json=$(gh issue view "$number" --repo "$REPO" --json title,body)
title=$(echo "$issue_json" | jq -r '.title')
body=$(echo "$issue_json" | jq -r '.body')

# issue.yml renders each form field as a "### <label>" heading in the body
acceptance_criteria=$(printf '%s\n' "$body" | awk '
  /^### Acceptance criteria/ { capture=1; next }
  /^### / { capture=0 }
  capture { print }
' | sed -e '/^[[:space:]]*$/d')
: "${acceptance_criteria:=(none specified in the issue)}"

clone_dir="$WORKDIR/issue-$number"
branch="agent/issue-$number"

log "issue #$number: cloning into $clone_dir"
rm -rf "$clone_dir"
gh repo clone "$REPO" "$clone_dir" -- --quiet
cd "$clone_dir"
git checkout -b "$branch"
start_sha=$(git rev-parse HEAD)

delimiter="===ACCEPTANCE-CRITERIA==="

prompt=$(cat <<EOF
Resolve GitHub issue #$number in this repository.

Title: $title

$body

Make the necessary code changes and commit them yourself. Do not push
or open a pull request yourself — that is handled separately.

Write your own commit message, in full — don't leave it to a fallback.
Follow normal git conventions: a short imperative subject line, a blank
line, then a body explaining what changed and why if it's not obvious
from the subject alone. End the commit message with a trailer on its
own line: "Co-Authored-By: Claude <noreply@anthropic.com>".

This issue's acceptance criteria are:

$acceptance_criteria

Once your change is committed, go through that list yourself and verify
each criterion against what you actually did. Don't just check every
box — if something isn't satisfied, leave it unchecked and say why.

Your entire final reply must be ONLY these two parts, in this exact
format, with nothing before, between, or after them:

<a few plain sentences: what changed and why, for a PR "Change description">
$delimiter
<the acceptance criteria list, one line per item, each as "- [x] <criterion text>" if satisfied or "- [ ] <criterion text> — <short reason not met>" otherwise. Preserve the original criterion text as given above. Don't add or remove criteria.>
EOF
)

log "issue #$number: running claude"
summary=$(claude -p "$prompt" \
  --dangerously-skip-permissions \
  ${CLAUDE_MODEL:+--model "$CLAUDE_MODEL"})
echo "$summary"

description="${summary%%"$delimiter"*}"
criteria_report="${summary#*"$delimiter"}"

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

log "issue #$number: deploying preview to Connect"
deploy_output=$(Rscript /app/deploy/deploy.R "$branch" 2>&1)
echo "$deploy_output"
deploy_url=$(printf '%s\n' "$deploy_output" | sed -n 's/^DEPLOY_URL=//p' | tail -1)
if [ -z "$deploy_url" ]; then
  log "issue #$number: deploy failed, no URL produced"
  exit 1
fi

template=".github/PULL_REQUEST_TEMPLATE.md"
if [ -f "$template" ]; then
  pr_body=$(sed "s/^Closes\$/Closes #$number/" "$template")
  pr_body="${pr_body/"## Change description"/## Change description

$description}"
  pr_body="${pr_body/"## Acceptance criteria"/## Acceptance criteria

$criteria_report}"
  pr_body="${pr_body/"## Deployment link"/## Deployment link

$deploy_url}"
else
  pr_body="Closes #$number

## Change description

$description

## Acceptance criteria

$criteria_report

## Deployment link

$deploy_url"
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
