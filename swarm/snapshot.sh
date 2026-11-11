#!/usr/bin/env bash
# Snapshot the workspace to a tarball so a bad overnight run can be undone.
# Usage: snapshot.sh [WORKSPACE]   (default: $WORKSPACE or ~/work)
set -euo pipefail
WS="${1:-${WORKSPACE:-$HOME/work}}"
DEST="${SNAPSHOT_DIR:-$HOME/.swarm-snapshots}"
TS="$(date +%Y%m%d-%H%M%S)"
mkdir -p "$DEST"
tar --exclude=node_modules --exclude=.venv -czf "$DEST/$TS.tar.gz" -C "$(dirname "$WS")" "$(basename "$WS")"
echo "$TS" > "$DEST/LATEST"
echo "Snapshot: $DEST/$TS.tar.gz"
