# Overnight agent swarm (iPad as remote control)

An iPad can't run OpenCode, Ollama or VS Code itself. Run everything on an always-on
Mac/Linux machine (your computer, a mini PC, or a rented server) and use the iPad to reach it.

Step-by-step iPad guide: [IPAD.md](IPAD.md).

## One-time setup (on the host)
1. `./setup/install.sh` (installs OpenCode, Ollama, Tailscale, VS Code, Obsidian).
2. `sudo apt install tmux` (or `brew install tmux`).
3. Linux only, for a hard no-internet guarantee: `sudo swarm/lockdown-linux.sh`.
   Workers then run as user `swarm`, which can only reach localhost.

## From the iPad
- Install Tailscale and sign in to the same account.
- Use an SSH app (Blink Shell, Termius, or Prompt) to connect to the host's Tailscale name.
- Optional browser UI: `opencode web --hostname 0.0.0.0` on the host, open `http://<host>:4096`.

## Start a night run
    echo "Add tests for module X" > tasks.txt
    echo "Fix lint errors in Y"  >> tasks.txt
    swarm/run.sh ~/work/myrepo tasks.txt     # snapshots first, then one worker per line
    tmux attach -t swarm-HHMMSS              # watch; detach with Ctrl-b d

## Undo
    swarm/restore.sh            # latest snapshot (current state kept as *.broken-*)
    swarm/restore.sh <id>       # ls ~/.swarm-snapshots to pick one

## What is enforced
| Rule | How |
|---|---|
| No spending | Only the local Ollama model is configured; no API keys exist for workers |
| No contact with outsiders | OpenCode denies curl/ssh/gh/mail/webfetch; on Linux, firewall blocks all non-localhost traffic for user `swarm` |
| No pushing | `git push` denied in OpenCode permissions; work stays on local `swarm/*` branches |
| Undo | `snapshot.sh` runs before every run |

Caveats: the permission patterns are a speed bump, not a sandbox. Only the Linux lockdown is a
hard network block. A 7B local model is weak, so expect modest results and review the
`swarm/*` branches in the morning.
