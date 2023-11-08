#!/bin/bash

# DESCRIPTION
description="Description: Automated setup of a machine to use preferred configs. Uses defaults provided from './Configs' and './Fonts', unless updated using their respective set scripts."

# FUNCTIONS
# Displays help documentation
show_help () {
    echo "$description"
    echo "Usage: $0 [OPTIONS]"
    echo "Options:"
    echo "  -a, --all       Sets up all config options listed below. WARNING: Passing other options before this option is superfluous."
    echo "  -b, --brew      Installs Homebrew, Casks & Formulae. Default Casks & Formulae are provided, or can be set separately using 'set_configs.sh'."
    echo "  -f, --fonts     Installs all custom fonts from './Fonts'. Can be updated separately using 'set_fonts.sh'."
    echo "  -g, --git       Reads user input to set '.gitconfig' user.name and user.email."
    echo "  -s, --shell     Downloads, installs, and sets up iTerm2, color preferences, Oh-My-Zsh, Agnoster theme, custom aliases, custom profile, and a few other useful tools. Requires fonts installed by '--fonts'."
    echo "  -v, --vscode    Downloads and installs VS Code, extensions, and configures its settings. Requires 'code' CLI (installed automatically with '--brew' and default configs)."
}

# Define a function to read lines from a file and populate an array
read_lines_into_array() {
    local file="$1"
    local array_name="$2"
    local line

    # Clear the array to make sure it's empty
    eval "$array_name=()"

    while IFS= read -r line; do
        eval "$array_name+=(\"\$line\")"
    done < "$file"
}

# Gets configs set previously by the user.
get_configs () {
    # VARS
    brew_casks_and_formulae=()
    vscode_extensions=()

    # Populate arrays with values from configs
    read_lines_into_array "./Configs/brew_casks_and_formulae.txt" brew_casks_and_formulae
    read_lines_into_array "./Configs/vscode_extensions.txt" vscode_extensions
}

# Sets .gitconfig
set_git_config () {
    # Setup Git Config
    echo "Setting up git"

    # Prompt the user to enter their name
    read -rp "Please enter your name: " name

    # Prompt the user to enter their email
    read -rp "Please enter your email: " email

    echo "CMD: git config --global user.name \""$name"\" user.email \""$email"\""

    echo "Done"
}

# Install all custom fonts
install_custom_fonts () {
    echo "Unpackaging and installing custom fonts"

    # Unzip fonts into the Fonts Library
    unzip -d ~/Library/Fonts "$script_dir"/Fonts/Fonts.zip

    # Check if Font Book is running and quit it
    if pgrep "Font Book" &>/dev/null; then
        osascript -e 'tell application "Font Book" to quit'
    fi

    # Open Font Book to recognize the new font
    open -a "Font Book"

    echo "Fonts successfully installed"
}

# Sets all shell preferences
setup_shell () {
    install_iterm2
    install_iterm_color_themes
    install_ohmyzsh
    setup_shell_preferences
}

# Downloads and installs the latest version of iTerm2
install_iterm2 () {
    # Install iTerm2
    echo "Installing iTerm2"

    # Collects and extracts URL from anchor tag for iTerm2's latest distribution
    iterm2_latest_url="https://iterm2.com/downloads/stable/latest"
    iterm2_download_url=$(curl -s "$iterm2_latest_url" | grep -oP '<a[^>]+href="\K[^"]+' | head -n 1)

    # Check if a file URL was found
    if [ -n "$iterm2_download_url" ]; then
        # Download the file
        wget "$iterm2_download_url"
        
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

    echo "Done"

    install_iterm_color_themes

    setup_shell_preferences
}

# TODO: Install color theme
install_iterm_color_themes () {
    echo "Installing custom iTerm2 Color Themes"
    echo "Done"
}

# Install Oh-My-Zsh & set up themes
install_ohmyzsh () {
    echo "Installing Oh-My-Zsh"

    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

    echo "Setting up theme"

    echo "${(F)AGNOSTER_PROMPT_SEGMENTS[@]}" | cat -n
    AGNOSTER_PROMPT_SEGMENTS=("prompt_git" "${AGNOSTER_PROMPT_SEGMENTS[@]}")

    echo "Done"
}

# TODO: Setup auto-complete shell integration & other custom features
setup_shell_preferences () {
    echo "Setting up other useful shell features"
    echo "Done"
}

# Install Homebrew, Formulae, & Casks
install_homebrew () {
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
install_vscode () {
    echo "Installing VS Code"
    echo "Done"

    install_vscode_extensions
    set_vscode_settings
}

# Install VSCode Extensions
install_vscode_extensions () {
    echo "Installing VS Code extensions"

    # TODO: multi-thread
    for extension in "${vscode_extensions[@]}";
    do
        code --install-extension "$extension"
    done

    echo "Done"
}

# TODO: Setting VSCode Preferences JSON
set_vscode_settings () {
    echo "Adjusting VS Code settings"
    echo "Done"
}

# OPTS
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
        -c | --configs)
            get_configs
            exit 0
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