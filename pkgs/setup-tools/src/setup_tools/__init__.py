import tomli_w
import tomllib
import argparse
from pathlib import Path
import logging


def setup_windows() -> None:
    parser = argparse.ArgumentParser("Windows Setup Tool")
    parser.add_argument("config", help = "Config folder location")

    args = parser.parse_args()
    config = Path(args.config)
    folders = config.glob('*')
    for folder in folders:
        toml_files = folder.glob("**/*.toml")
        for toml_file in toml_files:
            print(toml_file)


    
    # if not os.name == 'nt':
    #     raise ValueError("expected windows as the operating system ")



def _black_toml(search_folder : Path):
    "This function reads all the tomls in subfolders and formats them."
    logger = logging.getLogger("black_toml")
    logger.propagate = True
    toml_files = search_folder.glob("**/*.toml")
    for toml_file in toml_files:
        toml = tomllib.loads(toml_file.read_text())
        logger.info(toml)
        toml_file.write_text(tomli_w.dumps(toml))


def black_toml() -> None:
    parser = argparse.ArgumentParser("Black on Tomls")
    parser.add_argument("folder", help = "folder to search for tomls")

    args = parser.parse_args()
    _black_toml(Path(args.folder))
    

    
