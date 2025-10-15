set DEFAULT_BASE_DIR "$HOME/development/storyteq/monorepo-worktrees"

# Check if correct number of arguments provided
if test (count $argv) -lt 1; or test (count $argv) -gt 2
    echo "Usage: new-worktree <branch-name> [folder-path]"
    echo "Example: new-worktree feature/new-feature"
    echo "Example: new-worktree feature/new-feature ~/custom/path"
    echo "Default base directory: $DEFAULT_BASE_DIR"
    exit 1
end

set BRANCH_NAME $argv[1]

# Use provided folder path or construct default
if test (count $argv) -eq 2
    set FOLDER_PATH $argv[2]
else
    # Create folder name from branch name (replace / with -)
    set FOLDER_NAME (string replace -a / - $BRANCH_NAME)
    set FOLDER_PATH "$DEFAULT_BASE_DIR/$FOLDER_NAME"
end

echo "🔄 Fetching from origin..."
git fetch origin

# Create the base directory if it doesn't exist (when using default)
if test (count $argv) -eq 1
    mkdir -p (dirname $FOLDER_PATH)
end

echo "🌿 Creating new worktree '$BRANCH_NAME' in '$FOLDER_PATH'..."
git worktree add -b $BRANCH_NAME $FOLDER_PATH origin/main

echo "📁 Worktree created successfully!"

# Get the absolute path of the folder
set ABS_FOLDER_PATH (realpath $FOLDER_PATH)

set SESSION_NAME (string replace -ra '[^a-zA-Z0-9_-]' '_' $BRANCH_NAME)

echo "activating direnv in $ABS_FOLDER_PATH"
direnv allow $ABS_FOLDER_PATH

echo "🚀 now attach to zellij session $SESSION_NAME and cd into $ABS_FOLDER_PATH (in clipboard)"
echo "z $ABS_FOLDER_PATH" | pbcopy

exec zellij attach -b $SESSION_NAME
