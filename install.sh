#!/usr/bin/env bash
set -euo pipefail
# Yes iknow, iknow, ai code bad. I can't write shell scripts, sorry!
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FILES_DIR="$SCRIPT_DIR/files"
BACKUP_DIR="$HOME/oldconfigs"

backup_if_exists() {
    local src="$1"
    if [[ -e "$src" ]]; then
        mkdir -p "$BACKUP_DIR"
        local name
        name="$(basename "$src")_$(date +%Y%m%d_%H%M%S)"
        echo "  backing up $(basename "$src") → ~/oldconfigs/$name"
        cp -r "$src" "$BACKUP_DIR/$name"
    fi
}

echo "==> Installing oh-my-zsh..."
# RUNZSH=no prevents it from launching zsh and ending the script early
RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

echo ""
echo "==> Copying config files..."

# .zshrc → ~/
backup_if_exists "$HOME/.zshrc"
cp "$FILES_DIR/.zshrc" "$HOME/.zshrc"
echo "  copied .zshrc → ~/"

# kitty → ~/.config/kitty
backup_if_exists "$HOME/.config/kitty"
mkdir -p "$HOME/.config"
cp -r "$FILES_DIR/kitty" "$HOME/.config/"
echo "  copied kitty → ~/.config/kitty"

# fastfetch → ~/.config/fastfetch
backup_if_exists "$HOME/.config/fastfetch"
cp -r "$FILES_DIR/fastfetch" "$HOME/.config/fastfetch"
echo "  copied fastfetch → ~/.config/fastfetch"

echo ""
echo "==> Cloning zsh plugins..."

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

clone_plugin() {
    local repo="$1"
    local dest="$2"
    if [[ -d "$dest" ]]; then
        echo "  already exists, skipping: $(basename "$dest")"
    else
        git clone --depth=1 "$repo" "$dest"
    fi
}

clone_plugin https://github.com/zsh-users/zsh-autosuggestions             "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
clone_plugin https://github.com/zsh-users/zsh-completions                 "$ZSH_CUSTOM/plugins/zsh-completions"
clone_plugin https://github.com/zsh-users/zsh-history-substring-search    "$ZSH_CUSTOM/plugins/zsh-history-substring-search"
clone_plugin https://github.com/zdharma-continuum/fast-syntax-highlighting "$ZSH_CUSTOM/plugins/fast-syntax-highlighting"
clone_plugin https://github.com/hlissner/zsh-autopair                     "$ZSH_CUSTOM/plugins/zsh-autopair"
clone_plugin https://github.com/MichaelAquilina/zsh-you-should-use        "$ZSH_CUSTOM/plugins/you-should-use"

echo ""
echo "==> Sourcing ~/.zshrc..."
# shellcheck disable=SC1090
source "$HOME/.zshrc" 2>/dev/null || true

echo ""
echo "==> Changing default shell to zsh..."
chsh -s "$(which zsh)"

echo ""
echo "✓ Done. Log out and back in for the shell change to take effect."
