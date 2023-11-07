#!/bin/bash
# setup: Automated setup of a machine to use personally preferred configs.

# Gather relative dir of script
script_dir="$(dirname "$0")"

# Set configs as reusable vars
for config in "${script_dir}/Configs"/*; do
    if [ -f "$config" ]; then
        config_basename="$(basename "$config")"
        # Will not work on Mac, which does not have `mapfile` or `readarray`
        mapfile -t config_basename < config
    fi
done

# Setup Git Config
echo "Setting up git"

# Prompt the user to enter their name
read -rp "Please enter your name: " name

# Prompt the user to enter their email
read -rp "Please enter your email: " email

git config --global user.name \""$name"\" user.email \""$email"\"

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

# TODO: Download and install custom font
# TODO: Install color theme

echo "Done"

# Install Oh-My-Zsh & set up themes
echo "Installing Oh-My-Zsh"

sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

echo "Setting up theme"

echo "${(F)AGNOSTER_PROMPT_SEGMENTS[@]}" | cat -n
AGNOSTER_PROMPT_SEGMENTS=("prompt_git" "${AGNOSTER_PROMPT_SEGMENTS[@]}")

echo "Done"

# TODO: Install auto-complete shell integration

# Install Homebrew, Formulae, & Casks
echo "Installing Homebrew"

NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

echo "Done"

echo "Installing Formulae & Casks"

brew_formulae=("gh" "nvm" "shellcheck" "tree")

for formulae in "${brew_formulae[@]}";
do
    brew install "$formulae"
done

brew_casks=()

for cask in "${brew_casks[@]}";
do
    brew install "$cask"
done

# TODO: Download & Install VSCode

# Install VSCode Extensions
echo "Installing VS Code extensions"

vscode_extensions=("AncientLord.nightowl-theme" "DavidAnson.vscode-markdownlint" "dbaeumer.vscode-eslint" "donjayamanne.githistory" "eamodio.gitlens" "esbenp.prettier-vscode" "firefox-devtools.vscode-firefox-debug" "hoovercj.vscode-power-mode" "ms-azuretools.vscode-docker" "ms-python.python" "ms-python.vscode-pylance" "ms-toolsai.jupyter" "ms-toolsai.jupyter-keymap" "ms-toolsai.jupyter-renderers" "ms-toolsai.vscode-jupyter-cell-tags" "ms-toolsai.vscode-jupyter-slideshow" "ms-vscode.cpptools" "rvest.vs-code-prettier-eslint" "sdras.night-owl" "vscode-icons-team.vscode-icons")

for extension in "${vscode_extensions[@]}";
do
    code --install-extension "$extension"
done

echo "Done"