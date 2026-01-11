# .zshrc
# Managed by ubuntu-terminal-setup

# --- Zinit ---
if [[ ! -f $HOME/.local/share/zinit/zinit.git/zinit.zsh ]]; then
    print -P "%F{33} %F{220}Installing %F{33}ZDHARMA-CONTINUUM%F{220} Initiative Plugin Manager (%F{33}zdharma-continuum/zinit%F{220})…%f"
    command mkdir -p "$HOME/.local/share/zinit" && command chmod g-rwX "$HOME/.local/share/zinit"
    command git clone https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git" && \
        print -P "%F{33} %F{34}Installation successful.%f%b" || \
        print -P "%F{160} The clone has failed.%f%b"
fi

source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# Plugins
zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions

# FZF
if command -v fzf >/dev/null; then
  source <(fzf --zsh)
fi

# --- Starship ---
if command -v starship >/dev/null; then
  eval "$(starship init zsh)"
fi

# --- Config ---
HISTSIZE=50000
SAVEHIST=50000
setopt appendhistory
setopt sharehistory
setopt incappendhistory
setopt histignorealldups

# Keybindings
bindkey -e
bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward

# Aliases
alias ls='ls --color=auto'
alias ll='ls -al'
alias la='ls -A'
alias grep='grep --color=auto'

# Basic Git Aliases (if git plugin not loaded)
alias g='git'
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'

# PATH
export PATH="$HOME/.local/bin:$PATH"

# Editor
export EDITOR='nvim'
export VISUAL='nvim'
