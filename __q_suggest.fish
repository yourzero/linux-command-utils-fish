function __q_suggest --on-event fish_postexec --description 'Suggest q-commands after common base commands'
    set -l cmd (string trim $argv[1])
    test -z "$cmd"; and return

    set -l parts (string split ' ' -- $cmd)
    set -l base $parts[1]
    set -l sub (count $parts) > 1 && echo $parts[2]; or echo ''
    set -l sub $parts[2]

    # Never suggest for q-commands themselves
    string match -q 'q*' -- $base; and return

    set -l suggestion ''

    switch $base

        # ── NVIDIA / GPU ──────────────────────────────────────────────
        case nvidia-smi
            if string match -q -- '*-l *' $cmd; or string match -q -- '*--loop*' $cmd
                set suggestion 'qgpuwatch — live GPU stats every 2s'
            else if string match -q -- '*compute-apps*' $cmd
                set suggestion 'qgpuproc — GPU process list'
            else
                set suggestion 'qgpu — GPU temp/load/VRAM/power summary'
            end

        # ── DOCKER ────────────────────────────────────────────────────
        case docker
            switch $sub
                case ps
                    if string match -q -- '*-a*' $cmd; or string match -q -- '*--all*' $cmd
                        set suggestion 'qdpsall — all containers incl. stopped'
                    else
                        set suggestion 'qdps — running containers (clean format)'
                    end
                case logs
                    set suggestion 'qdlogs <name> — tail + follow container logs'
                case exec
                    set suggestion 'qdsh <name> — shell into a container'
                case stats
                    set suggestion 'qdstats — live resource usage (no-stream)'
                case network
                    set suggestion 'qdnet — Docker networks'
                case system
                    if test "$parts[3]" = prune
                        set suggestion 'qdclean — prune with confirmation prompt'
                    end
                case rm rmi
                    # no q-equivalent
            end

        # ── GIT ───────────────────────────────────────────────────────
        case git
            switch $sub
                case status
                    set suggestion 'qgst — status + recent log in one view'
                case log
                    set suggestion 'qglog — pretty log with author and date'
                case diff
                    set suggestion 'qgdiff — staged + unstaged diff summary'
                case branch
                    set suggestion 'qgbr — branches with last commit date'
                case clean
                    set suggestion 'qgclean — clean with confirmation prompt'
            end

        # ── DISK ──────────────────────────────────────────────────────
        case df
            set suggestion 'qdf — df sorted by usage, no tmpfs noise'

        case du
            if string match -q -- '*-a*' $cmd; and string match -q -- '*/\*' $cmd
                set suggestion 'qdubig — biggest files/dirs under a path'
            else
                set suggestion 'qduh — du summary sorted largest-first'
            end

        case mount
            set suggestion 'qmount — mounted filesystems, no pseudo-mounts'

        # ── MEMORY / CPU / PROCESSES ──────────────────────────────────
        case free
            set suggestion 'qmem — memory + swap summary'

        case ps
            if string match -q -- '*-%mem*' $cmd
                set suggestion 'qtopmem — top 15 processes by RAM'
            else
                set suggestion 'qtop — top 15 processes by CPU'
            end

        case top htop
            set suggestion 'qtop — top 15 by CPU  |  qtopmem — top 15 by RAM'

        case uptime
            set suggestion 'quptime — uptime + load avg, human-readable'

        case lscpu
            set suggestion 'qcpu — model, cores, load average'

        case sensors
            set suggestion 'qtemp — CPU + GPU temps together'

        case lsof
            set suggestion 'qopenfiles — top 10 open-fd counts by process'

        case kill pkill killall
            set suggestion 'qkill — find + kill with confirmation prompt'

        # ── NETWORKING ────────────────────────────────────────────────
        case ip
            switch $sub
                case addr
                    if string match -q -- '*-6*' $cmd
                        set suggestion 'qip6 — real IPv6 addresses only'
                    else
                        set suggestion 'qip — real IPs (no loopback/docker noise)'
                    end
                case route
                    set suggestion 'qroute — default gateway + routing table'
                case link
                    set suggestion 'qmac — MAC addresses for real interfaces'
            end

        case ifconfig
            set suggestion 'qip — real IPs only'

        case route
            set suggestion 'qroute — gateway + routing table'

        case ss
            if string match -q -- '*-a*' $cmd
                set suggestion 'qportall — all active TCP connections'
            else
                set suggestion 'qport — listening ports (optional port filter)'
            end

        case netstat
            if string match -q -- '*-a*' $cmd
                set suggestion 'qportall — all active TCP connections'
            else
                set suggestion 'qport — listening ports'
            end

        case dig nslookup host
            set suggestion 'qdns — A/AAAA/MX/NS/TXT records in one shot'

        case ping
            set suggestion 'qping — 5-packet ping'

        case traceroute mtr
            set suggestion 'qtrace — uses best available tool (mtr / traceroute)'

        case nmcli iwgetid
            set suggestion 'qwifi — SSID + signal strength'

        case curl
            if string match -q -- '*ifconfig.me*' $cmd; or string match -q -- '*ipify*' $cmd
                set suggestion 'qpubip — public IP with fallback URLs'
            else if string match -q -- '*/v1/models*' $cmd
                set suggestion 'qvllm — vLLM status + loaded model'
            end

        # ── LOGS / SERVICES ───────────────────────────────────────────
        case dmesg
            set suggestion 'qdmesg — warnings + errors with timestamps'

        case journalctl
            if string match -q -- '*-f*' $cmd
                set suggestion 'qlogf <unit> — live follow journal for a unit'
            else if string match -q -- '*-b*' $cmd; and string match -q -- '*-p err*' $cmd
                set suggestion 'qlasterr — errors from this boot'
            else
                set suggestion 'qlog — errors + warnings (optional unit filter)'
            end

        case systemctl
            switch $sub
                case status
                    set suggestion 'qsvc <name> — service status, clean view'
                case list-units
                    if string match -q -- '*running*' $cmd
                        set suggestion 'qsvca — all active (running) services'
                    else if string match -q -- '*failed*' $cmd
                        set suggestion 'qsvcs — all failed services'
                    end
            end

        # ── FILES & SEARCH ────────────────────────────────────────────
        case find
            if string match -q -- '*-mmin*' $cmd
                set suggestion 'qrecent [path] [mins] — files modified in last N minutes'
            else if string match -q -- '*-exec du*' $cmd
                set suggestion 'qbig [path] [n] — N largest files in a tree'
            else if string match -q -- '*-name*' $cmd
                set suggestion 'qfind <pattern> [path] — find by name, no permission noise'
            end

        case grep
            if string match -q -- '*-r*' $cmd
                set suggestion 'qgrep <pattern> [path] — recursive, case-insensitive, colored'
            end

        # ── PACKAGES ──────────────────────────────────────────────────
        case apt apt-get
            if string match -q -- '*update*' $cmd; or string match -q -- '*upgrade*' $cmd
                set suggestion 'qupdate — update + prompted upgrade'
            else if string match -q -- '*search*' $cmd
                set suggestion 'qpkg <name> — check installed or search'
            end

        case dpkg dpkg-query
            if string match -q -- '*-l*' $cmd
                set suggestion 'qpkg <name> — check if package is installed'
            end

        # ── SSH ───────────────────────────────────────────────────────
        case ssh-add
            set suggestion 'qsshagent — load all private keys into agent'

        case ssh-keygen
            if string match -q -- '*-l*' $cmd
                set suggestion 'qsshkeys — list all key fingerprints'
            end

        # ── MISC ─────────────────────────────────────────────────────
        case env printenv
            set suggestion 'qenv — sorted env vars, optional filter'

        case which
            set suggestion 'qwhat <cmd> — which + man summary'

        case sha256sum
            set suggestion 'qsum <file> — SHA256 checksum'

        case base64
            set suggestion 'qb64 <str> — encode  |  qb64 -d <str> — decode'

        case time
            set suggestion 'qtime <cmd> — time with clear ms output'

        case watch
            set suggestion 'qwatch <interval> <cmd> — watch wrapper'

        case who w
            set suggestion 'qwho — who is logged in and what they are doing'

        case history
            set suggestion 'qhist <pattern> — search history'

        case python3
            if string match -q -- '*json.tool*' $cmd
                set suggestion 'qjson — pretty-print JSON (file or stdin)'
            end

        case jq
            set suggestion 'qjson — pretty-print JSON (file or stdin)'

        case abbr
            set suggestion 'qalias — abbreviations + all defined functions'

    end

    if test -n "$suggestion"
        printf '%s  ↳ %s%s\n' (set_color yellow) $suggestion (set_color normal)
    end
end
