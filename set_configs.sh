#!/bin/bash

# DESCRIPTION
description="Overrides default configs. Run this if you have updates to your working environment and commit to your fork.

This will override any default Configs, Fonts, and Color Themes currently set for this repository."

# FUNCTIONS
# Displays help documentation
function show_help () {
    echo "$description"
    echo "Usage $0 [OPTIONS]"
    echo "Options:"
    echo "  -a, --all       Pulls all current configs for the options described below."
    echo "  -b, --brew      Sets the internal config for Homebrew ('./Configs/brew_casks_and_formulae.txt') as a line separated array. Since brew installs Casks and Formulae with the same command, values are stored together to reduce complexity."
    echo "  -f, --fonts     Copies all fonts in the Fontbook to './Fonts' and compresses them."
    echo "  -s, --shell     TODO"
    echo "  -v, --vscode    Collects all VS Code extensions, using 'code' CLI, and saves them to a line separated array file in './Configs/vscode_extensions.txt'"
}

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

# OPTS
# Show help if no arguments
if [ $# -eq 0 ]; then
    show_help
    exit 1
fi

while [ $# -gt 0 ]; do
    case "$1" in
        -a | --all)
            set_homebrew_casks_and_formulae
            set_vscode_extensions
            set_shell_preferences
            exit 0
            ;;
        -b | --brew)
            set_homebrew_casks_and_formulae
            ;;
        -h | --help)
            show_help
            exit 0
            ;;
        -s | --shell)
            set_shell_preferences
            ;;
        -v | --vscode)
            set_vscode_extensions
    esac
    shift
done