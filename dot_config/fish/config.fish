set -gx EDITOR nano
set -gx VISUAL nano

if test -x /opt/homebrew/bin/brew
    /opt/homebrew/bin/brew shellenv fish | source
end

fish_add_path ~/.local/bin
if type -q flox; and test -d ~/.flox
    flox activate -d $HOME -m run | source
end

if status is-interactive
    set -g fish_greeting

    if type -q starship
        starship init fish | source
    end

    if type -q zoxide
        zoxide init fish --cmd cd | source
    end

    if type -q direnv
        direnv hook fish | source
    end

    if type -q fzf
        fzf --fish | source
    end
end
