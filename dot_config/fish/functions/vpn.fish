function vpn --description 'tailscale on demand: vpn [on|off|status|log]'
    # No systemd unit by design: the tailnet is only needed to reach infra, so
    # the daemon is started by hand and torn down again. tailscaled needs root
    # (TUN device, iptables, routes), hence sudo; the rootless alternative,
    # --tun=userspace-networking, is a SOCKS5 proxy only and cannot carry
    # ordinary traffic. The daemon is detached, so it outlives this terminal
    # and stays up until `vpn off`.
    set -l action $argv[1]
    test -z "$action"; and set action on

    set -l tailscaled (command -v tailscaled)
    set -l tailscale (command -v tailscale)
    if test -z "$tailscaled" -o -z "$tailscale"
        echo "vpn: tailscale is not installed (home flox env, linux only)" >&2
        return 1
    end

    # sudo resets PATH to secure_path, which has no /nix/store in it, so every
    # privileged call goes through the absolute path resolved above.
    set -l state /var/lib/tailscale/tailscaled.state
    set -l sock /var/run/tailscale/tailscaled.sock
    set -l log /var/log/tailscaled.log
    set -l pattern "tailscaled --state=$state"

    switch "$action"
        case on
            if not pgrep -f "$pattern" >/dev/null
                sudo install -d -m 0700 /var/lib/tailscale
                sudo install -d -m 0755 /var/run/tailscale
                sudo sh -c "nohup $tailscaled --state=$state --socket=$sock --port=41641 >>$log 2>&1 &"
                set -l up 0
                for i in (seq 40)
                    if test -S $sock
                        set up 1
                        break
                    end
                    sleep 0.25
                end
                if test $up -eq 0
                    echo "vpn: tailscaled did not come up, see $log" >&2
                    return 1
                end
            end
            # --operator makes the socket usable by this user, so `tailscale
            # status` and `vpn off` need no password afterwards. Re-applying it
            # is harmless and keeps a fresh state dir working the same way.
            sudo $tailscale up --operator=$USER
        case off
            $tailscale down
            sudo pkill -f "$pattern"
            for i in (seq 40)
                pgrep -f "$pattern" >/dev/null; or break
                sleep 0.25
            end
            # Drops the iptables rules, routes and DNS config tailscaled added.
            sudo $tailscaled --cleanup
        case status
            if pgrep -f "$pattern" >/dev/null
                $tailscale status
            else
                echo "tailscaled: stopped"
            end
        case log
            sudo tail -n 50 -f $log
        case '*'
            echo "usage: vpn [on|off|status|log]" >&2
            return 2
    end
end
