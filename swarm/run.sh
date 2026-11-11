#!/usr/bin/env bash
# Snapshot, then start one OpenCode worker per task, each in its own git worktree, inside tmux.
# Usage: run.sh REPO_DIR TASKS_FILE   (TASKS_FILE: one task per line)
# Optional: SWARM_USER=swarm  runs workers as that user (use with lockdown-linux.sh)
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
REPO="$(cd "${1:?repo dir}" && pwd)"; TASKS="${2:?tasks file}"
WS="${WORKSPACE:-$(dirname "$REPO")}"
RUN="${SWARM_USER:+sudo -u $SWARM_USER}"
"$HERE/snapshot.sh" "$WS"
SESSION="swarm-$(date +%H%M%S)"; n=0
tmux new-session -d -s "$SESSION" -n control
while IFS= read -r task; do
  [ -z "$task" ] && continue; n=$((n+1))
  WT="$REPO-wt-$n"
  $RUN git -C "$REPO" worktree add -q -b "swarm/$SESSION-$n" "$WT"
  cp "$HERE/AGENTS.md" "$WT/AGENTS.md"
  tmux new-window -t "$SESSION" -n "w$n" \
    "cd '$WT' && $RUN opencode run $(printf '%q' "$task") ; echo finished; read"
done < "$TASKS"
echo "Started $n workers. From the iPad: ssh in, then: tmux attach -t $SESSION"
