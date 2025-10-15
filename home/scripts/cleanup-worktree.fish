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
read -P "Delete this worktree and kill current Zellij session? (y/N): " -n 1 response
echo
if not string match -qi 'y' $response
    echo "Cleanup cancelled"
    exit 0
end

# Move out of the worktree directory before removing it
echo "📁 Moving to parent git directory..."
cd (git rev-parse --show-superproject-working-tree 2>/dev/null; or git rev-parse --show-toplevel)

# Remove the worktree
echo "🗑️  Removing Git worktree '$CURRENT_DIR'..."
git worktree remove $CURRENT_DIR --force

echo "🎉 Cleanup completed!"

# Kill current Zellij session if we're in one (do this last)
if test -n "$ZELLIJ_SESSION_NAME"
    echo "🔪 Killing current Zellij session '$ZELLIJ_SESSION_NAME'..."
    sleep 1
    zellij kill-session $ZELLIJ_SESSION_NAME
else
    echo "ℹ️  Not in a Zellij session"
end
