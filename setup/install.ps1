# Windows: installs VS Code, Obsidian, OpenCode, Ollama and copies the skills into a vault.
# Usage: powershell -ExecutionPolicy Bypass -File setup\install.ps1 [-Vault C:\path\Vault]
param([string]$Vault = "$HOME\ObsidianVault")
$Repo = Split-Path -Parent $PSScriptRoot
winget install -e --id Microsoft.VisualStudioCode
winget install -e --id Obsidian.Obsidian
winget install -e --id Ollama.Ollama
winget install -e --id Tailscale.Tailscale
# Tailscale SSH server is not available on Windows, so enable OpenSSH Server (reachable over the tailnet)
Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
Set-Service sshd -StartupType Automatic; Start-Service sshd
tailscale up
npm install -g opencode-ai
ollama pull qwen2.5-coder:7b
New-Item -ItemType Directory -Force "$HOME\.config\opencode", "$Vault\.claude\skills", "$HOME\.opencode\skills" | Out-Null
if (-not (Test-Path "$HOME\.config\opencode\opencode.json")) { Copy-Item "$Repo\setup\opencode.json" "$HOME\.config\opencode\opencode.json" }
Copy-Item "$Repo\skills\*" "$Vault\.claude\skills" -Recurse -Force
Copy-Item "$Repo\skills\*" "$HOME\.opencode\skills" -Recurse -Force
Write-Host "Done. Open $Vault in Obsidian and VS Code, then run 'opencode' inside it."
