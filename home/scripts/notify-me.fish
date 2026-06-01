# notify-me — run a command, then send a desktop notification with its exit code.
#
# Usage:
#   notify-me [--] <command> [args...]
#
# Examples:
#   notify-me -- cargo build --release
#   notify-me make deploy
#
# Why a wrapper and not `cmd | notify-me`: in a pipe, the right-hand side only
# receives the left command's stdout bytes — never its exit code. Running the
# command ourselves is the only way to capture the real exit status.
#
# Output streams through live, and notify-me exits with the command's own exit
# code so it stays transparent inside scripts and `&&`/`;` chains.

# Drop an optional leading `--` separator
if test (count $argv) -ge 1; and test "$argv[1]" = "--"
    set argv $argv[2..-1]
end

if test (count $argv) -eq 0
    echo "Usage: notify-me [--] <command> [args...]" >&2
    exit 2
end

set -l cmd_str (string join ' ' -- $argv)
set -l start (date +%s)

# Run the command, streaming its output live
$argv
set -l code $status

set -l elapsed (math (date +%s) - $start)

set -l title
if test $code -eq 0
    set title "✅ done ("$elapsed"s)"
else
    set title "❌ failed: exit $code ("$elapsed"s)"
end

if type -q osascript
    # macOS
    set -l esc_body (string replace -a '\\' '\\\\' -- $cmd_str | string replace -a '"' '\\"')
    set -l esc_title (string replace -a '\\' '\\\\' -- $title | string replace -a '"' '\\"')
    osascript -e "display notification \"$esc_body\" with title \"$esc_title\"" >/dev/null 2>&1
else if type -q notify-send
    # Linux
    notify-send -- $title $cmd_str
end

exit $code
