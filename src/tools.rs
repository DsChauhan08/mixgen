use reqwest;
use std::fs;
use std::process::Command;
use std::path::{Path, PathBuf};

pub async fn ensure_binaries() {
    fs::create_dir_all(".toolbin").unwrap();

    let yt = tool_path("yt-dlp");
    let ff = tool_path("ffmpeg");

    if !yt.exists() {
        println!("Downloading yt-dlp...");
        download(yt.to_str().unwrap(), yt_url()).await;
        make_executable(&yt);
    }

    if !ff.exists() {
        println!("Downloading ffmpeg (small static build)...");
        download(ff.to_str().unwrap(), ffmpeg_url()).await;
        make_executable(&ff);
    }
}

pub fn tool_path(name: &str) -> PathBuf {
    if cfg!(windows) {
        Path::new(".toolbin").join(format!("{name}.exe"))
    } else {
        Path::new(".toolbin").join(name)
    }
}

fn yt_url() -> &'static str {
    if cfg!(windows) {
        "https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp.exe"
    } else if cfg!(target_os = "macos") {
        "https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp_macos"
    } else {
        "https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp"
    }
}

fn ffmpeg_url() -> &'static str {
    if cfg!(windows) {
        "https://www.gyan.dev/ffmpeg/builds/packages/ffmpeg-release-essentials.zip"
    } else if cfg!(target_os = "macos") {
        "https://evermeet.cx/ffmpeg/ffmpeg.zip"
    } else {
        "https://johnvansickle.com/ffmpeg/releases/ffmpeg-release-amd64-static.tar.xz"
    }
}

pub async fn download(path: &str, url: &str) {
    let bytes = reqwest::get(url)
        .await
        .unwrap()
        .bytes()
        .await
        .unwrap();

    fs::write(path, bytes).unwrap();
}

pub fn make_executable(p: &PathBuf) {
    #[cfg(unix)]
    {
        use std::os::unix::fs::PermissionsExt;
        let mut perms = fs::metadata(&p).unwrap().permissions();
        perms.set_mode(0o755);
        fs::set_permissions(&p, perms).unwrap();
    }
}

pub fn download_playlist(url: &str, dir: &Path) -> std::io::Result<()> {
    let yt = tool_path("yt-dlp");

    Command::new(yt)
        .arg("-x")
        .arg("--audio-format")
        .arg("webm")
        .arg(url)
        .arg("-o")
        .arg("%(title)s.%(ext)s")
        .current_dir(dir)
        .status()
        .expect("yt-dlp failed");

    Ok(())
}

