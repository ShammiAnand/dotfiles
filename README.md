# dotfiles

Personal development environment config for macOS.

## What's included

| Component | Config location | Description |
|-----------|----------------|-------------|
| **Neovim** | `nvim/` | LazyVim-based setup -- kanagawa theme, telescope, copilot, treesitter, mason, vim-tmux-navigator |
| **tmux** | `tmux/.tmux.conf` | C-a prefix, vim keybindings, Dracula pane styling, resurrect + continuum |
| **Zsh** | `zsh/.zshrc` | Oh My Zsh with powerlevel10k, autosuggestions, syntax highlighting, lazy-loaded nvm/pyenv |
| **p10k** | `zsh/.p10k.zsh` | Pure-style prompt, nerdfont, transient prompt |
| **Git** | `git/` | Global gitconfig and ignore |

## Install

```bash
git clone https://github.com/ShammiAnand/dotfiles.git ~/dotfiles
cd ~/dotfiles
chmod +x install.sh
./install.sh
```

The install script is idempotent -- safe to run multiple times. It will:

- Install Homebrew (if missing)
- Install core tools: neovim, tmux, ripgrep, fzf, bat, lazygit, wget, tree-sitter, pyenv
- Install MesloLGS Nerd Font
- Install Oh My Zsh + powerlevel10k + plugins
- Install nvm
- Install TPM (tmux plugin manager)
- Symlink all configs (backs up existing files to `*.bak`)

## Post-install

- Open `nvim` -- LazyVim plugins install automatically on first launch.
- Open `tmux` and press `prefix + I` to install tmux plugins via TPM.
- Run `p10k configure` if you want to re-customize the prompt.
