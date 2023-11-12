#!/bin/bash

# DESCRIPTION
description="Description: Automated setup of a machine to use preferred configs. Uses defaults provided from './Configs' and './Fonts', unless updated using their respective set scripts."

# FUNCTIONS
# Displays help documentation
function show_help () {
    echo "$description"
    echo "Usage: $0 [OPTIONS]"
    echo "Options:"
    echo "  -a, --all       Downloads and installs up all config options listed below. WARNING: Passing other options before this option is superfluous."
    echo "  -b, --brew      Installs Homebrew, Casks & Formulae. Default Casks & Formulae are provided, or can be set separately using 'set_configs.sh'."
    echo "  -f, --fonts     Installs all custom fonts from './Fonts'. Can be updated separately using 'set_fonts.sh'."
    echo "  -g, --git       Reads user input to set '.gitconfig' user.name and user.email."
    echo "  -s, --shell     Downloads, installs, and sets up iTerm2, color preferences, Oh-My-Zsh, Agnoster theme, custom aliases, custom profile, and a few other useful tools. Requires fonts installed by '--fonts'."
    echo "  -v, --vscode    Downloads and installs VS Code, extensions, and configures its settings. Requires 'code' CLI (installed automatically with '--brew' and default configs)."
}

# Read lines from a file and populate an array
function read_lines_into_array() {
    local file="$1"
    local array_name="$2"
    local line

    # Clear the array to make sure it's empty
    eval "$array_name=()"

    # shellcheck disable=SC2034
    while IFS= read -r line; do
        eval "$array_name+=(\"\$line\")"
    done < "$file"
}

# Gets configs set previously by the user.
function get_configs () {
    # VARS
    brew_casks_and_formulae=()
    vscode_extensions=()

    # Populate arrays with values from configs
    read_lines_into_array "./Configs/brew_casks_and_formulae.txt" brew_casks_and_formulae
    read_lines_into_array "./Configs/vscode_extensions.txt" vscode_extensions
}

# Sets .gitconfig
function set_git_config () {
    echo "Setting up git"

    # Prompt the user to enter their name
    read -rp "Please enter your name: " name

    # Prompt the user to enter their email
    read -rp "Please enter your email: " email

    # Apply user inputs to .gitconfig
    git config --global user.name \""$name"\" user.email \""$email"\"

    echo "Done"
}

# Install all custom fonts
function install_custom_fonts () {
    echo "Unpackaging and installing custom fonts"

    # Unzip fonts into the Fonts Library
    unzip -d ~/Library/Fonts ./Fonts/fonts.zip

    # Check if Font Book is running and quit it
    if pgrep "Font Book" &>/dev/null; then
        osascript -e 'tell application "Font Book" to quit'
    fi

    # Open Font Book to recognize the new font
    open -a "Font Book"

    echo "Fonts successfully installed"
}

# Sets all shell preferences
function setup_shell () {
    install_iterm2
    # install_iterm_color_themes
    install_ohmyzsh
    setup_zsh_plugins
}

# Downloads and installs the latest version of iTerm2
function install_iterm2 () {
    # Install iTerm2
    echo "Installing iTerm2"

    # Collects and extracts URL from anchor tag for iTerm2's latest distribution
    iterm2_latest_url="https://iterm2.com/downloads/stable/latest"
    iterm2_download_url=$(curl -s "$iterm2_latest_url" | awk -F 'href="' '/<a/{print $2; exit}' | awk -F '"' '{print $1}')

    echo "$iterm2_download_url"

    # Check if a file URL was found
    if [ -n "$iterm2_download_url" ]; then
        # Download the file
        curl -O "$iterm2_download_url"
        
        # Extract the file if it's a ZIP, GZIP, or TAR archive
        if [[ "$iterm2_download_url" =~ \.zip$ ]]; then
            unzip "$(basename "$iterm2_download_url")"
        elif [[ "$iterm2_download_url" =~ \.gz$ ]]; then
            tar -xzvf "$(basename "$iterm2_download_url")"
        elif [[ "$iterm2_download_url" =~ \.tar$ ]]; then
            tar -xvf "$(basename "$iterm2_download_url")"
        else
            echo "File downloaded, but not in a recognized archive format. No extraction performed."
        fi
    else
        echo "File URL not found in the anchor tag."
    fi

    open ./iTerm.app

    echo "Done"
}

# TODO: Installs color themes
# Currently unable to find a filetype which writes successfully with `defaults write`
# using the output provided from `defaults read`.
# Formats attempted: JSON-like output directly from `defaults read`, xml, binary, JSON, dictionary reformatted via Python
function install_iterm_color_themes () {
    echo "Installing custom iTerm2 Color Themes"
    # defaults write com.googlecode.iterm2 'Custom Color Presets' -dict "$(cat ./iTermColors/CustomColorPresets.json)"
    echo "Done"
}

# Install Oh-My-Zsh & set up themes
function install_ohmyzsh () {
    echo "Installing Oh-My-Zsh"
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

    echo "Setting up theme"
    # Pulled directly from Oh-My-Zsh site
    # NEEDS TESTING
    exec /bin/zsh -c '
        echo "${(F)AGNOSTER_PROMPT_SEGMENTS[@]}" | cat -n
        AGNOSTER_PROMPT_SEGMENTS=("prompt_git" "${AGNOSTER_PROMPT_SEGMENTS[@]}")
    '

    echo "Done"
}

# Setup zsh plugins
function setup_zsh_plugins () {
    echo "Setting up other useful shell features"

    # zsh Syntax Highlighting
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting

    echo "Done"
}

# Install Homebrew, Formulae, & Casks
function install_homebrew () {
    echo "Installing Homebrew"

    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    echo "Done"

    echo "Installing Formulae & Casks"

    # TODO: multi-thread
    for cask_or_formula in "${brew_casks_and_formulae[@]}";
    do
        brew install "$cask_or_formula"
    done

    echo "Done"
}

# TODO: Download & Install VSCode
function install_vscode () {
    echo "Installing VS Code"
    echo "Done"

    install_vscode_extensions
    set_vscode_settings
}

# Process function for parallel extension installation
function process_vscode_extension () {
    local extension="$1"
    code --install-extension "$extension"
}

# Install VSCode Extensions
function install_vscode_extensions () {
    echo "Installing VS Code extensions"

    for extension in "${vscode_extensions[@]}"; do
        process_vscode_extension "$extension" &
    done

    # Wait for all background processes to finish
    wait

    echo "Done"
}

# TODO: Setting VSCode Preferences JSON
function set_vscode_settings () {
    echo "Adjusting VS Code settings"
    echo "Done"
}

# OPTS
# Show help if no arguments
if [ $# -eq 0 ]; then
    show_help
    exit 1
fi

# Process arguments
while [ $# -gt 0 ]; do
    case "$1" in
        -a | --all)
            get_configs
            set_git_config
            install_custom_fonts
            setup_shell
            install_homebrew
            install_vscode
            exit 0
            ;;
        -b | --brew)
            install_homebrew
            ;;
        -f | --fonts)
            install_custom_fonts
            ;;
        -g | --git)
            set_git_config
            ;;
        -h | --help)
            show_help
            exit 0
            ;;
        -s | --shell)
            setup_shell
            ;;
        -v | --vscode)
            install_vscode
            ;;
        *)
            echo "Unrecognized option: $1" >&2
            show_help
            exit 1
            ;;
    esac
    shift
done