<#
.SYNOPSIS
          _____                    _____                                            _____                    _____                    _____          
         /\    \                  /\    \                 ______                   /\    \                  /\    \                  /\    \         
        /::\____\                /::\    \               |::|   |                 /::\    \                /::\    \                /::\____\        
       /::::|   |                \:::\    \              |::|   |                /::::\    \              /::::\    \              /::::|   |        
      /:::::|   |                 \:::\    \             |::|   |               /::::::\    \            /::::::\    \            /:::::|   |        
     /::::::|   |                  \:::\    \            |::|   |              /:::/\:::\    \          /:::/\:::\    \          /::::::|   |        
    /:::/|::|   |                   \:::\    \           |::|   |             /:::/  \:::\    \        /:::/__\:::\    \        /:::/|::|   |        
   /:::/ |::|   |                   /::::\    \          |::|   |            /:::/    \:::\    \      /::::\   \:::\    \      /:::/ |::|   |        
  /:::/  |::|___|______    ____    /::::::\    \         |::|   |           /:::/    / \:::\    \    /::::::\   \:::\    \    /:::/  |::|   | _____  
 /:::/   |::::::::\    \  /\   \  /:::/\:::\    \  ______|::|___|___ ____  /:::/    /   \:::\ ___\  /:::/\:::\   \:::\    \  /:::/   |::|   |/\    \ 
/:::/    |:::::::::\____\/::\   \/:::/  \:::\____\|:::::::::::::::::|    |/:::/____/  ___\:::|    |/:::/__\:::\   \:::\____\/:: /    |::|   /::\____\
\::/    / ~~~~~/:::/    /\:::\  /:::/    \::/    /|:::::::::::::::::|____|\:::\    \ /\  /:::|____|\:::\   \:::\   \::/    /\::/    /|::|  /:::/    /
 \/____/      /:::/    /  \:::\/:::/    / \/____/  ~~~~~~|::|~~~|~~~       \:::\    /::\ \::/    /  \:::\   \:::\   \/____/  \/____/ |::| /:::/    / 
             /:::/    /    \::::::/    /                 |::|   |           \:::\   \:::\ \/____/    \:::\   \:::\    \              |::|/:::/    /  
            /:::/    /      \::::/____/                  |::|   |            \:::\   \:::\____\       \:::\   \:::\____\             |::::::/    /   
           /:::/    /        \:::\    \                  |::|   |             \:::\  /:::/    /        \:::\   \::/    /             |:::::/    /    
          /:::/    /          \:::\    \                 |::|   |              \:::\/:::/    /          \:::\   \/____/              |::::/    /     
         /:::/    /            \:::\    \                |::|   |               \::::::/    /            \:::\    \                  /:::/    /      
        /:::/    /              \:::\____\               |::|   |                \::::/    /              \:::\____\                /:::/    /       
        \::/    /                \::/    /               |::|___|                 \::/____/                \::/    /                \::/    /        
         \/____/                  \/____/                 ~~                                                \/____/                  \/____/         
                                                                                                                                                     
A unified tool for Downloading, Cutting, and Mixing audio/video.
Native for Windows.

.DESCRIPTION
Version: 2.0.0
Author: MixGen Team
#>

$ErrorActionPreference = "Stop"
$AppName = "MixGen"
$Version = "2.0.0"
$DataRoot = if ($env:XDG_DATA_HOME -and $env:XDG_DATA_HOME.Trim()) {
    $env:XDG_DATA_HOME
} else {
    Join-Path (Join-Path $HOME ".local") "share"
}
$AppHome = Join-Path $DataRoot "mixgen"
$BinDir = Join-Path $AppHome "bin"

# Ensure bin dir exists
New-Item -ItemType Directory -Path $BinDir -Force | Out-Null

# Add bin to Path for this session
$env:Path = "$BinDir;$env:Path"

# --- Colors & formatting ---
function Write-Header {
    Clear-Host
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host "   $AppName v$Version - Professional Media Tool (Windows)"
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host ""
}

function Log-Info ($msg) { Write-Host "[INFO] $msg" -ForegroundColor Blue }
function Log-Success ($msg) { Write-Host "[SUCCESS] $msg" -ForegroundColor Green }
function Log-Warn ($msg) { Write-Host "[WARN] $msg" -ForegroundColor Yellow }
function Log-Error ($msg) { Write-Host "[ERROR] $msg" -ForegroundColor Red }

# --- Dependencies ---

function Install-YtDlp {
    Log-Info "Installing yt-dlp..."
    $Url = "https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp.exe"
    $Dest = Join-Path $BinDir "yt-dlp.exe"
    
    try {
        Invoke-WebRequest -Uri $Url -OutFile $Dest
        Log-Success "yt-dlp installed."
    } catch {
        Log-Error "Failed to download yt-dlp: $_"
    }
}

function Install-Ffmpeg {
    Log-Info "Installing ffmpeg (This may take a while)..."
    $Url = "https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-essentials.zip"
    $ZipPath = Join-Path $BinDir "ffmpeg.zip"
    
    try {
        Log-Info "Downloading zip from $Url..."
        Invoke-WebRequest -Uri $Url -OutFile $ZipPath
        
        Log-Info "Extracting..."
        Expand-Archive -Path $ZipPath -DestinationPath $BinDir -Force
        
        # Locate bins
        $FfmpegExe = Get-ChildItem -Path $BinDir -Filter "ffmpeg.exe" -Recurse | Select-Object -First 1
        $FfprobeExe = Get-ChildItem -Path $BinDir -Filter "ffprobe.exe" -Recurse | Select-Object -First 1
        
        if ($FfmpegExe) { Move-Item -Path $FfmpegExe.FullName -Destination $BinDir -Force }
        if ($FfprobeExe) { Move-Item -Path $FfprobeExe.FullName -Destination $BinDir -Force }
        
        # Cleanup
        Remove-Item $ZipPath -Force
        # Remove the extracted folder (usually ffmpeg-*-essentials_build)
        Get-ChildItem -Path $BinDir -Directory | Where-Object { $_.Name -like "ffmpeg-*-essentials_build" } | Remove-Item -Recurse -Force
        
        Log-Success "ffmpeg installed."
    } catch {
        Log-Error "Failed to install ffmpeg: $_"
    }
}

function Check-Dependencies {
    Log-Warn "Checking dependencies..."
    
    if (-not (Get-Command "yt-dlp" -ErrorAction SilentlyContinue)) {
        Log-Warn "yt-dlp not found."
        Install-YtDlp
    } else {
        Log-Success "yt-dlp found."
    }

    if (-not (Get-Command "ffmpeg" -ErrorAction SilentlyContinue)) {
        Log-Warn "ffmpeg not found."
        Install-Ffmpeg
    } else {
        Log-Success "ffmpeg found."
    }
    
    Write-Host ""
    Read-Host "Press Enter to continue"
}

# --- Actions ---

function Show-Download {
    Write-Header
    Write-Host "--- Download Media ---" -ForegroundColor Yellow
    $Url = Read-Host "Enter YouTube URL (Playlist or Video)"
    if ([string]::IsNullOrWhiteSpace($Url)) { return }

    Write-Host "Select Format:"
    Write-Host "1) Audio (MP3)"
    Write-Host "2) Video (MP4)"
    $Choice = Read-Host "Choose (1-2)"
    
    switch ($Choice) {
        "1" {
            Write-Host "Downloading Audio..."
            yt-dlp -x --audio-format mp3 --audio-quality 0 -o "%(title)s.%(ext)s" $Url
        }
        "2" {
            Write-Host "Downloading Video..."
            yt-dlp -f "bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best" -o "%(title)s.%(ext)s" $Url
        }
        Default { Log-Error "Invalid selection." }
    }
    Read-Host "Download complete. Press Enter..."
}

function Show-Cut {
    Write-Header
    Write-Host "--- Cut Media ---" -ForegroundColor Yellow
    
    $Files = Get-ChildItem -Path . -Include *.mp3,*.mp4,*.mkv,*.webm
    if ($Files.Count -eq 0) {
        Log-Error "No media files found."
        Read-Host "Press Enter..."
        return
    }
    
    $i = 1
    foreach ($f in $Files) {
        Write-Host "$i) $($f.Name)"
        $i++
    }
    
    $IdxStr = Read-Host "Select file number"
    if (-not [int]::TryParse($IdxStr, [ref]$null)) { return }
    $Idx = [int]$IdxStr
    
    if ($Idx -lt 1 -or $Idx -gt $Files.Count) { Log-Error "Invalid selection"; return }
    $Selected = $Files[$Idx - 1]
    
    Write-Host "Selected: $($Selected.Name)"
    $StartTime = Read-Host "Enter Start Time (e.g. 00:00:30)"
    $EndTime = Read-Host "Enter End Time (e.g. 00:01:00) or Duration"
    $Suffix = Read-Host "Enter Suffix for Output (default: 'cut')"
    if ([string]::IsNullOrWhiteSpace($Suffix)) { $Suffix = "cut" }
    # Security: Sanitize
    $Suffix = $Suffix -replace '[^a-zA-Z0-9_-]', ''
    
    $OutFile = "{0}_{1}{2}" -f $Selected.BaseName, $Suffix, $Selected.Extension
    
    Log-Info "Cutting..."
    ffmpeg -i $Selected.Name -ss $StartTime -to $EndTime -c copy $OutFile
    
    if ($?) { Log-Success "Saved to $OutFile" }
    Read-Host "Press Enter..."
}

function Show-Mix {
    Write-Header
    Write-Host "--- Mix / Mashup ---" -ForegroundColor Yellow
    Write-Host "Combines audio files with crossfade and normalization."
    
    $Files = @(Get-ChildItem -Path . -Filter "*cut*.mp3" | Sort-Object { [regex]::Replace($_.Name, '\d+', { $args[0].Value.PadLeft(20) }) }) # Natural sort attempt
    
    if ($Files.Count -eq 0) {
        Log-Warn "No '*cut*.mp3' files found."
        $Ans = Read-Host "Use all .mp3 files instead? (y/n)"
        if ($Ans -match "^[Yy]") {
            $Files = @(Get-ChildItem -Path . -Filter "*.mp3" | Sort-Object Name)
        } else {
            return
        }
    }
    
    Write-Host "Files:"
    $Files | ForEach-Object { Write-Host "- $($_.Name)" }
    $Ans = Read-Host "Proceed? (y/n)"
    if ($Ans -notmatch "^[Yy]") { return }

    # Params
    $TargetLufs = -14
    $Crossfade = 0.6
    $Temp = "tmp_mix_working.mp3"
    $FinalName = "mashup_final.mp3"
    
    # Init first file
    Log-Info "Initializing base: $($Files[0].Name)"
    ffmpeg -y -hide_banner -loglevel error -i $($Files[0].Name) -filter:a "loudnorm=I=$TargetLufs" $Temp
    
    for ($i = 1; $i -lt $Files.Count; $i++) {
        $Next = $Files[$i].Name
        Log-Info "Mixing [$i/$($Files.Count)]: Adding $Next"
        
        ffmpeg -y -hide_banner -loglevel error -i $Next -filter:a "loudnorm=I=$TargetLufs" "tmp_norm.mp3"
        
        # Complex filter string quoting can be tricky in PS calling external
        # We use explicit arguments array or careful string
        ffmpeg -y -hide_banner -loglevel error `
            -i $Temp -i "tmp_norm.mp3" `
            -filter_complex "acrossfade=d=$Crossfade:c1=tri:c2=tri" `
            "tmp_out.mp3"
            
        Move-Item "tmp_out.mp3" $Temp -Force
        Remove-Item "tmp_norm.mp3" -Force
    }
    
    Move-Item $Temp $FinalName -Force
    Log-Success "Mix Complete! Saved to: $FinalName"
    Read-Host "Press Enter to return..."
}

# --- Main Loop ---

Check-Dependencies

while ($true) {
    Write-Header
    Write-Host "1) Download (YouTube/Playlist)"
    Write-Host "2) Cut Media (Trim Start/End)"
    Write-Host "3) Mix/Mashup (Combine Audio)"
    Write-Host "4) Exit"
    Write-Host ""
    $Sel = Read-Host "Select an option [1-4]"
    
    switch ($Sel) {
        "1" { Show-Download }
        "2" { Show-Cut }
        "3" { Show-Mix }
        "4" { Write-Host "Goodbye!"; exit }
        Default { Write-Host "Invalid option." }
    }
}
