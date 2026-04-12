#!/usr/bin/env bash
set -euo pipefail

# SWAT OpenClaw Integration Uninstaller
# Usage: curl -fsSL https://raw.githubusercontent.com/LangSensei/swat-openclaw/main/uninstall.sh | bash

SWAT_HOME="$HOME/.swat"
PLUGIN_DIR="$SWAT_HOME/plugin"

info()  { echo -e "\033[0;36m[swat-openclaw]\033[0m $*"; }
ok()    { echo -e "\033[0;32m[swat-openclaw]\033[0m $*"; }
warn()  { echo -e "\033[0;33m[swat-openclaw]\033[0m $*"; }

echo ""
echo "  SWAT OpenClaw Uninstaller"
echo "  ========================="
echo ""

if [[ "${1:-}" != "--yes" ]]; then
    warn "This will remove:"
    echo "  - Plugin:  $PLUGIN_DIR/"
    echo "  - Skill:   OpenClaw skills/swat/"
    echo "  - Config:  swat-mcp-bridge entry from openclaw.json"
    echo ""
    read -r -p "Continue? [y/N] " confirm
    if [[ "$confirm" != [yY] ]]; then
        info "Aborted."
        exit 0
    fi
fi

# --- Remove plugin ---

if [[ -d "$PLUGIN_DIR" ]]; then
    rm -rf "$PLUGIN_DIR"
    ok "Removed $PLUGIN_DIR"
else
    info "Plugin not found (skipped)"
fi

# --- Remove skill ---

for dir in "$HOME/.npm-global/lib/node_modules/openclaw/skills" "/usr/local/lib/node_modules/openclaw/skills" "/usr/lib/node_modules/openclaw/skills"; do
    if [[ -d "$dir/swat" ]]; then
        rm -rf "$dir/swat"
        ok "Removed skill from $dir/swat/"
        break
    fi
done

# --- Clean OpenClaw config ---

OPENCLAW_CONFIG="$HOME/.openclaw/openclaw.json"
if [[ -f "$OPENCLAW_CONFIG" ]] && command -v node &>/dev/null; then
    node -e "
        const fs = require('fs');
        const cfg = JSON.parse(fs.readFileSync('$OPENCLAW_CONFIG', 'utf8'));
        let changed = false;
        if (cfg.plugins?.load?.paths) {
            const before = cfg.plugins.load.paths.length;
            cfg.plugins.load.paths = cfg.plugins.load.paths.filter(p => !p.includes('.swat/plugin'));
            if (cfg.plugins.load.paths.length < before) changed = true;
            if (cfg.plugins.load.paths.length === 0) delete cfg.plugins.load.paths;
        }
        if (cfg.plugins?.entries?.['swat-mcp-bridge']) {
            delete cfg.plugins.entries['swat-mcp-bridge'];
            changed = true;
        }
        if (changed) {
            fs.writeFileSync('$OPENCLAW_CONFIG', JSON.stringify(cfg, null, 2) + '\n');
        }
    " 2>/dev/null && ok "Cleaned OpenClaw config" || true
fi

echo ""
ok "SWAT OpenClaw integration removed."
info "Restart OpenClaw: openclaw gateway restart"
echo ""
