# dotfiles

## 1. Prerequisites

Linux:
```bash
sudo apt update && sudo apt install -y git curl
mkdir -p ~/.local/bin
curl -sS https://starship.rs/install.sh | sh -s -- -b "$HOME/.local/bin" -y
# flox: https://flox.dev/docs/install-flox/
```

`fish` and `syncthing` don't need to be installed manually — `packages/apt.txt`
is applied automatically on the first `chezmoi apply` below (and kept in sync
on every later one), same as the Brewfile does on macOS.

macOS:
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew install git fish starship flox
```

## 2. Common

```bash
# bootstrap chezmoi
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$HOME/.local/bin" init --apply eugenels
```

`init --apply` already does everything below — installs packages, sets fish as
the login shell, and creates the flox env — via the scripts in
`.chezmoiscripts`. The commands are listed here for reference, or to re-run a
piece by hand if a step was skipped (e.g. no `sudo` in a non-interactive
shell):

```bash
# fish as login shell
command -v fish | sudo tee -a /etc/shells
chsh -s "$(command -v fish)"

# flox default env
flox init -d "$HOME"
flox edit -d "$HOME" -f ~/.config/flox/manifest.toml
```

## 3. Fonts

JetBrainsMono Nerd Font is installed automatically on both platforms — via the
`font-jetbrains-mono-nerd-font` cask on macOS, and via `.chezmoiexternal.toml`
on Linux (Nerd Fonts aren't in the apt repos, so they can't go in `apt.txt`).

The Linux external is version-pinned and checksummed. To bump it, edit the URL
in `.chezmoiexternal.toml.tmpl` and refresh the hash:

```bash
curl -sSL <new-url> | sha256sum
chezmoi apply --refresh-externals
```

## 4. GUI apps

Also applied automatically by `init --apply`; shown here for manual re-runs.

Linux:
```bash
flatpak remote-add --user --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
xargs flatpak install --user -y flathub < ~/.local/share/chezmoi/packages/flatpak.txt
# syncthing starts as a systemd --user service automatically;
# web UI at http://localhost:8384
```

macOS:
```bash
brew bundle --file="$HOME/.local/share/chezmoi/packages/Brewfile"
# syncthing starts as a launchd service automatically (restart_service);
# web UI at http://localhost:8384
```

## 5. Update

```bash
chezmoi update
flox edit -d "$HOME" -f ~/.config/flox/manifest.toml
```
