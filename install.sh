#!/usr/bin/env bash
set -euo pipefail

# SWAT OpenClaw Integration Installer
# Usage: curl -fsSL https://raw.githubusercontent.com/LangSensei/swat-openclaw/main/install.sh | bash

REPO="LangSensei/swat-openclaw"
SWAT_HOME="$HOME/.swat"
PLUGIN_DIR="$SWAT_HOME/plugin"

info()  { echo -e "\033[0;36m[swat-openclaw]\033[0m $*"; }
ok()    { echo -e "\033[0;32m[swat-openclaw]\033[0m $*"; }
err()   { echo -e "\033[0;31m[swat-openclaw]\033[0m $*" >&2; }
die()   { err "$@"; exit 1; }

# --- Prerequisites ---

check_prereqs() {
    local missing=()
    command -v node >/dev/null 2>&1 || missing+=("node")
    command -v npm  >/dev/null 2>&1 || missing+=("npm")

    if [[ ${#missing[@]} -gt 0 ]]; then
        die "Missing prerequisites: ${missing[*]}"
    fi

    if ! command -v swat >/dev/null 2>&1; then
        err "SWAT binary not found. Install swat first:"
        echo "  curl -fsSL https://raw.githubusercontent.com/LangSensei/swat/main/install.sh | bash"
        exit 1
    fi

    if ! command -v openclaw >/dev/null 2>&1; then
        info "Warning: OpenClaw not found. Plugin will be installed but not activated."
    fi
}

# --- Download ---

download_release() {
    local tmp_dir
    tmp_dir=$(mktemp -d)

    info "Downloading latest release..."

    if command -v curl >/dev/null 2>&1; then
        curl -fsSL "https://github.com/$REPO/archive/refs/heads/main.tar.gz" | tar -xz -C "$tmp_dir" --strip-components=1
    else
        wget -qO- "https://github.com/$REPO/archive/refs/heads/main.tar.gz" | tar -xz -C "$tmp_dir" --strip-components=1
    fi

    EXTRACT_DIR="$tmp_dir"
}

# --- Install Plugin ---

install_plugin() {
    rm -rf "$PLUGIN_DIR"
    mkdir -p "$PLUGIN_DIR"
    cp "$EXTRACT_DIR/plugin/"* "$PLUGIN_DIR/"

    info "Installing plugin dependencies..."
    cd "$PLUGIN_DIR" && npm install --quiet 2>/dev/null
    ok "Plugin installed to $PLUGIN_DIR"
}

# --- Install Skill ---

install_skill() {
    local oc_skills=""
    for dir in "$HOME/.npm-global/lib/node_modules/openclaw/skills" "/usr/local/lib/node_modules/openclaw/skills" "/usr/lib/node_modules/openclaw/skills"; do
        if [[ -d "$dir" ]]; then
            oc_skills="$dir"
            break
        fi
    done

    if [[ -z "$oc_skills" ]]; then
        info "OpenClaw skills directory not found. Manually copy skill/SKILL.md to your OpenClaw skills dir."
        return
    fi

    mkdir -p "$oc_skills/swat"
    cp "$EXTRACT_DIR/skill/SKILL.md" "$oc_skills/swat/"
    ok "Skill installed to $oc_skills/swat/"
}

# --- Register in OpenClaw Config ---

register_plugin() {
    local oc_config="$HOME/.openclaw/openclaw.json"
    local plugin_path
    plugin_path=$(cd "$PLUGIN_DIR" && pwd)
    plugin_path="${plugin_path//\\/\/}"

    if [[ ! -f "$oc_config" ]]; then
        info "OpenClaw config not found at $oc_config"
        info "After installing OpenClaw, add to your config:"
        echo ""
        echo "  plugins.load.paths: [\"$plugin_path\"]"
        echo "  plugins.entries.swat-mcp-bridge.enabled: true"
        echo ""
        return
    fi

    # Detect swat binary path
    local bin_path
    bin_path=$(command -v swat)

    if node -e "
        const fs = require('fs');
        const cfg = JSON.parse(fs.readFileSync('$oc_config', 'utf8'));
        cfg.plugins = cfg.plugins || {};
        cfg.plugins.load = cfg.plugins.load || {};
        cfg.plugins.load.paths = cfg.plugins.load.paths || [];
        cfg.plugins.entries = cfg.plugins.entries || {};
        if (!cfg.plugins.load.paths.includes('$plugin_path')) {
            cfg.plugins.load.paths.push('$plugin_path');
        }
        cfg.plugins.entries['swat-mcp-bridge'] = {
            enabled: true,
            config: { binaryPath: '$bin_path', runtime: 'copilot' }
        };
        fs.writeFileSync('$oc_config', JSON.stringify(cfg, null, 2) + '\n');
    " 2>/dev/null; then
        ok "Plugin registered in OpenClaw config"
        info "Restart OpenClaw to activate: openclaw gateway restart"
    else
        err "Failed to auto-register. Manually add to $oc_config"
    fi
}

# --- Cleanup ---

cleanup() {
    rm -rf "$EXTRACT_DIR"
}

# --- Main ---

main() {
    echo ""
    info "Installing SWAT OpenClaw integration..."
    echo ""

    check_prereqs
    download_release
    install_plugin
    install_skill
    register_plugin
    cleanup

    echo ""
    ok "SWAT OpenClaw integration installed! 🚀"
    echo ""
    info "Configuration:"
    echo "  Runtime is set to 'copilot' (default)."
    echo "  To change, edit ~/.openclaw/openclaw.json:"
    echo "    plugins.entries.swat-mcp-bridge.config.runtime = \"copilot\" | \"gemini\""
    echo ""
    info "Next: openclaw gateway restart"
    echo ""
}

main "$@"
