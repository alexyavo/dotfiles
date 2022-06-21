# startup profiling commands
#zmodload zsh/zprof  # put this at the start of the file when profile
#zprof  # put this at the end of the file when profile

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes

#ZSH_THEME="robbyrussell"
#ZSH_THEME="bira"
ZSH_THEME="tjkirch"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to automatically update without prompting.
# DISABLE_UPDATE_PROMPT="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# Caution: this setting can cause issues with multiline prompts (zsh 5.7.1 and newer seem to work)
# See https://github.com/ohmyzsh/ohmyzsh/issues/5765
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
plugins=(
    git
    fzf
    pj
)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
export EDITOR='vim'

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# pj (Project Jump) zsh plugin conf
# https://git.esiee.fr/dewaelen/dotfiles/blob/b672fcfc68897e2b4a4d808b52597374064efccb/zsh/oh/plugins/pj/README.md
# ====================================================================================================
PROJECT_PATHS=(
    ~/code
)

# utils
alias ll="ls -alhtr"
alias grep="grep -i"

function jwt {
    jq -R 'split(".") | .[1] | @base64d | fromjson' <<< "$JWT"
}

function hex-b64 {
    echo "-- // hexdump START"
    echo "$1" | base64 -dD | xxd
    echo "-- // hexdump END"
}

# git
alias git=hub
alias gpull="git pull"
alias glog="git log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(bold yellow)%d%C(reset)' --all"
alias gstat="git status"
alias gshow="git show"
alias gdiff="git diff"
alias gclone="git clone"
alias gadd="git add"
alias gmast="git checkout master"
alias ghard="git reset --hard"
alias gtop="git log | grep Author | sort | uniq -c | sort -n -r"
alias gprls="git pr list -f '[%pC%>(10)%au %U%Creset] %t% l%n'"
alias git-delete-remote-tags="git tag -l | xargs -n 1 git push --delete origin"
alias git-delete-local-tags="git tag | xargs git tag -d"
alias git-delete-tags="git-delete-remote-tags && git-delete-local-tags"
alias github-delete-drafts="hub release -f \"%T (%S) %n\" --include-drafts | grep \" (draft)\" | awk '{print $1}' | xargs -t -n1 hub release delete"
unalias gsta # default alias for "git stash" that conflicts with gstat typo

function gpushall {
    local branch=$(eval git branch --show-current)
    git add . &&
        git commit --amend --no-edit &&
        git push -f origin $branch
}

function gpush {
    git push origin $(eval git branch --show-current)
}

# emacs
if [[ `uname` == "Darwin" ]]; then
    export PATH=/Applications/Emacs.app/Contents/MacOS/bin:$PATH # emacs 27 (railwaycat fork)
fi
alias ec="emacsclient -nw"

# docker
alias docker-clean="docker system prune -f"
alias docker-rm-stopped="docker container prune"
alias docker-rm-all='docker stop $(docker ps -aq) && docker rm $(docker ps -aq)'

# docker-compose
alias dcu="docker-compose up"
alias dcd="docker-compose down"

function load-nvm {
    export NVM_DIR="$HOME/.nvm"
    [ -s "/usr/local/opt/nvm/nvm.sh" ] && . "/usr/local/opt/nvm/nvm.sh"  # This loads nvm
    #   [ -s "/usr/local/opt/nvm/etc/bash_completion.d/nvm" ] && . "/usr/local/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion
    nvm use --lts
}

function load-pyenv {
    eval "$(pyenv init --path)"
}

function load-golang {
    if [[ `uname` == "Darwin" ]]; then
        # golang
        export GOPATH=$HOME/go
        export GOROOT="$(brew --prefix golang)/libexec"
        export PATH="$PATH:${GOPATH}/bin:${GOROOT}/bin"
    fi
}

function load-sdkman {
    export SDKMAN_DIR="$HOME/.sdkman"
    [[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
}

function load-ruby {
    if [[ `uname` == "Darwin" ]]; then
        # ruby
        export PATH="/usr/local/opt/ruby/bin:/usr/local/lib/ruby/gems/3.0.0/bin:$PATH"
    elif [[ `uname` == "Linux" ]]; then
        # Install Ruby Gems to ~/gems
        export GEM_HOME="$HOME/gems"
        export PATH="$HOME/gems/bin:$PATH"
    fi
}

