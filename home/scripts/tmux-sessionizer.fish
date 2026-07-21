# tmux-sessionizer: fuzzy-pick a project directory and open (or switch to) a
# tmux session for it. Directory discovery mirrors the old wezterm workspace
# switcher (see git history: home/programs/wezterm/config.lua).

if test (count $argv) -eq 1
    set selected $argv[1]
else
    set selected (begin
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
    end | fzf)
end

if test -z "$selected"
    exit 0
end

# Derive a tmux-safe session name (no dots — tmux treats them specially).
# yeschef worktrees are named <project>_<worktree> so worktrees with the same
# name in different projects don't collide.
set wt (string match -r '/yeschef/projects/([^/]+)/worktrees/([^/]+)$' $selected)
if test (count $wt) -eq 3
    set selected_name "$wt[2]_$wt[3]"
else
    set selected_name (basename $selected)
end
set selected_name (string replace -a '.' '_' $selected_name)

if not tmux has-session -t=$selected_name 2>/dev/null
    tmux new-session -d -s $selected_name -c $selected
end

if set -q TMUX
    tmux switch-client -t $selected_name
else
    tmux attach -t $selected_name
end
