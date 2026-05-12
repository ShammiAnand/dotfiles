#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

info()  { printf "\033[1;34m[info]\033[0m  %s\n" "$1"; }
warn()  { printf "\033[1;33m[warn]\033[0m  %s\n" "$1"; }
ok()    { printf "\033[1;32m[ok]\033[0m    %s\n" "$1"; }
fail()  { printf "\033[1;31m[fail]\033[0m  %s\n" "$1"; exit 1; }

link_file() {
    local src="$1" dst="$2"
    if [ -L "$dst" ]; then
        rm "$dst"
    elif [ -f "$dst" ] || [ -d "$dst" ]; then
        warn "Backing up existing $dst -> ${dst}.bak"
        mv "$dst" "${dst}.bak"
    fi
    mkdir -p "$(dirname "$dst")"
    ln -s "$src" "$dst"
    ok "Linked $dst -> $src"
}

# ─── Homebrew ────────────────────────────────────────────────────────────────

setup_brew_env() {
    if [ -x /opt/homebrew/bin/brew ]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [ -x /usr/local/bin/brew ]; then
        eval "$(/usr/local/bin/brew shellenv)"
    elif [ -x /home/linuxbrew/.linuxbrew/bin/brew ]; then
        eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    fi
}

if ! command -v brew &>/dev/null; then
    info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    setup_brew_env
else
    ok "Homebrew already installed"
fi

# ─── Core packages ───────────────────────────────────────────────────────────

BREW_FORMULAE=(
    neovim
    tmux
    ripgrep
    fzf
    bat
    lazygit
    wget
    tree-sitter
    pyenv
)

BREW_CASKS=(
    font-meslo-lg-nerd-font
)

info "Installing brew formulae..."
for pkg in "${BREW_FORMULAE[@]}"; do
    brew list "$pkg" &>/dev/null || brew install "$pkg"
done

if [[ "$(uname)" == "Darwin" ]]; then
    info "Installing brew casks..."
    for cask in "${BREW_CASKS[@]}"; do
        brew list --cask "$cask" &>/dev/null || brew install --cask "$cask"
    done
else
    info "Skipping casks (macOS only)"
fi

ok "Brew packages installed"

# ─── Oh My Zsh ───────────────────────────────────────────────────────────────

if [ ! -d "$HOME/.oh-my-zsh" ]; then
    info "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
    ok "Oh My Zsh already installed"
fi

# Powerlevel10k
P10K_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
if [ ! -d "$P10K_DIR" ]; then
    info "Installing Powerlevel10k..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR"
else
    ok "Powerlevel10k already installed"
fi

# zsh-autosuggestions
ZSH_AS_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"
if [ ! -d "$ZSH_AS_DIR" ]; then
    info "Installing zsh-autosuggestions..."
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_AS_DIR"
else
    ok "zsh-autosuggestions already installed"
fi

# zsh-syntax-highlighting
ZSH_SH_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting"
if [ ! -d "$ZSH_SH_DIR" ]; then
    info "Installing zsh-syntax-highlighting..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_SH_DIR"
else
    ok "zsh-syntax-highlighting already installed"
fi

# ─── NVM ─────────────────────────────────────────────────────────────────────

if [ ! -d "$HOME/.nvm" ]; then
    info "Installing nvm..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
else
    ok "nvm already installed"
fi

# ─── TPM (Tmux Plugin Manager) ──────────────────────────────────────────────

if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
    info "Installing TPM..."
    git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
else
    ok "TPM already installed"
fi

# ─── Symlink configs ────────────────────────────────────────────────────────

info "Symlinking configs..."

link_file "$DOTFILES_DIR/nvim"               "$HOME/.config/nvim"
link_file "$DOTFILES_DIR/tmux/.tmux.conf"    "$HOME/.tmux.conf"
link_file "$DOTFILES_DIR/zsh/.zshrc"         "$HOME/.zshrc"
link_file "$DOTFILES_DIR/zsh/.p10k.zsh"      "$HOME/.p10k.zsh"
link_file "$DOTFILES_DIR/git/.gitconfig"     "$HOME/.gitconfig"

mkdir -p "$HOME/.config/git"
link_file "$DOTFILES_DIR/git/.config/git/ignore" "$HOME/.config/git/ignore"

# ─── Claude Code ────────────────────────────────────────────────────────────

link_file "$DOTFILES_DIR/agents" "$HOME/.agents"

if ! command -v claude &>/dev/null; then
    warn "claude CLI not found. Download from: https://claude.ai/download"
    warn "After install, re-run this script to symlink configs and install plugins."
else
    ok "claude CLI found: $(claude --version 2>/dev/null | head -1)"

    info "Symlinking Claude config..."
    mkdir -p "$HOME/.claude"
    link_file "$DOTFILES_DIR/claude/CLAUDE.md"     "$HOME/.claude/CLAUDE.md"
    link_file "$DOTFILES_DIR/claude/settings.json"  "$HOME/.claude/settings.json"

    info "Installing Claude plugins..."
    CLAUDE_PLUGINS=(
        superpowers@claude-plugins-official
        ralph-loop@claude-plugins-official
        pyright-lsp@claude-plugins-official
    )
    for plugin in "${CLAUDE_PLUGINS[@]}"; do
        claude plugin install "$plugin" -s user && ok "Installed $plugin" || warn "Failed to install $plugin (may already be installed)"
    done
fi

# ─── Post-install ────────────────────────────────────────────────────────────

info "LazyVim plugins will bootstrap on first nvim launch."
info "Run 'tmux' then press prefix + I to install tmux plugins via TPM."

echo ""
ok "Done! Restart your terminal or run: exec zsh"
