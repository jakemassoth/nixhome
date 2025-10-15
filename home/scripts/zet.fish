# function to prompt the user for a filename
function get_filename
  read -P "Enter a filename: " filename
  echo $filename
end

# function to create and open a file in the specified directory
function open_file
  set dir $argv[1]

  # Cd into the directory
  cd $dir; or exit
  # Create the file in the specified directory
  touch "$dir/$filename.md"

  # create unique identifier and links section
  set timestamp (date +"%Y%m%d%H%M")

  # format the file
  echo "# " >> "$dir/$filename.md"
  echo "" >> "$dir/$filename.md"
  echo "" >> "$dir/$filename.md"
  echo "" >> "$dir/$filename.md"
  echo "Links:" >> "$dir/$filename.md"
  echo "" >> "$dir/$filename.md"
  echo $timestamp >> "$dir/$filename.md"

  # Open the file in Neovim
  nvim '+ normal ggzzi' "$dir/$filename.md"
end

# Prompt the user if no filename is provided
if test (count $argv) -eq 0
  set filename (get_filename)
end

# if more than one argument is given, print error message and stop script
if test (count $argv) -gt 1
  echo "Please provide only one filename separated by dashes, without .md extension."
  echo "Example: zet my-new-note"
  exit 1
end

# set filename to the argument given to the script
if test (count $argv) -eq 1
  set filename $argv[1]
end

open_file "@OBSIDIAN_DIR@"
