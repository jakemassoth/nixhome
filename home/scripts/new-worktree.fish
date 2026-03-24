set REPO_DIR "$HOME/github.com/verifybv/firebase-monorepo"
set WORKTREES_DIR "$HOME/github.com/verifybv/firebase-monorepo-worktrees"

# Check if correct number of arguments provided
if test (count $argv) -lt 1; or test (count $argv) -gt 2
    echo "Usage: new-worktree <branch-name> [base-branch]"
    echo "Example: new-worktree feature/new-feature"
    echo "Example: new-worktree feature/new-feature develop"
    echo "Base branch options: main (default), develop, release"
    exit 1
end

set BRANCH_NAME $argv[1]
set BASE_BRANCH "main"

if test (count $argv) -eq 2
    set BASE_BRANCH $argv[2]
    if not contains $BASE_BRANCH main develop release
        echo "Error: base branch must be one of: main, develop, release"
        exit 1
    end
end

set FOLDER_NAME (string replace -a / - $BRANCH_NAME)
set FOLDER_PATH "$WORKTREES_DIR/$FOLDER_NAME"

echo "🔄 Fetching from origin..."
git -C $REPO_DIR fetch origin

mkdir -p $WORKTREES_DIR

echo "🌿 Creating new worktree '$BRANCH_NAME' from 'origin/$BASE_BRANCH' in '$FOLDER_PATH'..."
git -C $REPO_DIR worktree add -b $BRANCH_NAME $FOLDER_PATH origin/$BASE_BRANCH

echo "📁 Worktree created successfully!"

set ABS_FOLDER_PATH (realpath $FOLDER_PATH)

set SESSION_NAME (string replace -ra '[^a-zA-Z0-9_-]' '_' $BRANCH_NAME)

echo "activating direnv in $ABS_FOLDER_PATH"
direnv allow $ABS_FOLDER_PATH

echo "z $ABS_FOLDER_PATH" | pbcopy

# Create tmux session (no-op if it already exists), then switch to it
tmux new-session -d -s $SESSION_NAME -c $ABS_FOLDER_PATH 2>/dev/null; or true

if set -q TMUX
    echo "🚀 Switching to tmux session '$SESSION_NAME'"
    exec tmux switch-client -t $SESSION_NAME
else
    echo "🚀 Attaching to tmux session '$SESSION_NAME'"
    exec tmux attach -t $SESSION_NAME
end
