# dotfiles

## 1. Prerequisites

Linux:
```bash
sudo apt update && sudo apt install -y git curl
mkdir -p ~/.local/bin
curl -sS https://starship.rs/install.sh | sh -s -- -b "$HOME/.local/bin" -y
# flox: https://flox.dev/docs/install-flox/
```

`fish` and `syncthing` are installed from `packages/apt.txt` on the first
`chezmoi apply` and kept in sync afterwards, as the Brewfile does on macOS.

macOS:
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew install git fish starship flox
```

## 2. Bootstrap

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$HOME/.local/bin" init --apply eugenels
```

`init --apply` runs the scripts in `.chezmoiscripts`: packages, the home flox
env, pi extensions, the herdr Claude integration, fish as the login shell.
Steps that need `sudo` are skipped in a non-interactive shell; re-run
`chezmoi apply` from a terminal to pick them up.

The equivalent manual steps, for reference:

```bash
# fish as login shell
command -v fish | sudo tee -a /etc/shells
chsh -s "$(command -v fish)"

# home flox env
flox init -d "$HOME"
flox edit -d "$HOME" -f ~/.config/flox/manifest.toml
```

## 3. Project environments

Project toolchains are not dotfiles and are not in this repo. The questdb one
is synced via Syncthing and bootstrapped with:

```bash
~/Syncthing/dev-setup/questdb/bootstrap.sh
```

## 4. Fonts

JetBrainsMono Nerd Font is installed automatically on both platforms: the
`font-jetbrains-mono-nerd-font` cask on macOS, `.chezmoiexternal.toml` on
Linux (Nerd Fonts are not in the apt repos).

The Linux external is version-pinned and checksummed. To bump it, edit the URL
in `.chezmoiexternal.toml.tmpl` and refresh the hash:

```bash
curl -sSL <new-url> | sha256sum
chezmoi apply --refresh-externals
```

## 5. GUI apps

Applied automatically; shown here for manual re-runs.

Linux:
```bash
flatpak remote-add --user --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
xargs flatpak install --user -y flathub < ~/.local/share/chezmoi/packages/flatpak.txt
```

macOS:
```bash
brew bundle --file="$HOME/.local/share/chezmoi/packages/Brewfile"
```

Syncthing starts as a user service on both (launchd / systemd --user); web UI
at http://localhost:8384.

## 6. Update

```bash
chezmoi update
```
