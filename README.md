# swat-openclaw

OpenClaw integration for [SWAT](https://github.com/LangSensei/swat) — MCP plugin bridge + skill definition.

## What's Inside

- **plugin/** — OpenClaw MCP bridge that exposes SWAT tools (dispatch, list, cancel, squads, schedules, browse, install, uninstall) to OpenClaw agents
- **skill/** — OpenClaw skill definition (`SKILL.md`) that teaches agents how to use SWAT

## Prerequisites

- [SWAT](https://github.com/LangSensei/swat) installed (`swat` binary in PATH)
- [OpenClaw](https://github.com/openclaw/openclaw) running

## Install

```bash
# Clone
git clone https://github.com/LangSensei/swat-openclaw.git
cd swat-openclaw

# Install plugin dependencies
cd plugin && npm install && cd ..

# Register in OpenClaw config (~/.openclaw/openclaw.json):
# 1. Add plugin path to plugins.load.paths
# 2. Enable swat-mcp-bridge with binaryPath pointing to your swat binary
```

### OpenClaw Config Example

```json
{
  "plugins": {
    "load": {
      "paths": ["/path/to/swat-openclaw/plugin"]
    },
    "entries": {
      "swat-mcp-bridge": {
        "enabled": true,
        "config": {
          "binaryPath": "~/.local/bin/swat"
        }
      }
    }
  }
}
```

Then restart OpenClaw:
```bash
openclaw gateway restart
```

## Using SWAT without OpenClaw

If you just want SWAT with GitHub Copilot CLI, you don't need this repo. Install [swat](https://github.com/LangSensei/swat) standalone and configure `.mcp.json`:

```json
{
  "mcpServers": {
    "swat": {
      "command": "swat",
      "args": ["mcp"]
    }
  }
}
```

## Related Repos

- [swat](https://github.com/LangSensei/swat) — Commander engine (Go)
- [swat-marketplace](https://github.com/LangSensei/swat-marketplace) — Squads, skills, and MCPs
