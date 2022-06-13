# Install

`cp` should be the GNU variant. 
on macos run `brew install coreutils` and use ` /usr/local/Cellar/coreutils/9.1/bin/gcp`

```
export dotfiles_home=~/dotfiles
cp -rsf "$dotfiles_home"/. ~
```

```
-r: Recursive, create the necessary directory for each file
-s: Create symlinks instead of copying
-f: Overwrite existing files (previously created symlinks, default .bashrc, etc)
/.: Make sure cp "copy" the contents of home instead of the home directory itself.
```

