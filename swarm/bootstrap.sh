#!/usr/bin/env bash
# One command to set up a Linux host (e.g. the T450). Picks a model that fits the RAM,
# installs everything, locks the network down, and starts the iPad web UI in tmux.
# Usage: git clone <repo> && cd obsidian-skills && git checkout claude/ipad-readme-commit-zi1vlu && swarm/bootstrap.sh
set -euo pipefail
cd "$(dirname "$0")/.."
[ "$(uname -s)" = "Linux" ] || { echo "Linux only (Mac: use setup/install.sh then swarm/web.sh)"; exit 1; }

RAM_MB=$(awk '/MemTotal/ {print int($2/1024)}' /proc/meminfo)
if   [ "$RAM_MB" -ge 14000 ]; then MODEL="qwen2.5-coder:7b"
elif [ "$RAM_MB" -ge 6000 ];  then MODEL="qwen2.5-coder:3b"
else                               MODEL="qwen2.5-coder:1.5b"; fi
echo "RAM ${RAM_MB} MB -> model $MODEL"

# Use the chosen model everywhere before install.sh pulls it and copies the config.
sed -i "s/qwen2.5-coder:7b/$MODEL/g; s/Qwen2.5 Coder 7B/Qwen2.5 Coder ($MODEL)/" setup/opencode.json
sed -i "s/qwen2.5-coder:7b/$MODEL/g" setup/install.sh
rm -f "$HOME/.config/opencode/opencode.json"

sudo apt-get update -y && sudo apt-get install -y tmux git curl
./setup/install.sh
sudo swarm/lockdown-linux.sh

tmux kill-session -t web 2>/dev/null || true
tmux new-session -d -s web "swarm/web.sh"
sleep 5
echo
echo "Done. Model: $MODEL"
echo "iPad: Tailscale on, open the https://...ts.net address below in Safari."
tailscale serve status || true
