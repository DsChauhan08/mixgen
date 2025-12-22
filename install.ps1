$ErrorActionPreference = "Stop"

param(
    [string]$Prefix
)

$AppName = "mixgen"
$BaseDir = if ($Prefix) { $Prefix } else { Join-Path $HOME ".mixgen" }
$BinDir = Join-Path $BaseDir "bin"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

if (-not (Test-Path $BinDir)) {
    New-Item -ItemType Directory -Path $BinDir -Force | Out-Null
}

Copy-Item -Force (Join-Path $ScriptDir "mixgen.ps1") (Join-Path $BinDir "mixgen.ps1")

$CmdPath = Join-Path $BinDir "mixgen.cmd"
Set-Content -Path $CmdPath -Value "@echo off`r`nPowerShell -NoProfile -ExecutionPolicy Bypass -File ""%~dp0mixgen.ps1"" %*"

$pathEntries = ($env:Path -split ';')
if (-not ($pathEntries -contains $BinDir)) {
    $existing = [Environment]::GetEnvironmentVariable("Path", "User")
    if ($existing) {
        $newPath = "$existing;$BinDir"
    } else {
        $newPath = $BinDir
    }
    [Environment]::SetEnvironmentVariable("Path", $newPath, "User")
    Write-Host "Added $BinDir to user PATH. Restart your terminal to pick it up."
}

Write-Host "Installed $AppName into $BinDir. Run 'mixgen' from a new terminal."
