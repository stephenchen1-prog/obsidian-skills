#!/usr/bin/env bash
# Installs VS Code, Obsidian, OpenCode and Ollama (local model = no paid tokens),
# then wires the skills in this repo into an Obsidian vault.
# Usage: ./setup/install.sh [VAULT_DIR]   (macOS or Linux)
set -euo pipefail
REPO="$(cd "$(dirname "$0")/.." && pwd)"
VAULT="${1:-$HOME/ObsidianVault}"
OS="$(uname -s)"

have() { command -v "$1" >/dev/null 2>&1; }

if [ "$OS" = "Darwin" ]; then
  have brew || { echo "Install Homebrew first: https://brew.sh"; exit 1; }
  brew install --cask visual-studio-code obsidian
  brew install ollama opencode tailscale
  sudo brew services start tailscale
elif [ "$OS" = "Linux" ]; then
  if have snap; then
    sudo snap install code --classic
    sudo snap install obsidian --classic
  else
    echo "No snap found: install VS Code (code.visualstudio.com) and Obsidian (obsidian.md) manually."
  fi
  have ollama || curl -fsSL https://ollama.com/install.sh | sh
  have tailscale || curl -fsSL https://tailscale.com/install.sh | sh
  have opencode || { have npm && npm install -g opencode-ai || curl -fsSL https://opencode.ai/install | bash; }
else
  echo "Unsupported OS: $OS (use setup/install.ps1 on Windows)"; exit 1
fi

# Local model for OpenCode
(have ollama && ollama pull qwen2.5-coder:7b) || echo "Start Ollama, then run: ollama pull qwen2.5-coder:7b"
mkdir -p "$HOME/.config/opencode"
[ -f "$HOME/.config/opencode/opencode.json" ] || cp "$REPO/setup/opencode.json" "$HOME/.config/opencode/opencode.json"

# Vault + skills for Claude Code and OpenCode
mkdir -p "$VAULT/.claude/skills" "$HOME/.opencode/skills"
cp -R "$REPO/skills/." "$VAULT/.claude/skills/"
cp -R "$REPO/skills/." "$HOME/.opencode/skills/"

# Tailscale login + Tailscale SSH (opens a login URL; approve it in your browser)
sudo tailscale up --ssh
# Optional: share a local web UI over your tailnet, e.g. TS_SERVE_PORT=3040 ./setup/install.sh
[ -n "${TS_SERVE_PORT:-}" ] && sudo tailscale serve --bg "$TS_SERVE_PORT"

echo "Done. Open $VAULT in Obsidian and VS Code, then run 'opencode' inside it."
