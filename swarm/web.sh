#!/usr/bin/env bash
# Browser UI for OpenCode (local Ollama model) that the iPad opens in Safari over Tailscale.
# Runs on the host (T450). Binds to localhost only; tailscale serve exposes it to your tailnet only.
set -euo pipefail
PORT="${PORT:-4096}"
command -v opencode >/dev/null || { echo "opencode not installed; run setup/install.sh"; exit 1; }
command -v tailscale >/dev/null || { echo "tailscale not installed"; exit 1; }
# Optional password if your OpenCode version supports it.
export OPENCODE_SERVER_PASSWORD="${OPENCODE_SERVER_PASSWORD:-}"
sudo tailscale serve --bg "$PORT"
tailscale serve status
echo "On the iPad (Tailscale on), open the https://<host>.<tailnet>.ts.net address shown above in Safari."
echo "Stop sharing: sudo tailscale serve reset"
exec opencode web --hostname 127.0.0.1 --port "$PORT"
