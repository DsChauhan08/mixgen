mod tools;
mod ffmpeg_ops;

use rustyline::Editor;
use std::fs;
use std::process::Command;
use rfd::FileDialog;
use tools::*;
use ffmpeg_ops::*;

#[tokio::main]
async fn main() {
    println!("=== Mashup CLI (Rust) ===");

    ensure_binaries().await;

    let mut rl = Editor::<()>::new();

    // 1. Ask playlist URL
    let playlist_url = rl.readline("Enter YouTube playlist URL: ").unwrap();

    // 2. Ask for download folder (GUI file picker)
    println!("Select download directory...");
    let download_dir = FileDialog::new()
        .set_directory(".")
        .pick_folder()
        .expect("No folder selected");

    // 3. Download audio files
    println!("Downloading playlist...");
    download_playlist(&playlist_url, &download_dir).unwrap();

    // 4. Convert .webm → .mp3
    println!("Converting to MP3...");
    convert_all_to_mp3(&download_dir).unwrap();

    // 5. Let user reorder files
    let mut files = read_mp3_files(&download_dir);
    println!("\nDetected tracks:");
    for (i, f) in files.iter().enumerate() {
        println!("{}: {}", i + 1, f);
    }

    println!("\nEnter new order (e.g. 3 1 2 4 ...):");
    let order_line = rl.readline("> ").unwrap();
    let order: Vec<usize> = order_line
        .split_whitespace()
        .map(|x| x.parse().unwrap())
        .collect();

    let mut ordered_files: Vec<String> = Vec::new();
    for index in order {
        ordered_files.push(files[index - 1].clone());
    }

    // 6. Ask crossfade
    let fade_str = rl.readline("Crossfade seconds (0 = none): ").unwrap();
    let fade: f32 = fade_str.parse().unwrap_or(0.0);

    // 7. Concatenate
    println!("Combining...");
    let output = download_dir.join("final_mashup.mp3");

    if fade == 0.0 {
        concat_no_fade(&ordered_files, &output).unwrap();
    } else {
        concat_with_crossfade(&ordered_files, fade, &output).unwrap();
    }

    println!("Done! Output: {:?}", output);
}

