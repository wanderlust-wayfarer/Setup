#!/bin/bash

# Description: Overrides default configs. Run this if you have updates to your working environment and commit to your fork.

# FUNCTIONS
# Collect Homebrew formulae & casks
function set_homebrew_casks_and_formulae () {
    echo "Collecting Homebrew formulae & casks..."
    brew list --formulae > ./Configs/brew_casks_and_formulae.txt
    brew list --casks >> ./Configs/brew_casks_and_formulae.txt
    echo "Done"
}

# Collect VS Code extensions
function set_vscode_extensions () {
    echo "Setting VS Code extensions"
    code --list-extensions > ./Configs/vscode_extensions.txt
    echo "Done"
}

# Sets all Shell preferences
function set_shell_preferences () {
    copy_zshrc
}

# Copy .zsrhc
function copy_zshrc () {
    echo "Copying .zshrc from Home (~) directory"
    cp ~/.zshrc ./Configs
    echo "Done"
}