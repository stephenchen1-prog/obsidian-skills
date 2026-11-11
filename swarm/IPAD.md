# Using the swarm from an iPad

The iPad is only the remote control. OpenCode, Ollama and VS Code have no iPad versions,
so an always-on Mac or Linux "host" does the work and you reach it over Tailscale + SSH.

> Not tested on a real iPad or host yet. Only `snapshot.sh` and `restore.sh` have been run.

## Host: the ThinkPad T450
The T450 is the host. It is an old CPU-only laptop, so a 7B model will be very slow there.
Check RAM (`free -h`) and prefer a small model (about 3B or less, e.g. `ollama pull qwen2.5-coder:3b`),
then point the model name in `setup/opencode.json` at it. Run one or two workers, not many.
If it runs Linux, step 5 below (lockdown) applies. If it runs Windows, use `setup/install.ps1`
and note that `swarm/*.sh` need WSL or Git Bash, so Linux is the better choice for this.
Tell me which OS it runs and I'll tune the scripts.

## 1. Host (once, on the Mac/Linux machine)
1. `./setup/install.sh` (installs and logs in to Tailscale with `--ssh`).
2. Install tmux: `brew install tmux` or `sudo apt install tmux`.
3. Keep the host awake and plugged in. Mac: System Settings > Battery/Energy, or run
   `caffeinate -dimsu &`. Linux (T450): disable suspend, and set `HandleLidSwitch=ignore` in `/etc/systemd/logind.conf` so closing the lid doesn't sleep it.
4. Mac only: turn on System Settings > General > Sharing > Remote Login. Tailscale SSH
   may not be available in every Mac Tailscale build; normal SSH over the Tailscale IP works.
5. Linux, recommended: `sudo swarm/lockdown-linux.sh` (the only hard no-internet guarantee).
6. Note the host's Tailscale name: `tailscale status`.

## 2. iPad (once)
1. Install **Tailscale** from the App Store and sign in to the same account as the host.
2. Install an SSH app: **Blink Shell**, **Termius** or **Prompt**.
3. Add a host: the Tailscale name (or 100.x.y.z address), your host username, port 22.
   If Tailscale SSH is enabled, no key is needed; otherwise add your key or password.
4. Keep the Tailscale VPN toggle on while connected.

## 3. Start the night run
    ssh <you>@<host>
    cd ~/obsidian-skills
    printf 'Add tests for module X\nFix lint errors in Y\n' > tasks.txt
    swarm/run.sh ~/work/myrepo tasks.txt

`run.sh` snapshots first, then starts one worker per line, each in its own git worktree and
`swarm/*` branch inside a tmux session. Close the iPad; workers keep running on the host.

## 4. Check in (from the iPad)
    tmux ls                       # find swarm-HHMMSS
    tmux attach -t swarm-HHMMSS   # watch; detach with Ctrl-b d
Each worker writes `REPORT.md` and, if stuck, `NEEDS_HUMAN.md` in its worktree.
iPad-friendly OpenCode (local model): on the T450 run `swarm/web.sh`, then open the
`https://<host>.<tailnet>.ts.net` address it prints in Safari on the iPad. It is the same OpenCode,
using the local Ollama model, served only to your tailnet (it listens on localhost; no public exposure).
Stop sharing with `sudo tailscale serve reset`.

## 5. Morning review
    cd ~/work/myrepo && git branch --list 'swarm/*'
    git diff main...swarm/<branch>
Nothing is pushed. Merge what you like. To undo everything: `swarm/restore.sh`
(your current state is kept aside as `*.broken-*`, not deleted).

## Troubleshooting
- Can't connect: check Tailscale is on in both devices and `tailscale status` shows the host online.
- Host asleep: wake it, then re-attach; tmux sessions survive iPad disconnects but not reboots.
- Weak results are expected from a 7B local model; read each `REPORT.md` before merging.
