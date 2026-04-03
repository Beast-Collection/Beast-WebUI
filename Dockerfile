FROM python:3.11-slim

# System deps for hermes-agent
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential git curl nodejs npm ripgrep ffmpeg && \
    rm -rf /var/lib/apt/lists/*

# Install uv
RUN curl -LsSf https://astral.sh/uv/install.sh | sh
ENV PATH="/root/.local/bin:${PATH}"

WORKDIR /app

# Clone and install hermes-agent (the WebUI wraps this)
RUN git clone --depth 1 https://github.com/NousResearch/hermes-agent.git /app/hermes-agent
RUN cd /app/hermes-agent && uv sync --no-dev

# Copy WebUI source
COPY . /app/webui/

# Persistent data volume for config, skills, memories, sessions
VOLUME ["/data"]

# Environment
ENV HERMES_HOME=/data
ENV HERMES_WEBUI_AGENT_DIR=/app/hermes-agent
ENV HERMES_WEBUI_HOST=0.0.0.0
ENV HERMES_WEBUI_PORT=8787
ENV HERMES_CONFIG_PATH=/data/config.yaml
ENV HERMES_WEBUI_STATE_DIR=/data/webui-state

EXPOSE 8787

# Launch WebUI using hermes-agent's venv (has all deps)
CMD ["/app/hermes-agent/.venv/bin/python", "/app/webui/server.py"]
