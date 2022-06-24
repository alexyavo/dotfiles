#!/usr/bin/env bash

export DOTFILES_HOME=$HOME/dotfiles

if [ "$(uname)" == "Darwin" ]; then
    cp=/usr/local/opt/coreutils/bin/gcp
else
    cp=cp
fi

# ugh....
declare -a blacklist=(
    "$DOTFILES_HOME/.git"
    "$DOTFILES_HOME/README.md"
    "$DOTFILES_HOME/install.sh"
    "$DOTFILES_HOME/alacritty-windows.yml"
)

function maybe-link {
    f=$1
    blacklisted=$(echo ${blacklist[@]} | grep -o "$f" | wc -w)
    if [ "$blacklisted" -eq "0" ]; then
        echo "... linking $(basename $f)"
        $cp -rsf $f ~
    fi
}

# covers only actual dotfiles...
for f in "$DOTFILES_HOME"/.[^.]*;
do
    maybe-link $f
done

# in case there are non-dot files...
for f in "$DOTFILES_HOME"/*;
do
    maybe-link $f
done

if grep -qEi "(Microsoft|WSL)" /proc/version &> /dev/null; then
    echo "... copying alacritty-windows.yml to /mnt/c/Users/$USER/Appdata/Roaming/alacritty/"
    $cp $DOTFILES_HOME/alacritty-windows.yml /mnt/c/Users/$USER/Appdata/Roaming/alacritty/alacritty.yml

    echo "... copying .vsvimrc to /mnt/c/Users/$USER/"
    $cp $DOTFILES_HOME/.vsvimrc /mnt/c/Users/$USER/.vsvimrc
fi
