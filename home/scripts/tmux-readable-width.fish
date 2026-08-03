# Toggle a centered, fixed-width content area in the current tmux window.
# Empty full-height panes are used as left and right gutters because tmux
# always anchors a manually resized window at the top-left of its client.

set -l target_width 120

if test (count $argv) -lt 3
    echo "usage: tmux-readable-width WINDOW_ID PANE_ID CLIENT_WIDTH" >&2
    exit 2
end

set -l window_id $argv[1]
set -l source_pane $argv[2]
set -l client_width $argv[3]

function show_message --inherit-variable window_id --argument-names message
    tmux display-message -t "$window_id" -- "$message"
end

function pane_belongs_to_window --argument-names pane window
    test -n "$pane"; or return 1
    set -l pane_window (tmux display-message -p -t "$pane" '#{window_id}' 2>/dev/null); or return 1
    test "$pane_window" = "$window"
end

function clear_state --argument-names window
    for option in @readable_width @readable_left_pane @readable_right_pane @readable_main_pane @readable_layout @readable_was_zoomed
        tmux set-option -wqu -t "$window" "$option"
    end
end

set -l enabled (tmux show-option -wqv -t "$window_id" @readable_width)
if test -n "$enabled"
    set -l left_pane (tmux show-option -wqv -t "$window_id" @readable_left_pane)
    set -l right_pane (tmux show-option -wqv -t "$window_id" @readable_right_pane)
    set -l main_pane (tmux show-option -wqv -t "$window_id" @readable_main_pane)
    set -l saved_layout (tmux show-option -wqv -t "$window_id" @readable_layout)
    set -l was_zoomed (tmux show-option -wqv -t "$window_id" @readable_was_zoomed)

    if pane_belongs_to_window "$right_pane" "$window_id"
        tmux kill-pane -t "$right_pane"
    end
    if pane_belongs_to_window "$left_pane" "$window_id"
        tmux kill-pane -t "$left_pane"
    end

    # Also handles windows left in the old, left-aligned implementation.
    tmux set-option -w -t "$window_id" window-size latest
    tmux set-option -wqu -t "$window_id" fill-character
    clear_state "$window_id"

    if test -n "$saved_layout"
        tmux select-layout -t "$window_id" "$saved_layout" >/dev/null 2>&1
    end
    if pane_belongs_to_window "$main_pane" "$window_id"
        tmux select-pane -t "$main_pane"
        if test "$was_zoomed" = 1
            tmux resize-pane -Z -t "$main_pane"
        end
    end

    show_message 'Readable width off'
    exit 0
end

if not string match -qr '^[0-9]+$' -- "$client_width"
    show_message 'Could not determine the tmux client width'
    exit 1
end

# Ensure a window left in manual sizing is returned to the invoking client size
# before calculating its gutters.
tmux set-option -w -t "$window_id" window-size latest
set -l window_width (tmux display-message -p -t "$source_pane" '#{window_width}')
if not string match -qr '^[0-9]+$' -- "$window_width"
    show_message 'Could not determine the tmux window width'
    exit 1
end

# Two columns are consumed by the pane borders around the content area.
set -l spare (math "$window_width - $target_width - 2")
if test "$spare" -lt 2
    show_message "Window is already $target_width columns or narrower"
    exit 0
end

set -l left_width (math "floor($spare / 2)")
set -l right_width (math "$spare - $left_width")
set -l saved_layout (tmux display-message -p -t "$source_pane" '#{window_layout}')
set -l was_zoomed (tmux display-message -p -t "$source_pane" '#{window_zoomed_flag}')

if test "$was_zoomed" = 1
    tmux resize-pane -Z -t "$source_pane"
end

set -l left_pane (tmux split-window -d -h -f -b -l "$left_width" -t "$source_pane" -P -F '#{pane_id}' -E)
if test $status -ne 0 -o -z "$left_pane"
    if test "$was_zoomed" = 1
        tmux resize-pane -Z -t "$source_pane"
    end
    show_message 'Could not create the left readable-width gutter'
    exit 1
end

set -l right_pane (tmux split-window -d -h -f -l "$right_width" -t "$source_pane" -P -F '#{pane_id}' -E)
if test $status -ne 0 -o -z "$right_pane"
    tmux kill-pane -t "$left_pane"
    tmux select-layout -t "$window_id" "$saved_layout" >/dev/null 2>&1
    if test "$was_zoomed" = 1
        tmux resize-pane -Z -t "$source_pane"
    end
    show_message 'Could not create the right readable-width gutter'
    exit 1
end

# Adding the second gutter proportionally shrinks the first one, so enforce
# both final widths after both panes exist.
tmux resize-pane -t "$left_pane" -x "$left_width"
tmux resize-pane -t "$right_pane" -x "$right_width"
tmux set-option -p -t "$left_pane" @readable_gutter left
tmux set-option -p -t "$right_pane" @readable_gutter right
tmux select-pane -d -t "$left_pane"
tmux select-pane -d -t "$right_pane"
tmux select-pane -t "$source_pane"

tmux set-option -w -t "$window_id" @readable_width 1
tmux set-option -w -t "$window_id" @readable_left_pane "$left_pane"
tmux set-option -w -t "$window_id" @readable_right_pane "$right_pane"
tmux set-option -w -t "$window_id" @readable_main_pane "$source_pane"
tmux set-option -w -t "$window_id" @readable_layout "$saved_layout"
tmux set-option -w -t "$window_id" @readable_was_zoomed "$was_zoomed"

show_message "Readable width: $target_width columns, centered"
