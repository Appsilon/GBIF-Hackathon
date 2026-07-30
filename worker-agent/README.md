# worker-agent

Polls a repo's issues on a cron schedule and dispatches Claude Code to
work each one, opening a PR when done.

## How it fits together

```
entrypoint.sh          installs POLL_CRON as a cron job, runs cron in foreground
  -> scripts/dispatch.sh   runs on each tick
       -> scripts/poll.sh      lists open issues labeled $LABEL_READY
       -> scripts/worker.sh    per issue: clone, run claude, push branch, open PR
       -> scripts/lib/common.sh   shared config/env/logging, sourced by all of the above
```

State lives entirely in GitHub labels — no database:

- `agent-ready` — issue is queued for an agent (add this manually, or
  via another automation, to opt an issue in)
- `agent-in-progress` — claimed by a worker
- `agent-done` — PR opened successfully
- `agent-failed` — worker errored or produced no changes

## Setup

```
cp .env.example .env
# fill in GH_TOKEN (repo + PR scope), ANTHROPIC_API_KEY, REPO
docker compose up -d --build
```

`gh issue edit --add-label agent-ready` on an issue to hand it to the agent.

## Security note

`worker.sh` runs `claude -p ... --dangerously-skip-permissions`, i.e.
fully autonomous, no per-edit approval. Only let trusted repo members
apply `agent-ready` — the issue title/body becomes the agent's prompt
verbatim, so an untrusted author could otherwise inject instructions.

## Extending

Each piece is a standalone script, callable directly for local testing
(`source .env && ./scripts/dispatch.sh`) without Docker:

- swap the state backend by editing `dispatch.sh`'s claim/label calls
- change what the agent is told to do by editing the prompt in `worker.sh`
- run workers concurrently by backgrounding the loop body in `dispatch.sh`
  and adding a `wait`
- change cadence via `POLL_CRON` in `.env`, no rebuild needed if it's
  read at container start
