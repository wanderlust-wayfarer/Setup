#! /bin/bash
# A script to get the current configs used on a given machine and store them within a Configs dir,
# stored at the same level as this script.

# Homebrew configs
echo "Collecting Homebrew formulae & casks..."
brew list --formulae > ~/Code/Scripts/Configs/brew_formulae.txt
brew list --casks > ~/Code/Scripts/Configs/brew_casks.txt
echo "Done"

# VS Code extensions
code --list-extensions > ~/Code/Scripts/Configs/vscode_extensions.txt

# Testing how to store config as an associative array
# and pull them down for later use.
# Decided this whole script is probably better done in Python or Perl

# script_dir="$(dirname "$0")"

# for config in "${script_dir}/Configs"/*; do
#     if [ -f "$config" ]; then
#         config_basename="$(basename "$config")"
#         echo "${config_basename%.*}"
#         while IFS= read -r line; do
#             echo "$line"
#             configs["$config_basename%.*"]+="$line"
#         done
#     fi
# done

# echo "${configs[vscode_extensions]}"