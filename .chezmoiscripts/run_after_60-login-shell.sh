#!/usr/bin/env bash
set -euo pipefail

# Use a stable host path, never a versioned Flox store path.
case "$(uname -s)" in
    Darwin)
        fish=/opt/homebrew/bin/fish
        current=$(dscl . -read "/Users/$USER" UserShell | awk '{print $2}')
        ;;
    Linux)
        fish=/usr/bin/fish
        current=$(getent passwd "$USER" | cut -d: -f7)
        ;;
esac
[ "$current" != "$fish" ] || exit 0
"$fish" --no-config -c 'exit 0'
if ! grep -qxF "$fish" /etc/shells; then
    echo "$fish" | sudo tee -a /etc/shells >/dev/null
fi
sudo chsh -s "$fish" "$USER"
