set CACHE_DIR "$HOME/Music/dj-sets"

if not test -d $CACHE_DIR
    echo "No cache directory at $CACHE_DIR — nothing to clean."
    exit 0
end

set FILES (find $CACHE_DIR -maxdepth 1 -type f)

if test (count $FILES) -eq 0
    echo "No DJ sets cached in $CACHE_DIR."
    exit 0
end

set SELECTED (printf '%s\n' $FILES | fzf --multi --prompt='Delete sets (tab to multi-select): ' --preview='ls -lh {}')

if test (count $SELECTED) -eq 0
    echo "Nothing selected."
    exit 0
end

for f in $SELECTED
    echo "🗑  Removing $f"
    rm -f $f
end
