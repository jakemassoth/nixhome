if test (count $argv) -lt 1
    echo "Usage: dj-set <youtube-url>"
    echo "Downloads audio from a YouTube DJ set and plays it in the terminal with mpv."
    echo "Already-downloaded sets are reused from the cache."
    exit 1
end

set URL $argv[1]
set CACHE_DIR "$HOME/Music/dj-sets"
mkdir -p $CACHE_DIR

set TMPFILE (mktemp)

echo "⬇️  Fetching $URL..."
yt-dlp \
    -x --audio-format opus \
    --embed-metadata \
    --no-overwrites \
    --ffmpeg-location "$FFMPEG" \
    -o "$CACHE_DIR/%(title)s [%(id)s].%(ext)s" \
    --print-to-file after_move:filepath $TMPFILE \
    $URL

if test $status -ne 0
    rm -f $TMPFILE
    echo "❌ Download failed"
    exit 1
end

set FILE (cat $TMPFILE)
rm -f $TMPFILE

if test -z "$FILE"; or not test -f "$FILE"
    echo "❌ Could not resolve downloaded file"
    exit 1
end

echo "🎧 Playing $FILE"
exec mpv --no-video --term-osd-bar $FILE
