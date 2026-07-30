#!/usr/bin/env bash
set -euo pipefail

: "${POLL_CRON:=*/5 * * * *}"

# cron jobs don't inherit the container's env, so snapshot it here once
# and have scripts/lib/common.sh source it back in
env | grep -E '^(GH_TOKEN|ANTHROPIC_API_KEY|REPO|LABEL_READY|LABEL_IN_PROGRESS|LABEL_DONE|LABEL_FAILED|CLAUDE_MODEL|WORKDIR)=' \
  | sed 's/^/export /' > /app/.env.runtime
chmod 644 /app/.env.runtime

# cron strips PATH down to /usr/bin:/bin by default, which misses
# /usr/local/bin (npm global installs, incl. claude) — set it explicitly.
# runs as "agent", not root: claude refuses --dangerously-skip-permissions
# as root, and /etc/cron.d entries require an explicit user field.
{
  echo "PATH=$PATH"
  echo "$POLL_CRON agent /app/scripts/dispatch.sh >> /var/log/agent-runner.log 2>&1"
  echo ""
} > /etc/cron.d/agent-runner
chmod 0644 /etc/cron.d/agent-runner

# agent (non-root) can't write to root-owned /proc/1/fd/1, so the cron job
# logs to a file instead; stream that file to our own stdout for `docker logs`
tail -F /var/log/agent-runner.log &

echo "worker-agent starting, schedule: $POLL_CRON, repo: ${REPO:-unset}"
cron -f
