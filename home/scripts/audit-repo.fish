echo "=== Most-changed files (last year) ==="
git log --format=format: --name-only --since="1 year ago" | sort | uniq -c | sort -nr | head -20

echo ""
echo "=== Contributors by commit count ==="
git shortlog -sn --no-merges

echo ""
echo "=== Bug hotspots ==="
git log -i -E --grep="fix|bug|broken" --name-only --format='' | sort | uniq -c | sort -nr | head -20

echo ""
echo "=== Commit velocity (by month) ==="
git log --format='%ad' --date=format:'%Y-%m' | sort | uniq -c

echo ""
echo "=== Firefighting patterns (last year) ==="
git log --oneline --since="1 year ago" | grep -iE 'revert|hotfix|emergency|rollback'
