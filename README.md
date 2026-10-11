# dotfiles

Minimal shared setup for an Apple Silicon Mac and Pop!_OS with COSMIC.
Flox owns portable CLI tools; Homebrew/apt own host dependencies;
Homebrew/Flatpak own GUI apps. Pop!_OS provides Flatpak.

## Bootstrap

Install [Flox](https://flox.dev/docs/install-flox/) first on Linux.

```sh
# Pop!_OS
sudo apt update && sudo apt install -y git curl

# macOS: install Homebrew first (https://brew.sh)
eval "$(/opt/homebrew/bin/brew shellenv)"
brew install git
```

Then, on either machine:

```sh
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$HOME/.local/bin" init --apply eugenels
```

Run from a terminal: setup requires sudo. Required steps fail rather than
silently skipping; fix the error and rerun `~/.local/bin/chezmoi apply`.
Open a new terminal for fish and the home Flox environment.

Scripts install packages, configure Flox, install Pi extensions and herdr
integrations, and select fish as the login shell. Syncthing starts as a user
service; its UI is at http://localhost:8384.

## Apply and update

```sh
chezmoi apply       # apply local configuration changes
dotfiles-update    # pull dotfiles, apply, then upgrade installed packages
```

`dotfiles-update` upgrades Homebrew or apt + user Flatpaks, the home Flox
environment, and Pi extensions, then refreshes herdr integrations. It stops
on failure. Commit local dotfile edits before updating; divergent Git history
requires an explicit merge or rebase.

Unpinned packages track the latest versions available from their configured
repositories, not necessarily upstream releases. Flox packages have separate
groups so one package doesn't hold back the others. Explicit version pins
remain intentional; the font archive is pinned and checksummed. Flox owns Pi
itself, so only its extensions are updated through Pi.

Removing a package from a list does not uninstall it. Remove obsolete packages
explicitly; setup migrates the old `pi-herdr` extension without touching other
user-installed extensions.

## Fonts

JetBrainsMono Nerd Font comes from Homebrew on macOS and a checksummed external
archive on Linux. To bump Linux fonts, update the URL and SHA-256 in
`.chezmoiexternal.toml.tmpl`, then run `chezmoi apply --refresh-externals`.

## Machine-local state

Flox runtime config, Pi settings, and SSH keys stay outside this repository.
Generate `~/.ssh/id_ed25519` on each machine and register its public key with
GitHub. GitHub CLI manages its credentials; commands needing a token can use
`GITHUB_TOKEN=$(gh auth token) command` rather than exporting it to every process.
Zed requires per-project trust and uses its agent's default permission mode.

Project toolchains are separate. The QuestDB setup is synced through Syncthing:

```sh
~/Syncthing/dev-setup/questdb/bootstrap.sh
```
