#!/usr/bin/env bash
#
# Set fish as the login shell.
#
# run_after_ (not run_once_): this is a cheap no-op once the shell is already
# correct, and running every time means it self-heals if the shell ever gets
# reset. It only asks for sudo when a change is actually needed.
#
set -euo pipefail

# Only ever use a package-manager fish. A flox store path would move on the
# next rebuild and leave you with a login shell that no longer exists.
FISH=""
for candidate in /opt/homebrew/bin/fish /usr/local/bin/fish /usr/bin/fish; do
    if [ -x "$candidate" ]; then
        FISH="$candidate"
        break
    fi
done

if [ -z "$FISH" ]; then
    echo "==> login shell: skipped (fish not installed yet)"
    exit 0
fi

# Current login shell. macOS has no getent.
if command -v getent >/dev/null 2>&1; then
    current=$(getent passwd "$USER" | cut -d: -f7)
else
    current=$(dscl . -read "/Users/$USER" UserShell 2>/dev/null | awk '{print $2}')
fi

if [ "$current" = "$FISH" ]; then
    exit 0
fi

# Smoke test before committing to it. A shell that cannot execute a trivial
# command is the one failure mode here that locks you out of your terminal.
if ! "$FISH" -c 'exit 0' >/dev/null 2>&1; then
    echo "==> login shell: skipped ($FISH will not run)" >&2
    exit 0
fi

if ! sudo -v 2>/dev/null; then
    echo "==> login shell: skipped (no sudo available)"
    exit 0
fi

if ! grep -qxF "$FISH" /etc/shells; then
    echo "$FISH" | sudo tee -a /etc/shells >/dev/null
fi

echo "==> login shell: ${current:-unknown} -> $FISH"
sudo chsh -s "$FISH" "$USER"
echo "    open a new terminal window for this to take effect"
