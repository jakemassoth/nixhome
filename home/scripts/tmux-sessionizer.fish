if test (count $argv) -eq 1
    set selected $argv[1]
else
    set selected (begin
        find "$HOME/github.com" -mindepth 2 -maxdepth 2 -type d
        find "$HOME/github.com/verifybv/firebase-monorepo-worktrees" -mindepth 1 -maxdepth 1 -type d 2>/dev/null
    end | fzf)
end

if test -z "$selected"
    exit 0
end

set selected_name (basename $selected | tr . _)

if not tmux has-session -t=$selected_name 2>/dev/null
    tmux new-session -d -s $selected_name -c $selected
end

if set -q TMUX
    tmux switch-client -t $selected_name
else
    tmux attach -t $selected_name
end
