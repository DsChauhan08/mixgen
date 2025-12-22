$ErrorActionPreference = "Stop"

param(
    [string]$Prefix
)

$AppName = "mixgen"
$BaseDir = if ($Prefix) {
    $Prefix
} else {
    $dataRoot = if ($env:XDG_DATA_HOME -and $env:XDG_DATA_HOME.Trim()) {
        $env:XDG_DATA_HOME
    } else {
        Join-Path (Join-Path $HOME ".local") "share"
    }
    Join-Path $dataRoot "mixgen"
}
$BinDir = Join-Path $BaseDir "bin"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

New-Item -ItemType Directory -Path $BinDir -Force | Out-Null

Copy-Item -Force (Join-Path $ScriptDir "mixgen.ps1") (Join-Path $BinDir "mixgen.ps1")

$CmdPath = Join-Path $BinDir "mixgen.cmd"
$cmdContent = @"
@echo off
PowerShell -NoProfile -ExecutionPolicy Bypass -File "%~dp0mixgen.ps1" %*
"@
Set-Content -Path $CmdPath -Value $cmdContent

$existingUserPath = [Environment]::GetEnvironmentVariable("Path", "User")
$userEntries = @()
if ($existingUserPath) {
    $userEntries = $existingUserPath -split ';'
}

if (-not ($userEntries -contains $BinDir)) {
    $newPath = (@($userEntries) + $BinDir) -join ';'
    [Environment]::SetEnvironmentVariable("Path", $newPath, "User")
    Write-Host "Added $BinDir to user PATH. Restart your terminal to pick it up."
}

Write-Host "Installed $AppName into $BinDir. Run 'mixgen' from a new terminal."
