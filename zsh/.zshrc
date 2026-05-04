# 1. POWERLEVEL10K INSTANT PROMPT (Keep at the absolute top)
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# 2. PATHS & EXPORTS
export ZSH="$HOME/.oh-my-zsh"
export PYENV_ROOT="$HOME/.pyenv"
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export HOMEBREW_NO_AUTO_UPDATE=1
export HOMEBREW_NO_ENV_HINTS=1

# 3. OH MY ZSH CONFIGURATION
ZSH_THEME="powerlevel10k/powerlevel10k"
zstyle ':omz:update' mode disabled

plugins=(git zsh-autosuggestions zsh-syntax-highlighting web-search)

ZSH_COMPDUMP="$HOME/.zcompdump"

source $ZSH/oh-my-zsh.sh

# 4. ALIASES
alias claude="claude --dangerously-skip-permissions"
alias c="claude --dangerously-skip-permissions"

# 5. OPTIMIZED PYENV LOADING
if [[ -d $PYENV_ROOT/bin ]]; then
  export PATH="$PYENV_ROOT/bin:$PATH"
  eval "$(pyenv init --path)"
  pyenv() {
    unset -f pyenv
    eval "$(command pyenv init -)"
    pyenv "$@"
  }
fi

# 6. LAZY LOAD NVM
export NVM_DIR="$HOME/.nvm"
[ -z "$XDG_CONFIG_HOME" ] || export NVM_DIR="$XDG_CONFIG_HOME/nvm"
nvm() {
    unset -f nvm node npm npx
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    nvm "$@"
}
node() { nvm && node "$@" }
npm() { nvm && npm "$@" }
npx() { nvm && npx "$@" }

# 7. THEME CUSTOMIZATION
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# 8. SPEEDFIX: Re-compile zcompdump if it's old (prevents 0.5s lag)
autoload -Uz compinit
if [ $(date +%j) != $(stat -f '%Sm' -t '%j' "$ZSH_COMPDUMP") ]; then
  compinit
else
  compinit -C
fi
