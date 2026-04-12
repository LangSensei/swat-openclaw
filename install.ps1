# SWAT OpenClaw Integration Installer for Windows
# Usage: irm https://raw.githubusercontent.com/LangSensei/swat-openclaw/main/install.ps1 | iex

$ErrorActionPreference = "Stop"

$Repo = "LangSensei/swat-openclaw"
$SwatHome = Join-Path $env:USERPROFILE ".swat"
$PluginDir = Join-Path $SwatHome "plugin"

function Info  { param($Msg) Write-Host "[swat-openclaw] $Msg" -ForegroundColor Cyan }
function Ok    { param($Msg) Write-Host "[swat-openclaw] $Msg" -ForegroundColor Green }
function Err   { param($Msg) Write-Host "[swat-openclaw] $Msg" -ForegroundColor Red }

# --- Prerequisites ---

$missing = @()
if (-not (Get-Command node -ErrorAction SilentlyContinue)) { $missing += "node" }
if (-not (Get-Command npm -ErrorAction SilentlyContinue))  { $missing += "npm" }
if ($missing.Count -gt 0) { Err "Missing prerequisites: $($missing -join ', ')"; exit 1 }

if (-not (Get-Command swat -ErrorAction SilentlyContinue)) {
    if (-not (Test-Path (Join-Path $env:USERPROFILE ".local\bin\swat.exe"))) {
        Err "SWAT binary not found. Install swat first:"
        Write-Host "  irm https://raw.githubusercontent.com/LangSensei/swat/main/install.ps1 | iex"
        exit 1
    }
}

# --- Download ---

Write-Host ""
Info "Installing SWAT OpenClaw integration..."
Write-Host ""

$tmpDir = Join-Path ([System.IO.Path]::GetTempPath()) "swat-openclaw-$(Get-Random)"
New-Item -ItemType Directory -Path $tmpDir -Force | Out-Null

Info "Downloading..."
$zipUrl = "https://github.com/$Repo/archive/refs/heads/main.zip"
$zipPath = Join-Path $tmpDir "main.zip"
Invoke-WebRequest -Uri $zipUrl -OutFile $zipPath -UseBasicParsing
Expand-Archive -Path $zipPath -DestinationPath $tmpDir -Force
$extractDir = Join-Path $tmpDir "swat-openclaw-main"

# --- Install Plugin ---

if (Test-Path $PluginDir) { Remove-Item -Recurse -Force $PluginDir }
New-Item -ItemType Directory -Path $PluginDir -Force | Out-Null
Copy-Item (Join-Path $extractDir "plugin\*") $PluginDir -Force

Info "Installing plugin dependencies..."
Push-Location $PluginDir
npm install --quiet 2>$null
Pop-Location
Ok "Plugin installed to $PluginDir"

# --- Install Skill ---

$ocSkills = $null
$candidates = @(
    (Join-Path $env:APPDATA "npm\node_modules\openclaw\skills"),
    (Join-Path $env:USERPROFILE ".npm-global\lib\node_modules\openclaw\skills")
)
foreach ($dir in $candidates) {
    if (Test-Path $dir) { $ocSkills = $dir; break }
}

if ($ocSkills) {
    $skillDir = Join-Path $ocSkills "swat"
    New-Item -ItemType Directory -Path $skillDir -Force | Out-Null
    Copy-Item (Join-Path $extractDir "skill\SKILL.md") $skillDir -Force
    Ok "Skill installed to $skillDir"
} else {
    Info "OpenClaw skills directory not found. Manually copy skill\SKILL.md to your OpenClaw skills dir."
}

# --- Register in OpenClaw Config ---

$ocConfig = Join-Path $env:USERPROFILE ".openclaw\openclaw.json"
$pluginPath = $PluginDir -replace '\\', '/'

# Find swat binary
$binPath = (Get-Command swat -ErrorAction SilentlyContinue).Source
if (-not $binPath) { $binPath = (Join-Path $env:USERPROFILE ".local\bin\swat.exe") }
$binPath = $binPath -replace '\\', '/'

if (Test-Path $ocConfig) {
    try {
        node -e @"
const fs = require('fs');
const cfg = JSON.parse(fs.readFileSync('$($ocConfig -replace '\\', '/')', 'utf8'));
cfg.plugins = cfg.plugins || {};
cfg.plugins.load = cfg.plugins.load || {};
cfg.plugins.load.paths = cfg.plugins.load.paths || [];
cfg.plugins.entries = cfg.plugins.entries || {};
if (!cfg.plugins.load.paths.includes('$pluginPath')) {
    cfg.plugins.load.paths.push('$pluginPath');
}
cfg.plugins.entries['swat-mcp-bridge'] = {
    enabled: true,
    config: { binaryPath: '$binPath' }
};
fs.writeFileSync('$($ocConfig -replace '\\', '/')', JSON.stringify(cfg, null, 2) + '\n');
"@
        Ok "Plugin registered in OpenClaw config"
    } catch {
        Err "Failed to auto-register. Manually add to $ocConfig"
    }
} else {
    Info "OpenClaw config not found. After installing OpenClaw, add plugin path to config."
}

# --- Cleanup ---

Remove-Item -Recurse -Force $tmpDir -ErrorAction SilentlyContinue

Write-Host ""
Ok "SWAT OpenClaw integration installed! 🚀"
Write-Host ""
Info "Next: openclaw gateway restart"
Write-Host ""
