# Doom Emacs on Windows

- https://alpha.gnu.org/gnu/emacs/windows/emacs-28.0.91.zip
- https://github.com/msys2/msys2-installer/releases/download/2022-06-03/msys2-x86_64-20220603.exe

- clone doom to `AppData\Roamin`:

``` shell
git clone https://github.com/hlissner/doom-emacs ~/.emacs.d
```

- upgrade pacman: `pacman -Syu`

- can't run `doom install` b/c `libgccjit` is missing; will install it via `msysy2`:

``` shell
pacman -S mingw-w64-x86_64-libgccjit
```

- install `find` (projectile [other things too?] doesn't work otherwise): `pacman -S mingw-x64-x86_64-fd`

## Set Path
(Advanced System Settings" in search)

add:
  1. `C:\emacs-28.0.91\bin` (or w/e version)
  2. `C:\msys64\mingw64\bin`
  3. `...\AppData\Roaming\.emacs.d\bin`
