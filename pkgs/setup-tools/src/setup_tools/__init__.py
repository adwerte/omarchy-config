import tomli_w
import tomllib
import os
import argparse
from pathlib import Path
import logging
import shutil
from typing import Any


def setup_windows() -> None:
    parser = argparse.ArgumentParser("Windows Setup Tool")
    parser.add_argument("config", help = "Config folder location")

    if os.name == "nt":
        appdata_folder = Path(os.getenv('APPDATA'))
    else:
        appdata_folder = Path('./temp/')

    args = parser.parse_args()
    config = Path(args.config)
    folders = config.glob('**/.config/*')
    for folder in folders:
        if not folder.is_dir():
            continue

        target_folder = appdata_folder / folder.name
        shutil.copytree(folder, target_folder, dirs_exist_ok=True)

        toml_files = target_folder.glob("**/*.toml")
        for toml_file in toml_files:
            toml = tomllib.loads(toml_file.read_text())
            toml = _convert_to_windows(toml)
            toml_file.write_text(tomli_w.dumps(toml))

def _convert_to_windows(toml : dict[str, Any] | Any) -> dict[str, Any] | Any:
    if not isinstance(toml, dict):
        return toml

    original_keys = list(toml.keys())
    for key in original_keys:
        if key.endswith("_windows"):
            continue
        try:
            value = toml.pop(key + "_windows")
            toml[key] = value
        except KeyError:
            _convert_to_windows(toml[key])

    return toml
    





    

    
