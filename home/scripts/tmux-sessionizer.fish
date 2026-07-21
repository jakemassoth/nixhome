# tmux-sessionizer: a single picker over both running tmux sessions and
# project directories you could launch a session for. Pick a running session
# to switch to it, or a directory to create (or reuse) a session for it — no
# distinction from the caller's point of view. Bound to prefix+s in tmux.
# Directory discovery mirrors the old wezterm workspace switcher (see git
# history: home/programs/wezterm/config.lua).

function __session_name --argument-names dir
    # Derive a tmux-safe session name (no dots — tmux treats them specially).
    # yeschef worktrees are named <project>_<worktree> so worktrees with the
    # same name in different projects don't collide.
    set -l wt (string match -r '/yeschef/projects/([^/]+)/worktrees/([^/]+)$' $dir)
    if test (count $wt) -eq 3
        set -l name "$wt[2]_$wt[3]"
        string replace -a '.' '_' $name
    else
        string replace -a '.' '_' (basename $dir)
    end
end

if test (count $argv) -eq 1
    set selected $argv[1]
else
    set -l running (tmux list-sessions -F '#{session_name}' 2>/dev/null)

    set -l dirs (begin
        # ~/github.com/<org>/<repo>
        find "$HOME/github.com" -mindepth 2 -maxdepth 2 -type d 2>/dev/null
        # verifybv firebase monorepo worktrees
        find "$HOME/github.com/verifybv/firebase-monorepo-worktrees" -mindepth 1 -maxdepth 1 -type d 2>/dev/null
        # yeschef source checkout
        if test -d "$HOME/yeschef/yeschef-src"
            echo "$HOME/yeschef/yeschef-src"
        end
        # yeschef project worktrees: ~/yeschef/projects/<project>/worktrees/<worktree>
        find "$HOME/yeschef/projects" -mindepth 3 -maxdepth 3 -type d -path '*/worktrees/*' 2>/dev/null
    end)

    set selected (begin
        # Running sessions first, so switching is one keystroke away.
        for s in $running
            echo $s
        end
        # Then candidate directories, skipping any whose session already runs
        # (it's already listed above).
        for d in $dirs
            if not contains -- (__session_name $d) $running
                echo $d
            end
        end
    end | fzf --prompt='session: ')
end

if test -z "$selected"
    exit 0
end

# An absolute path means "open this directory"; anything else is the name of an
# already-running session, so switch straight to it.
if string match -q -- '/*' $selected
    set -l name (__session_name $selected)
    if not tmux has-session -t=$name 2>/dev/null
        tmux new-session -d -s $name -c $selected
    end
    set selected $name
end

if set -q TMUX
    tmux switch-client -t $selected
else
    tmux attach -t $selected
end
