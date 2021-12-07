use std::{env, fs, path::PathBuf};
use walkdir::WalkDir;

fn walk_dir_and_copy(src_dir: &str, dst_dir: &str) {
    let dst_folder_name = String::from(
        PathBuf::from(&dst_dir)
            .file_name()
            .unwrap()
            .to_str()
            .unwrap(),
    );

    for entry in WalkDir::new(src_dir)
        .max_depth(1)
        .into_iter()
        .filter_map(Result::ok)
        .skip(1)
    {
        let mut dst = PathBuf::from(dst_dir);
        dst.push(entry.file_name());

        if entry.file_type().is_file() {
            if entry.file_name().to_str().unwrap().contains("Cargo.toml") {
                let content = fs::read_to_string(entry.path()).unwrap();
                let content = content.replace("{}", &dst_folder_name);
                fs::write(dst, content).unwrap();
            } else {
                fs::copy(entry.path(), dst).unwrap();
            }
        } else if entry.file_type().is_dir() {
            fs::create_dir(&dst).unwrap();
            walk_dir_and_copy(entry.path().to_str().unwrap(), dst.to_str().unwrap());
        }
    }
}

fn main() {
    let day = env::args().nth(1).expect("expects day number as first arg");
    let day_dir = format!("day{}", day);
    fs::create_dir(&day_dir).unwrap();

    let template_dir = format!("{}/{}", env!("CARGO_MANIFEST_DIR"), "src/template/");

    walk_dir_and_copy(&template_dir, &day_dir);
}
