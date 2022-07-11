#!/usr/bin/env python3

import sys
import pathlib
import subprocess
import getpass
from abc import ABC, abstractmethod


USE_DOOM_EMACS=True

USER = getpass.getuser()
WIN_HOME = f"/mnt/c/Users/{USER}/AppData/Roaming/"


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


class LST(Action):
    def __init__(self, *actions: Action):
        self.actions = actions

    def perform(self, f: pathlib.Path) -> None:
        for a in self.actions:
            a.perform(f)


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
    def __init__(self, to: str) -> None:
        self.to = pathlib.Path(to)
        if not(self.to.is_dir and self.to.exists()):
            fail(f'copy dst {self.to.absolute()} must be an existing directory')

    def perform(self, f: pathlib.Path) -> None:
        print(f"... copying {f.name} to {self.to.absolute()}")
        # -L option copies sym links as regular folders / files
        # (e.g. "mycode" under .emacs.d that is referenced by .doom.d)
        res = subprocess.run([get_cp_cmd(), "-rL", str(f.absolute()), str(self.to.absolute())])
        if res.returncode != 0:
            fail(f"failed to copy {f.name} to {self.to.absolute()}, code: {res.returncode}")


def COPY_IF_WSL(to: str) -> Action:
    return COPY(to) if is_wsl() else NOOP


if __name__ == '__main__':
    default_action = LINK

    # on WSL we want to both link & copy to windows home, on non-WSL just link
    # what we're linking/copying is listed as the "key" below
    # (that's what's passed as the param to perform)
    EMACS = LST(LINK, COPY(WIN_HOME)) if is_wsl() else LINK

    actions = {
        ".git"                  : NOOP,
        "README.md"             : NOOP,
        "install.sh"            : NOOP,
        ".emacs.d"              : NOOP if USE_DOOM_EMACS else EMACS,
        ".doom.d"               : EMACS if USE_DOOM_EMACS else NOOP,
        "alacritty-windows.yml" : COPY_IF_WSL(f"{WIN_HOME}/alacritty/"),
        ".vsvimrc"              : COPY_IF_WSL(f"/mnt/c/Users/{USER}/"),
    }

    cwd: pathlib.Path = pathlib.Path().resolve()
    for f in cwd.iterdir():
        actions.get(f.name, default_action).perform(f)
