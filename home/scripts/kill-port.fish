if test (count $argv) -eq 0
    echo "usage: kill-port PORT [PORT...]" >&2
    exit 1
end

set status_code 0

for port in $argv
    if not string match -qr '^[0-9]+$' -- $port
        echo "kill-port: '$port' is not a valid port" >&2
        set status_code 1
        continue
    end

    set pids (lsof -ti tcp:$port)

    if test (count $pids) -eq 0
        echo "kill-port: no process listening on port $port"
        continue
    end

    echo "kill-port: killing "(count $pids)" process(es) on port $port: $pids"
    kill $pids
end

exit $status_code
