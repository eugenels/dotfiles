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

    # Let fzf inherit the terminal palette without duplicating nested-shell options.
    if not string match -q '*--color=16*' -- "$FZF_DEFAULT_OPTS"
        set -gx FZF_DEFAULT_OPTS "$FZF_DEFAULT_OPTS --color=16"
    end

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
