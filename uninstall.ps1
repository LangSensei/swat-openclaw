# SWAT OpenClaw Integration Uninstaller for Windows
# Usage: irm https://raw.githubusercontent.com/LangSensei/swat-openclaw/main/uninstall.ps1 | iex

$ErrorActionPreference = "Stop"

$SwatHome = Join-Path $env:USERPROFILE ".swat"
$PluginDir = Join-Path $SwatHome "plugin"

function Info  { param($Msg) Write-Host "[swat-openclaw] $Msg" -ForegroundColor Cyan }
function Ok    { param($Msg) Write-Host "[swat-openclaw] $Msg" -ForegroundColor Green }
function Warn  { param($Msg) Write-Host "[swat-openclaw] $Msg" -ForegroundColor Yellow }

$Yes = $args -contains "--yes"

Write-Host ""
Write-Host "  SWAT OpenClaw Uninstaller"
Write-Host "  ========================="
Write-Host ""

if (-not $Yes) {
    Warn "This will remove:"
    Write-Host "  - Plugin:  $PluginDir\"
    Write-Host "  - Skill:   OpenClaw skills\swat\"
    Write-Host "  - Config:  swat-mcp-bridge entry from openclaw.json"
    Write-Host ""
    $confirm = Read-Host "Continue? [y/N]"
    if ($confirm -notin @("y", "Y")) {
        Info "Aborted."
        exit 0
    }
}

# --- Remove plugin ---

if (Test-Path $PluginDir) {
    Remove-Item -Recurse -Force $PluginDir
    Ok "Removed $PluginDir"
} else {
    Info "Plugin not found (skipped)"
}

# --- Remove skill ---

$candidates = @(
    (Join-Path $env:APPDATA "npm\node_modules\openclaw\skills\swat"),
    (Join-Path $env:USERPROFILE ".npm-global\lib\node_modules\openclaw\skills\swat")
)
foreach ($dir in $candidates) {
    if (Test-Path $dir) {
        Remove-Item -Recurse -Force $dir
        Ok "Removed skill from $dir"
        break
    }
}

# --- Clean OpenClaw config ---

$ocConfig = Join-Path $env:USERPROFILE ".openclaw\openclaw.json"
if ((Test-Path $ocConfig) -and (Get-Command node -ErrorAction SilentlyContinue)) {
    try {
        node -e @"
const fs = require('fs');
const cfg = JSON.parse(fs.readFileSync('$($ocConfig -replace '\\', '/')', 'utf8'));
let changed = false;
if (cfg.plugins?.load?.paths) {
    const before = cfg.plugins.load.paths.length;
    cfg.plugins.load.paths = cfg.plugins.load.paths.filter(p => !p.includes('.swat/plugin') && !p.includes('.swat\\plugin'));
    if (cfg.plugins.load.paths.length < before) changed = true;
    if (cfg.plugins.load.paths.length === 0) delete cfg.plugins.load.paths;
}
if (cfg.plugins?.entries?.['swat-mcp-bridge']) {
    delete cfg.plugins.entries['swat-mcp-bridge'];
    changed = true;
}
if (changed) {
    fs.writeFileSync('$($ocConfig -replace '\\', '/')', JSON.stringify(cfg, null, 2) + '\n');
}
"@
        Ok "Cleaned OpenClaw config"
    } catch {
        Info "Could not auto-clean OpenClaw config"
    }
}

Write-Host ""
Ok "SWAT OpenClaw integration removed."
Info "Restart OpenClaw: openclaw gateway restart"
Write-Host ""
