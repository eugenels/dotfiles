# dotfiles

## 1. Prerequisites

Linux:
```bash
sudo apt update && sudo apt install -y git curl fish
mkdir -p ~/.local/bin
curl -sS https://starship.rs/install.sh | sh -s -- -b "$HOME/.local/bin" -y
# flox: https://flox.dev/docs/install-flox/
```

macOS:
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew install git fish starship flox
```

## 2. Common

```bash
# bootstrap chezmoi
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$HOME/.local/bin" init --apply eugenels

# fish as login shell
command -v fish | sudo tee -a /etc/shells
chsh -s "$(command -v fish)"

# flox default env
flox init -d "$HOME"
flox edit -d "$HOME" -f ~/.config/flox/manifest.toml
```

## 3. GUI apps

Linux:
```bash
flatpak remote-add --user --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
xargs flatpak install --user -y flathub < ~/.local/share/chezmoi/packages/flatpak.txt
```

macOS:
```bash
brew bundle --file="$HOME/.local/share/chezmoi/packages/Brewfile"
```

## Update

```bash
chezmoi update
flox edit -d "$HOME" -f ~/.config/flox/manifest.toml
```
