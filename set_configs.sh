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
    # copy_iterm2_custom_color_presets
}

# Copy .zsrhc
function copy_zshrc () {
    echo "Copying .zshrc from Home (~) directory"
    cp ~/.zshrc ./Configs
    echo "Done"
}

# TODO: Copy iTerm2 Custom Color Presets
# Currently unable to find a filetype which writes successfully with `defaults write`
# using the output provided from `defaults read`.
# Formats attempted: JSON-like output directly from `defaults read`, xml, binary, JSON, dictionary reformatted via Python
function copy_iterm2_custom_color_presets () {
    echo "Copying 'Custom Color Presets' plist..."
    defaults read com.googlecode.iterm2 'Custom Color Presets' > ./iTermColors/tmp.bin
    
    echo "Converting plist dictionary-ish to binary..."
    plutil -convert binary1 ./iTermColors/tmp.bin

    echo "Converting binary to dict..."
    python_version=$(python --version 2>&1)
    if [[ $python_version == *" 2."* ]]; then
        echo "Running Python 2"
        python -c "import plistlib; print(plistlib.readPlist('./iTermColors/tmp.bin'))" > ./iTermColors/customColorPresets.dict
    elif [[ $python_version == *" 3."* ]]; then
        echo "Running Python 3"
        python -c "import plistlib; print(plistlib.load(open('./iTermColors/tmp.bin', 'rb')))" > ./iTermColors/customColorPresets.dict
    else
        echo "Unknown Python version"
        exit 2
    fi

    echo "Converting dict to defaults compatible JSON"
    jq . "$(sed "s/'/\"/g; s/, *$/ /" './iTermColors/customColorPresets.dict')" > ./iTermColors/customColorPresets.json

    echo "Setting com.googlecode.iterm2 'Custom Color Presets'"
    defaults write com.googlecode.iterm2 'Custom Color Presets' -dict "$(cat ./iTermColors/customColorPresets.dict)"
    

    echo "Cleaning up directory..."
    rm ./iTermColors/tmp.bin

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
            copy_iterm2_custom_color_presets
            ;;
        -v | --vscode)
            set_vscode_extensions
    esac
    shift
done