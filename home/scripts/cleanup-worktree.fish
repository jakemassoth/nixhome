# Check if we're in a Git repository
if not git rev-parse --git-dir > /dev/null 2>&1
    echo "Error: Not in a Git repository"
    exit 1
end

# Get the current directory (the worktree we want to delete)
set CURRENT_DIR (pwd)
set BRANCH_NAME (git branch --show-current)

echo "🔍 Current worktree:"
echo "  Branch: $BRANCH_NAME"
echo "  Path: $CURRENT_DIR"
echo ""

# Confirmation
read -P "Delete this worktree and kill current tmux session? (y/N): " -n 1 response
echo
if not string match -qi 'y' $response
    echo "Cleanup cancelled"
    exit 0
end

# Remove the worktree
echo "🗑️  Removing Git worktree '$CURRENT_DIR'..."
git worktree remove . --force

echo "🎉 Cleanup completed!"

# Kill current tmux session if we're in one (do this last)
if set -q TMUX
    set TMUX_SESSION (tmux display-message -p '#S')
    echo "🔪 Killing current tmux session '$TMUX_SESSION'..."
    sleep 1
    tmux kill-session -t $TMUX_SESSION
else
    echo "ℹ️  Not in a tmux session"
end
