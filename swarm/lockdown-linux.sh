#!/usr/bin/env bash
# Linux, run once as root. Creates user 'swarm' that can only talk to localhost
# (so the local Ollama works, but nothing can reach the internet or other people).
set -euo pipefail
id swarm >/dev/null 2>&1 || useradd -m -s /bin/bash swarm
UID_S="$(id -u swarm)"
nft add table inet swarm 2>/dev/null || true
nft flush table inet swarm
nft add chain inet swarm out '{ type filter hook output priority 0; }'
nft add rule inet swarm out meta skuid "$UID_S" oif lo accept
nft add rule inet swarm out meta skuid "$UID_S" drop
mkdir -p /srv/swarm/work && chown -R swarm: /srv/swarm
install -d -o swarm -g swarm /home/swarm/.config/opencode
cp "$(dirname "$0")/../setup/opencode.json" /home/swarm/.config/opencode/opencode.json
chown swarm: /home/swarm/.config/opencode/opencode.json
echo "Done. Put repos in /srv/swarm/work and run: SWARM_USER=swarm WORKSPACE=/srv/swarm/work swarm/run.sh <repo> <tasks>"
