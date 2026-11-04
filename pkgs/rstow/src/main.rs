use std::fs;
use std::io;
use std::{env::var, fs::read_dir, path::Path};
fn main() {
    let cargo_location = match var("CARGO_MANIFEST_DIR") {
        Ok(value) => value,
        Err(_value) => panic!("CARGO_MANIFEST_DIR not found"),
    };
    let cargo_path = Path::new(&cargo_location);
    let Some(repo_path) = cargo_path.parent() else {
        panic!("repo_path not found")
    };
    let config_path = repo_path.join("config");
    println!("{:?}", config_path);

    let appdata_folder = match var("APPDATA") {
        Ok(value) => value,
        Err(_value) => panic!("APPDATA not found"),
    };
    let appdata_path = Path::new(&appdata_folder);

    let paths = read_dir(config_path).unwrap();
    for path in paths {
        let dir_entry = path.unwrap();
        println!("====== copying ======");
        println!("{:?}", dir_entry);
        println!("to");
        let target_location = appdata_path.join(dir_entry.file_name());
        println!("{:?}", target_location);
        copy_dir_all(dir_entry.path(), target_location).unwrap();
    }
}
fn copy_dir_all(src: impl AsRef<Path>, dst: impl AsRef<Path>) -> io::Result<()> {
    fs::create_dir_all(&dst)?;
    for entry in fs::read_dir(src)? {
        let entry = entry?;
        let ty = entry.file_type()?;
        if ty.is_dir() {
            copy_dir_all(entry.path(), dst.as_ref().join(entry.file_name()))?;
        } else {
            fs::copy(entry.path(), dst.as_ref().join(entry.file_name()))?;
        }
    }
    Ok(())
}
