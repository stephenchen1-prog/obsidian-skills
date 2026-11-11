#!/usr/bin/env bash
# Undo: put the workspace back to a snapshot. The current state is kept as <workspace>.broken-<time>.
# Usage: restore.sh [SNAPSHOT_ID] [WORKSPACE]   (default: LATEST)
set -euo pipefail
DEST="${SNAPSHOT_DIR:-$HOME/.swarm-snapshots}"
ID="${1:-$(cat "$DEST/LATEST")}"
WS="${2:-${WORKSPACE:-$HOME/work}}"
[ -f "$DEST/$ID.tar.gz" ] || { echo "No snapshot $ID. Available:"; ls "$DEST"; exit 1; }
[ -d "$WS" ] && mv "$WS" "$WS.broken-$(date +%H%M%S)"
tar -xzf "$DEST/$ID.tar.gz" -C "$(dirname "$WS")"
echo "Restored $WS from $ID"
