#!/usr/bin/env bash
set -e  # stop on first error

API_KEY="${1:-}"

if [ -z "$API_KEY" ]; then
  echo "ERROR: pass your API key as the first argument."
  echo 'Example: curl -fsSL .../setup.sh | bash -s -- "sk-your-key"'
  exit 1
fi

echo "==> [1/5] Updating system packages..."
sudo apt-get update -y
sudo DEBIAN_FRONTEND=noninteractive apt-get -o Dpkg::Options::="--force-confold" upgrade -y
sudo apt-get install -y git curl

echo "==> [2/5] Installing Node.js via nvm..."
if [ ! -d "$HOME/.nvm" ]; then
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
fi
export NVM_DIR="$HOME/.nvm"
# shellcheck disable=SC1091
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
nvm install --lts
nvm use --lts

echo "==> [3/5] Installing Claude Code..."
npm install -g @anthropic-ai/claude-code

echo "==> [4/5] Writing Claude Code settings..."
mkdir -p "$HOME/.claude"
# Pull the settings template from the same repo and inject the key.
TEMPLATE_URL="https://raw.githubusercontent.com/iamarturr/vibe-setup/main/settings.template.json"
curl -fsSL "$TEMPLATE_URL" -o /tmp/settings.template.json
# Replace the placeholder with the real key.
sed "s|__API_KEY__|$API_KEY|g" /tmp/settings.template.json > "$HOME/.claude/settings.json"
rm -f /tmp/settings.template.json

echo "==> [5/5] Creating projects folder..."
mkdir -p "$HOME/projects"

echo ""
echo "============================================================"
echo " DONE. Open a new shell (or run: source ~/.bashrc) then:"
echo "   cd ~/projects && claude"
echo "============================================================"
