# Find screen recordings on Desktop sorted by last modified (newest first)
set recordings (ls -t ~/Desktop/*.mov ~/Desktop/*.mp4 2>/dev/null)

if test (count $recordings) -eq 0
    echo "No screen recordings found on Desktop"
    exit 1
end

set selected (printf '%s\n' $recordings | fzf --prompt="Select recording: " --preview="ls -lh {}" --preview-window=up:1)

if test -z "$selected"
    exit 0
end

set basename (basename "$selected")
set name (string replace -r '\.[^.]+$' '' "$basename")
set output ~/Desktop/{$name}-compressed.webm

echo "Compressing $basename -> "(basename "$output")"..."

ffmpeg -i "$selected" \
    -c:v libvpx-vp9 \
    -crf 33 \
    -b:v 0 \
    -an \
    -cpu-used 2 \
    "$output"

set size_kb (du -k "$output" | cut -f1)
echo "Done: $output ($size_kb KB)"

if test $size_kb -gt 10240
    echo "Warning: output is still over 10MB. Try reducing the source recording length."
end

# Copy file to clipboard (macOS: pastes as a file in Finder/browser uploads)
osascript -e "set the clipboard to (POSIX file \"$output\")"
echo "Copied to clipboard"
