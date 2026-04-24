# swat-openclaw

OpenClaw integration for [SWAT](https://github.com/LangSensei/swat) — MCP plugin bridge + skill definition.

## What's Inside

- **plugin/** — OpenClaw MCP bridge that exposes SWAT tools to OpenClaw agents
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

## Configuration

| Key | Default | Description |
|-----|---------|-------------|
| `binaryPath` | — | Path to the `swat` binary (required) |
| `runtime` | `copilot` | Agent runtime: `copilot`, `gemini` |

## Notification Configuration

SWAT sends notifications through the OpenClaw Gateway API. To configure where notifications are delivered, set two environment variables in `~/.swat/.env`:

```bash
OPENCLAW_NOTIFY_TARGET=<target-id>
OPENCLAW_NOTIFY_CHANNEL=<channel-type>
```

### Required Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `OPENCLAW_NOTIFY_TARGET` | Chat or channel ID for the target platform | `123456789` |
| `OPENCLAW_NOTIFY_CHANNEL` | Notification channel type | `telegram`, `discord`, `signal` |

### Finding Your Target ID

The target ID depends on your notification channel:

- **Telegram** — Use the `allowFrom` value from `~/.openclaw/openclaw.json`
- **Discord** — DM channel ID (enable Developer Mode → right-click channel → Copy ID)
- **Signal** — Phone number or group ID as configured in OpenClaw

### Gateway Connection

The Gateway port and token are read automatically from `~/.openclaw/openclaw.json`. No manual configuration is needed unless you want to override them.

To override, add these to `~/.swat/.env`:

```bash
OPENCLAW_GATEWAY_PORT=<port>
OPENCLAW_GATEWAY_TOKEN=<token>
```

### Priority Order

Configuration values are resolved in this order (first match wins):

1. Environment variables (exported in shell)
2. `~/.swat/.env` file
3. `~/.openclaw/openclaw.json` (port and token only)

### Testing

After configuration, verify notifications work:

```bash
swat notify "Test notification from SWAT"
```

If any required value is missing, `swat_notify` will return a descriptive error indicating which variable needs to be set.

## Related Repos

- [swat](https://github.com/LangSensei/swat) — Commander engine (Go)
- [swat-marketplace](https://github.com/LangSensei/swat-marketplace) — Squads, skills, and MCPs
