use std::fs;
use std::path::{Path, PathBuf};
use std::process::Command;
use crate::tools::tool_path;

pub fn convert_all_to_mp3(dir: &Path) -> std::io::Result<()> {
    let ffmpeg = tool_path("ffmpeg");

    for entry in fs::read_dir(dir)? {
        let e = entry?;
        let p = e.path();

        if p.extension().unwrap_or_default() == "webm" {
            let out = p.with_extension("mp3");
            Command::new(&ffmpeg)
                .args(["-i", p.to_str().unwrap(), "-y"])
                .arg(out.to_str().unwrap())
                .status()
                .unwrap();

            fs::remove_file(p)?;
        }
    }

    Ok(())
}

pub fn read_mp3_files(dir: &Path) -> Vec<String> {
    let mut out = vec![];
    for entry in fs::read_dir(dir).unwrap() {
        let p = entry.unwrap().path();
        if p.extension().unwrap_or_default() == "mp3" {
            out.push(p.to_str().unwrap().to_string());
        }
    }
    out.sort();
    out
}

pub fn concat_no_fade(files: &Vec<String>, output: &PathBuf) -> std::io::Result<()> {
    let ffmpeg = tool_path("ffmpeg");

    let list_path = output.parent().unwrap().join("list.txt");
    let mut txt = String::new();

    for f in files {
        txt.push_str(&format!("file '{}'\n", f));
    }
    fs::write(&list_path, txt)?;

    Command::new(ffmpeg)
        .args(["-f", "concat", "-safe", "0", "-i"])
        .arg(list_path.to_str().unwrap())
        .args(["-c", "copy"])
        .arg(output.to_str().unwrap())
        .status()
        .unwrap();

    Ok(())
}

pub fn concat_with_crossfade(files: &Vec<String>, fade: f32, output: &PathBuf) -> std::io::Result<()> {
    let ffmpeg = tool_path("ffmpeg");

    // Build complex filter
    let mut filter = String::new();

    for (i, f) in files.iter().enumerate() {
        filter.push_str(&format!("[{i}:a][{i}:a]"));
    }

    // Build filter chain
    let mut cmd = Command::new(ffmpeg);
    for f in files {
        cmd.arg("-i").arg(f);
    }

    let mut filtergraph = String::new();
    filtergraph.push_str(&format!("acrossfade=d={fade}"));

    cmd.args(["-filter_complex", &filtergraph]);
    cmd.arg("-y").arg(output.to_str().unwrap()).status().unwrap();

    Ok(())
}

