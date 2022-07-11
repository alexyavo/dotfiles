#!/usr/bin/env python3

import os
import sys
import pathlib
import subprocess
import getpass
from abc import ABC, abstractmethod
from typing import Optional


USE_DOOM_EMACS=True

USER = getpass.getuser()


def is_darwin() -> bool:
    return sys.platform == "Darwin"


def is_wsl() -> bool:
    res = subprocess.getoutput("cat /proc/version")
    return "Microsoft" in res or "WSL" in res


def get_cp_cmd() -> str:
    return "/usr/local/opt/coreutils/bin/gcp" if is_darwin() else "cp"


def fail(msg: str) -> None:
    print(msg)
    exit(-1)


class Action(ABC):
    @abstractmethod
    def perform(self, f: pathlib.Path) -> None:
        pass


class NOOPAction(Action):
    def perform(self, f: pathlib.Path) -> None:
        print(f"... skpping {f.name}")


NOOP = NOOPAction()


class LINKAction(Action):
    def perform(self, f: pathlib.Path) -> None:
        print(f"... linking {f.name}")
        # -r: Recursive, create the necessary directory for each file
        # -s: Create symlinks instead of copying
        # -f: Overwrite existing files (previously created symlinks, default .bashrc, etc)
        res = subprocess.run([get_cp_cmd(), "-rsf", str(f.absolute()), str(pathlib.Path.home())])
        if res.returncode != 0:
            fail(f"failed to link {f.name}, code: {res.returncode}")


LINK = LINKAction()


class COPY(Action):
    def __init__(self, to: str, new_fname: Optional[str] = None) -> None:
        self.to = pathlib.Path(to)

        if self.to.exists() and (not self.to.is_dir):
            fail(f"dst {self.to.absolute()} exists, but is not a directory")

        if not self.to.exists():
            print(f"creating dst {self.to.absolute()} ...")
            os.makedirs(self.to.absolute())

        if new_fname is not None:
            self.to = pathlib.Path(to + "/" + new_fname)

    def perform(self, f: pathlib.Path) -> None:
        print(f"... copying {f.name} to {self.to.absolute()}")
        res = subprocess.run([get_cp_cmd(), str(f.absolute()), str(self.to.absolute())])
        if res.returncode != 0:
            fail(f"failed to copy {f.name} to {self.to.absolute()}, code: {res.returncode}")


def COPY_IF_WSL(*args, **kwargs) -> Action:
    return COPY(*args, **kwargs) if is_wsl() else NOOP


if __name__ == '__main__':
    default_action = LINK

    actions = {
        ".git"                  : NOOP,
        "README.md"             : NOOP,
        "install.sh"            : NOOP,
        ".emacs.d"              : NOOP if USE_DOOM_EMACS else LINK,
        ".doom.d"               : LINK if USE_DOOM_EMACS else NOOP,
        "alacritty-windows.yml" : COPY_IF_WSL(f"/mnt/c/Users/{USER}/Appdata/Roaming/alacritty/", "alacritty.yml"),
        ".vsvimrc"              : COPY_IF_WSL(f"/mnt/c/Users/{USER}/"),
    }

    cwd: pathlib.Path = pathlib.Path().resolve()
    for f in cwd.iterdir():
        actions.get(f.name, default_action).perform(f)
