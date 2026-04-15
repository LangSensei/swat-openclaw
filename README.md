# swat-openclaw

OpenClaw integration for [SWAT](https://github.com/LangSensei/swat) — MCP plugin bridge + skill definition.

## What's Inside

- **plugin/** — OpenClaw MCP bridge that exposes SWAT tools (dispatch, ops, cancel, squads, schedules, schedule_create, schedule_delete, browse, install, uninstall, update, notify) to OpenClaw agents
- **skill/** — OpenClaw skill definition (`SKILL.md`) that teaches agents how to use SWAT

## Prerequisites

- [SWAT](https://github.com/LangSensei/swat) installed (`swat` binary in PATH)
- [OpenClaw](https://github.com/openclaw/openclaw) running
- Node.js 18+

## Install

### Linux / macOS

```bash
curl -fsSL https://raw.githubusercontent.com/LangSensei/swat-openclaw/main/install.sh | bash
```

### Windows

```powershell
irm https://raw.githubusercontent.com/LangSensei/swat-openclaw/main/install.ps1 | iex
```

This will:
1. Download plugin and skill files
2. Install plugin dependencies (`npm install`)
3. Register the plugin in your OpenClaw config (`~/.openclaw/openclaw.json`)

Then restart OpenClaw:
```bash
openclaw gateway restart
```

## Uninstall

### Linux / macOS

```bash
curl -fsSL https://raw.githubusercontent.com/LangSensei/swat-openclaw/main/uninstall.sh | bash
```

### Windows

```powershell
irm https://raw.githubusercontent.com/LangSensei/swat-openclaw/main/uninstall.ps1 | iex
```

## Manual Setup

If you prefer manual installation:

```bash
git clone https://github.com/LangSensei/swat-openclaw.git
cd swat-openclaw/plugin && npm install
```

Then add to your OpenClaw config (`~/.openclaw/openclaw.json`):

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
          "binaryPath": "~/.local/bin/swat",
          "runtime": "copilot"
        }
      }
    }
  }
}
```

## Configuration

| Key | Default | Description |
|-----|---------|-------------|
| `binaryPath` | — | Path to the `swat` binary (required) |
| `runtime` | `copilot` | Agent runtime: `copilot`, `gemini` |

Notifications are hardcoded to `openclaw` (sent via Gateway API).

## Related Repos

- [swat](https://github.com/LangSensei/swat) — Commander engine (Go)
- [swat-marketplace](https://github.com/LangSensei/swat-marketplace) — Squads, skills, and MCPs
