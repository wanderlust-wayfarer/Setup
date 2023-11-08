#!/bin/bash

# Description: Overrides default configs. Run this if you have updates to your working environment and commit to your fork.

# Homebrew configs
echo "Collecting Homebrew formulae & casks..."
brew list --formulae > ./Configs/brew_casks_and_formulae.txt
brew list --casks >> ./Configs/brew_casks_and_formulae.txt
echo "Done"

# VS Code extensions
echo "Setting VS Code extensions"
code --list-extensions > ./Configs/vscode_extensions.txt
echo "Done"