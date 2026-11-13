# dotfiles

Minimal shared setup for an Apple Silicon Mac and Pop!_OS with COSMIC.
Flox owns portable CLI tools; Homebrew/apt own host dependencies;
Homebrew/Flatpak own GUI apps. Pop!_OS provides Flatpak. The Herdr desktop app
is not on Flathub, so Linux uses its upstream installer.

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
service; its UI is at http://localhost:8384. On x86_64 Linux, Ollama (Flox
`ollama-rocm`) runs as a user service at http://localhost:11434 and keeps models
loaded; `dotfiles-update` restarts it after upgrades. Handy's post-processing
uses its `dictation-cleanup` model, which setup rebuilds whenever the
machine-local `~/.config/ollama/Modelfile.dictation-cleanup` changes.

## Apply and update

```sh
chezmoi apply       # apply local configuration changes
dotfiles-update    # upgrade chezmoi, pull and apply dotfiles, upgrade packages
```

`dotfiles-update` upgrades chezmoi, Homebrew or apt + user Flatpaks, the home
Flox environment, and Pi extensions, then refreshes herdr integrations. It stops
on failure. On Linux, setup installs the Herdr desktop app only when missing;
the app updates itself and herdr-core, so `dotfiles-update` leaves it alone.
`chezmoi update` pulls with `--autostash --rebase`, overriding `pull.ff=only`:
unpushed dotfile commits are rebased onto the remote, stopping on conflicts.

Unpinned packages track the latest versions available from their configured
repositories, not necessarily upstream releases. Flox packages have separate
groups so one package doesn't hold back the others. Explicit version pins
remain intentional; the font archive is pinned and checksummed. Flox owns Pi
itself, so only its extensions are updated through Pi.

Removing a package from a list does not uninstall it. Remove obsolete packages
explicitly.

## Fonts

JetBrainsMono Nerd Font comes from Homebrew on macOS and a checksummed external
archive on Linux. To bump Linux fonts, update the URL and SHA-256 in
`.chezmoiexternals/fonts-linux.toml.tmpl`, then run `chezmoi apply`.

## Theme

Flexoki follows system/terminal appearance in Ghostty, COSMIC Terminal, Zed,
Herdr, Neovim, and Yazi. Pi's `system` theme and fish/Starship/fzf/bat inherit terminal colors;
other terminals must also use Flexoki. Pi's modify template manages only
`theme`, preserving all other settings.

The app configs and theme downloads work on macOS and Pop!_OS. Ghostty config
is macOS-only; COSMIC Terminal config is Linux-only and uses the same palette as
Ghostty's Flexoki themes. Its color schemes and default themes are managed as
whole files; the `profiles` modify template only sets each profile's dark/light
theme. Run `chezmoi update` on the other machine to pull and apply changes.

Helix 25.07 defaults to `flexoki_light` and cannot switch automatically.
Use `:theme flexoki_dark` / `:theme flexoki_light`, or edit its managed config.
Neovim's detection can be overridden with `:set background=light` / `dark`.

Theme downloads are pinned and checksummed in `.chezmoiexternals/themes.toml`;
update both revision and SHA-256 when upgrading. Herdr's overrides come from
`nertzy/herdr-flexoki` (revision recorded in its config).

After applying, reload Ghostty, reopen COSMIC Terminal, run `/reload` in Pi and
`herdr server reload-config`, and reopen shells/editors/Yazi. Restart Zed if
its newly installed theme is not visible.

## Second accounts

`claude2` (fish function) runs Claude Code on a second account, alongside
`claude`. It points `CLAUDE_CONFIG_DIR` at `~/.claude2`, which keeps its own
login, history and sessions; symlinks share the agent rules
(`~/.agents/AGENTS.md`) and `settings.json` with `~/.claude`.

Pi uses pi-multi-pass instead: the second Claude subscription is the
`anthropic-2` provider in the same Pi, so sessions, settings and other logins
stay shared. Start on it with `pi --model anthropic-2/<model>`, switch a running
session with `/model`, or `/pool create` to rotate on rate limits.
pi-anthropic-auth's config shapes `anthropic-2` like `anthropic`, so it bills
as subscription usage. `multi-pass.json` is only seeded when missing, so
`/subs` and `/pool` changes stay local.

Log in once per machine: run `claude2`, and in Pi run `/login` and pick
Anthropic #2.

## Machine-local state

Flox runtime config, Pi settings (except the managed theme), SSH keys and
Ollama Modelfiles (private prompts) stay outside this repository. Copy
`~/.config/ollama/Modelfile.dictation-cleanup` to a new machine yourself;
setup skips the model until it exists.
Generate `~/.ssh/id_ed25519` on each machine and register its public key with
GitHub. GitHub CLI manages its credentials; commands needing a token can use
`GITHUB_TOKEN=$(gh auth token) command` rather than exporting it to every process.
Zed requires per-project trust and uses its agent's default permission mode.

Project toolchains are separate. The QuestDB setup is synced through Syncthing:

```sh
~/Syncthing/dev-setup/questdb/bootstrap.sh
```
