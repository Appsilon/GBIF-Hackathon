FROM node:20-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
      git curl jq ca-certificates cron gnupg \
    && curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg -o /usr/share/keyrings/githubcli-archive-keyring.gpg \
    && chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" > /etc/apt/sources.list.d/github-cli.list \
    && apt-get update && apt-get install -y --no-install-recommends gh \
    && rm -rf /var/lib/apt/lists/*

RUN npm install -g @anthropic-ai/claude-code

# claude refuses --dangerously-skip-permissions when run as root, so the
# worker itself must run as an unprivileged user (cron daemon stays root)
RUN useradd -m -s /bin/bash agent \
    && su agent -c "git config --global user.email 'worker-agent@local' && git config --global user.name 'worker-agent'" \
    && touch /var/log/agent-runner.log && chown agent:agent /var/log/agent-runner.log

WORKDIR /app
COPY scripts/ scripts/
COPY entrypoint.sh .
RUN chmod +x scripts/*.sh scripts/lib/*.sh entrypoint.sh \
    && chown -R agent:agent /app

ENV WORKDIR=/work
RUN mkdir -p /work && chown agent:agent /work

ENTRYPOINT ["/app/entrypoint.sh"]
