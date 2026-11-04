import tomli_w
import tomllib
import os
import argparse
from pathlib import Path
import shutil
from typing import Any


def setup_windows() -> None:
    parser = argparse.ArgumentParser("Windows Setup Tool", "This method moves the configuration files in <config> into the APPDATA folder on windows, and moves it into a temporary folder on other systems.")
    parser.add_argument("config", help = "Config folder location")
    parser.add_argument("-do", "--debug-output", help = "Debug output location for non windows functions.", type=str, default="./temp/")

    args = parser.parse_args()
    config = Path(args.config)
    debug_output = Path(args.debug_output)

    # On non-windows systems we use the debug path.
    if os.name == "nt":
        appdata_folder = Path(os.getenv('APPDATA'))
    else:
        appdata_folder = debug_output

    folders = config.glob('**/.config/*')
    for folder in folders:
        if not folder.is_dir():
            continue

        # 1. We copy the folders into the target folder, changing the structure to fit with windows.
        target_folder = appdata_folder / folder.name
        shutil.copytree(folder, target_folder, dirs_exist_ok=True)

        # 2. We change the toml files such any settings specific for windows systems are changed to be the default.
        toml_files = target_folder.glob("**/*.toml")
        for toml_file in toml_files:
            toml = tomllib.loads(toml_file.read_text())
            toml = _convert_to_windows(toml)
            toml_file.write_text(tomli_w.dumps(toml))

def _convert_to_windows(toml : dict[str, Any] | Any) -> dict[str, Any] | Any:
    "This function removes all keys with the name ending with _windows and inserts them in the stripped name."
    if not isinstance(toml, dict):
        return toml

    original_keys = list(toml.keys())
    for key in original_keys:
        if not key.endswith("_windows"):
            _convert_to_windows(toml[key])
            continue

        value = toml.pop(key)
        new_key = key.strip("_windows")
        toml[new_key] = value

        _convert_to_windows(toml[new_key])

    return toml
    





    

    
