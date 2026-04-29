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

## Post-Install Configuration

After installing, you **must** configure your runtime before first use:

Edit `~/.openclaw/openclaw.json`:
```json
{
  "plugins": {
    "entries": {
      "swat-mcp-bridge": {
        "config": {
          "runtime": "copilot"
        }
      }
    }
  }
}
```

Choose `"copilot"` or `"gemini"` based on which CLI you have installed.

## Upgrade

Re-run the same install command. The installer detects existing configuration and only updates plugin files and binary path — your `runtime`, notification settings, and other config are preserved.

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
| `runtime` | — | Agent runtime: `copilot` or `gemini` (required) |

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

Gateway port and token are read from `~/.openclaw/openclaw.json`. Notification target and channel are read from `~/.swat/.env`. Each value has exactly one source.

### Testing

After configuration, verify notifications work:

Use the `swat_notify` tool through OpenClaw to test notifications:
> swat_notify(message="Test notification from SWAT", operation_id="optional-op-id")

The optional `operation_id` parameter enables a direct link to the operation report in the notification.

If any required value is missing, `swat_notify` will return a descriptive error indicating which variable needs to be set.

## Related Repos

- [swat](https://github.com/LangSensei/swat) — Commander engine (Go)
- [swat-marketplace](https://github.com/LangSensei/swat-marketplace) — Squads, skills, and MCPs
