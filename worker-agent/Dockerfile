FROM node:20-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
      git curl jq ca-certificates cron gnupg dirmngr \
    && curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg -o /usr/share/keyrings/githubcli-archive-keyring.gpg \
    && chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" > /etc/apt/sources.list.d/github-cli.list \
    && gpg --keyserver keyserver.ubuntu.com --recv-key 95C0FAF38DB3CCAD0C080A7BDC78B2DDEABC47B7 \
    && gpg --armor --export 95C0FAF38DB3CCAD0C080A7BDC78B2DDEABC47B7 > /etc/apt/trusted.gpg.d/cran_debian_key.asc \
    && echo "deb http://cloud.r-project.org/bin/linux/debian bookworm-cran46/" > /etc/apt/sources.list.d/cran.list \
    && apt-get update && apt-get install -y --no-install-recommends \
      gh r-base build-essential cmake libabsl-dev pkg-config \
      libcurl4-openssl-dev libssl-dev \
      libgdal-dev libgeos-dev libproj-dev libudunits2-dev libxml2-dev \
      libuv1 libgit2-1.5 libssh2-1 \
    && rm -rf /var/lib/apt/lists/*

# app's own dependency stack (sf, mapgl, echarts4r, rsconnect, ...),
# restored from the app's lockfile so deployApp() can actually bundle it
COPY renv.lock /tmp/renv.lock
RUN Rscript -e "options(repos = c(CRAN = 'https://packagemanager.posit.co/cran/__linux__/bookworm/latest'), Ncpus = parallel::detectCores()); install.packages('renv'); renv::consent(provided = TRUE); renv::restore(lockfile = '/tmp/renv.lock')"

# httr isn't in the lockfile (the app itself only uses httr2) but
# deploy/deploy.R and cleanup.R need it directly
RUN Rscript -e "options(repos = c(CRAN = 'https://packagemanager.posit.co/cran/__linux__/bookworm/latest')); install.packages('httr'); stopifnot('httr' %in% rownames(installed.packages()))"

RUN npm install -g @anthropic-ai/claude-code

# claude refuses --dangerously-skip-permissions when run as root, so the
# worker itself must run as an unprivileged user (cron daemon stays root)
RUN useradd -m -s /bin/bash agent \
    && su agent -c "git config --global user.email 'worker-agent@local' && git config --global user.name 'worker-agent'" \
    && touch /var/log/agent-runner.log && chown agent:agent /var/log/agent-runner.log

WORKDIR /app
COPY worker-agent/scripts/ scripts/
COPY worker-agent/entrypoint.sh .
COPY worker-agent/deploy/ deploy/
RUN chmod +x scripts/*.sh scripts/lib/*.sh entrypoint.sh \
    && chown -R agent:agent /app

ENV WORKDIR=/work
RUN mkdir -p /work && chown agent:agent /work

ENTRYPOINT ["/app/entrypoint.sh"]
