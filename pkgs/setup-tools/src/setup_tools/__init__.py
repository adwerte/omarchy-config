import argparse
import os
import shutil
import tomllib
from pathlib import Path
from typing import Any

import tomli_w


def setup_windows() -> None:
    parser = argparse.ArgumentParser(
        prog="Windows Setup Tool",
        description=(
            "Copy the configuration in <config> into the APPDATA "
            "folder on Windows, or into a debug folder on other systems"
        ),
    )
    parser.add_argument("config", help="Config folder location")
    parser.add_argument(
        "-do",
        "--debug-output",
        help="output location on non-Windows systems (default: %(default)s)",
        type=str,
        default="./temp/",
    )

    args = parser.parse_args()
    config = Path(args.config)
    debug_output = Path(args.debug_output)

    # Non-Windows systems write to the debug directory instead of APPDATA
    if os.name == "nt":
        appdata_folder = Path(os.environ["APPDATA"])
    else:
        appdata_folder = debug_output

    folders = config.glob("**/.config/*")
    for folder in folders:
        if not folder.is_dir():
            continue

        # Copy the folder into the target, flattening the structure to match Windows.
        target_folder = appdata_folder / folder.name
        shutil.copytree(folder, target_folder, dirs_exist_ok=True)

        # Promote Windows-specific TOML settings to the defaults.
        toml_files = target_folder.glob("**/*.toml")
        for toml_file in toml_files:
            toml = tomllib.loads(toml_file.read_text())
            toml = _convert_to_windows(toml)
            toml_file.write_text(tomli_w.dumps(toml))


def _convert_to_windows(toml: dict[str, Any] | Any) -> dict[str, Any] | Any:
    """Promote '*_windows' keys to their unsuffixed names, in place."""
    if not isinstance(toml, dict):
        return toml

    original_keys = list(toml.keys())
    for key in original_keys:
        if not key.endswith("_windows"):
            _convert_to_windows(toml[key])
            continue

        value = toml.pop(key)
        new_key = key.removesuffix("_windows")
        toml[new_key] = value

        _convert_to_windows(toml[new_key])

    return toml
