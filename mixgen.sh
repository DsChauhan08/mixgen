#!/usr/bin/env bash

# ==============================================================================
#           _____                    _____                                            _____                    _____                    _____          
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
                                                                                                                                                     
# A unified tool for Downloading, Cutting, and Mixing audio/video.
# Works on Linux, macOS, and Windows (via Git Bash/WSL).
# ==============================================================================

# --- Configuration ---
APP_NAME="MixGen"
VERSION="2.0.0"
APP_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/mixgen"
BIN_DIR="$APP_HOME/bin"
mkdir -p "$BIN_DIR"
export PATH="$BIN_DIR:$PATH"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# --- Utilities ---

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

header() {
    clear
    echo -e "${CYAN}${BOLD}"
    echo "============================================================"
    echo "   $APP_NAME v$VERSION - Professional Media Tool"
    echo "============================================================"
    echo -e "${NC}"
}

# --- Dependency Management ---

get_os() {
    case "$(uname -s)" in
        Linux*)     echo "linux";;
        Darwin*)    echo "mac";;
        CYGWIN*|MINGW*|MSYS*) echo "win";;
        *)          echo "unknown";;
    esac
}

install_ytdlp() {
    log_info "Installing yt-dlp..."
    local os=$(get_os)
    local url=""
    local target="$BIN_DIR/yt-dlp"

    if [ "$os" == "win" ]; then
        url="https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp.exe"
        target="${target}.exe"
    else
        url="https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp"
    fi

    echo "Downloading from: $url"
    if curl -L -o "$target" "$url" --progress-bar; then
        chmod +x "$target"
        log_success "yt-dlp installed to $target"
    else
        log_error "Failed to download yt-dlp."
        return 1
    fi
}

install_ffmpeg() {
    log_info "Installing ffmpeg (This may take a while)..."
    local os=$(get_os)
    local arch=$(uname -m)
    
    # Simple static build fetching logic
    if [ "$os" == "linux" ]; then
        # John Van Sickle static builds
        local url="https://johnvansickle.com/ffmpeg/releases/ffmpeg-release-amd64-static.tar.xz"
        if [ "$arch" == "aarch64" ]; then
             url="https://johnvansickle.com/ffmpeg/releases/ffmpeg-release-arm64-static.tar.xz"
        fi
        
        echo "Downloading Linux static build..."
        curl -L -o "$BIN_DIR/ffmpeg.tar.xz" "$url" --progress-bar
        
        echo "Extracting..."
        tar -xf "$BIN_DIR/ffmpeg.tar.xz" -C "$BIN_DIR"
        
        # Move binaries to bin root and cleanup
        find "$BIN_DIR" -name "ffmpeg" -type f -exec mv {} "$BIN_DIR/" \;
        find "$BIN_DIR" -name "ffprobe" -type f -exec mv {} "$BIN_DIR/" \;
        
        rm "$BIN_DIR/ffmpeg.tar.xz"
        rm -rf "$BIN_DIR/ffmpeg-*-static" # Cleanup folder

    elif [ "$os" == "mac" ]; then
        log_warn "Automatic FFMPEG install on macOS is complex via script. Using basic evermeet download..."
        curl -L -o "$BIN_DIR/ffmpeg.zip" "https://evermeet.cx/ffmpeg/getrelease/zip" --progress-bar
        unzip -o -q "$BIN_DIR/ffmpeg.zip" -d "$BIN_DIR"
        rm "$BIN_DIR/ffmpeg.zip"

    elif [ "$os" == "win" ]; then
        log_warn "Downloading FFMPEG for Windows (Gyan.dev)..."
        local url="https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-essentials.zip"
        curl -L -o "$BIN_DIR/ffmpeg.zip" "$url" --progress-bar
        unzip -o -q "$BIN_DIR/ffmpeg.zip" -d "$BIN_DIR"
        
        # Move exe from subfolder
        find "$BIN_DIR" -name "ffmpeg.exe" -type f -exec mv {} "$BIN_DIR/" \;
        find "$BIN_DIR" -name "ffprobe.exe" -type f -exec mv {} "$BIN_DIR/" \;
        rm "$BIN_DIR/ffmpeg.zip"
        # Cleanup folder logic omitted for brevity, glob pattern might fail if not careful
    else
        log_error "Unsupported OS for auto-install. Please install ffmpeg manually."
        return 1
    fi
    
    chmod +x "$BIN_DIR/ffmpeg"* 2>/dev/null
    log_success "ffmpeg installed."
}

check_dependencies() {
    echo -e "${YELLOW}Checking dependencies...${NC}"
    
    if ! command -v yt-dlp &> /dev/null; then
        log_warn "yt-dlp not found."
        install_ytdlp
    else
        log_success "yt-dlp found."
    fi

    if ! command -v ffmpeg &> /dev/null; then
        log_warn "ffmpeg not found."
        install_ffmpeg
    else
        log_success "ffmpeg found."
    fi
    
    echo ""
    read -n 1 -s -r -p "Press any key to continue..."
}

# --- Modules ---

do_download() {
    header
    echo -e "${BOLD}--- Download Media ---${NC}"
    echo "Enter YouTube URL (Playlist or Video):"
    read -r url
    if [ -z "$url" ]; then return; fi

    echo ""
    echo "Select Format:"
    PS3="Choose (1-2): "
    options=("Audio (MP3)" "Video (MP4)")
    select opt in "${options[@]}"; do
        case $opt in
            "Audio (MP3)")
                echo "Downloading Audio..."
                yt-dlp -x --audio-format mp3 --audio-quality 0 -o "%(title)s.%(ext)s" "$url"
                break
                ;;
            "Video (MP4)")
                echo "Downloading Video..."
                yt-dlp -f "bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best" -o "%(title)s.%(ext)s" "$url"
                break
                ;;
            *) echo "Invalid option";;
        esac
    done
    read -n 1 -s -r -p "Download complete. Press key to return..."
}

do_cut() {
    header
    echo -e "${BOLD}--- Cut Media ---${NC}"
    
    # List files
    files=(*.mp3 *.mp4 *.mkv *.webm)
    if [ ! -e "${files[0]}" ]; then
        log_error "No media files found in current directory."
        read -n 1 -s -r -p "Press key..."
        return
    fi
    
    echo "Files available:"
    i=1
    for f in "${files[@]}"; do
        echo "$i) $f"
        ((i++))
    done
    
    echo ""
    read -p "Select file number: " file_idx
    selected="${files[$((file_idx-1))]}"
    
    if [ -z "$selected" ]; then log_error "Invalid selection"; sleep 1; return; fi
    
    echo "Selected: $selected"
    echo "Enter Start Time (e.g. 00:00:30):"
    read -r start_time
    echo "Enter End Time (e.g. 00:01:00) or Duration (e.g. 30):"
    read -r end_time
    echo "Enter Suffix for Output (default: 'cut'):"
    read -r suffix
    suffix=${suffix:-cut}
    # Security: Sanitize suffix to remove non-alphanumeric (except -_)
    suffix=$(echo "$suffix" | tr -cd '[:alnum:]_-')
    
    ext="${selected##*.}"
    base="${selected%.*}"
    outfile="${base}_${suffix}.${ext}"
    
    log_info "Cutting..."
    ffmpeg -i "$selected" -ss "$start_time" -to "$end_time" -c copy "$outfile"
    
    if [ $? -eq 0 ]; then
        log_success "Saved to $outfile"
    else
        log_error "Cut failed."
    fi
    read -n 1 -s -r -p "Press key..."
}

do_mix() {
    header
    echo -e "${BOLD}--- Mix / Mashup ---${NC}"
    echo "This module combines audio files with crossfade and normalization."
    
    # 1. Select Files
    files=($(ls *cut*.mp3 2>/dev/null | sort -V))
    if [ ${#files[@]} -eq 0 ]; then
        log_warn "No '*cut*.mp3' files found. Select manually?"
        # Manual selection logic could go here, for now simple exit
        read -p "Use all .mp3 files instead? (y/n) " ans
        if [[ $ans =~ ^[Yy]$ ]]; then
            files=($(ls *.mp3 | sort -V))
        else
            return
        fi
    fi
    
    echo "Selected files for mixing:"
    printf '%s\n' "${files[@]}"
    
    read -p "Proceed? (y/n) " proceed
    if [[ ! $proceed =~ ^[Yy]$ ]]; then return; fi

    # Params
    target_lufs=-14
    crossfade=0.6 # seconds
    temp="tmp_mix_working.mp3"
    final="mashup_final.mp3"
    
    # Init first file
    log_info "Initializing base: ${files[0]}"
    ffmpeg -y -hide_banner -loglevel error -i "${files[0]}" -filter:a "loudnorm=I=$target_lufs" "$temp"
    
    for ((i = 1; i < ${#files[@]}; i++)); do
        next="${files[$i]}"
        log_info "Mixing [$i/${#files[@]}]: Adding $next"
        
        # Normalize next
        ffmpeg -y -hide_banner -loglevel error -i "$next" -filter:a "loudnorm=I=$target_lufs" "tmp_norm.mp3"
        
        # Crossfade with accum
        # We need complex filter to mix temp and next
        ffmpeg -y -hide_banner -loglevel error \
            -i "$temp" -i "tmp_norm.mp3" \
            -filter_complex "acrossfade=d=$crossfade:c1=tri:c2=tri" \
            "tmp_out.mp3"
            
        mv "tmp_out.mp3" "$temp"
        rm "tmp_norm.mp3"
    done
    
    mv "$temp" "$final"
    log_success "Mix Complete! Saved to: $final"
    read -n 1 -s -r -p "Press key to return..."
}

# --- Main Loop ---

chmod +x "$0" # specific self-permission check could be redundant but good for first run

check_dependencies

while true; do
    header
    echo "1) Download (YouTube/Playlist)"
    echo "2) Cut Media (Trim Start/End)"
    echo "3) Mix/Mashup (Combine Audio)"
    echo "4) Exit"
    echo ""
    read -p "Select an option [1-4]: " choice
    
    case $choice in
        1) do_download ;;
        2) do_cut ;;
        3) do_mix ;;
        4) echo "Goodbye!"; exit 0 ;;
        *) echo "Invalid option." ;;
    esac
done
