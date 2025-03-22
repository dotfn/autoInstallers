#!/bin/bash

# Stop the script if a command fails
set -e

# Function to handle errors
handle_error() {
    echo "Error: $1"
    exit 1
}

# Function to check internet connection
check_internet() {
    if ! ping -c 1 google.com &> /dev/null; then
        handle_error "No internet connection. Please check your connection and try again."
    fi
}

# Function to check sudo permissions
check_sudo() {
    if ! sudo -v &> /dev/null; then
        handle_error "This script requires sudo permissions. Please run the script as a user with privileges."
    fi
}

# Function to check disk space
check_disk_space() {
    local required_space=1000000 # Required space in KB (1GB)
    local available_space=$(df "$HOME" | awk 'NR==2 {print $4}')
    if [ "$available_space" -lt "$required_space" ]; then
        handle_error "Not enough disk space. At least 1GB is required."
    fi
}

# Function to install Zsh and Oh My Zsh
install_oh_my_zsh() {
    echo "Installing Zsh..."
    sudo pacman -S git zsh --noconfirm || handle_error "Failed to install Zsh."

    echo "Installing Oh My Zsh..."
    yes | sh -c "$(wget https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)" || handle_error "Failed to install Oh My Zsh."
}

# Function to clone Zsh plugins
clone_plugin() {
    local repo_url=$1
    local dest_dir=$2

    # Remove the plugin directory if it already exists
    [ -d "$dest_dir" ] && rm -rf "$dest_dir"

    # Clone the repository
    git clone "$repo_url" "$dest_dir" || handle_error "Failed to clone the repository: $repo_url"
    echo "Plugin installed at: $dest_dir"
}

# Function to install plugins
install_plugins() {
    declare -a plugins=(
        "https://github.com/zsh-users/zsh-syntax-highlighting.git"
        "https://github.com/zsh-users/zsh-autosuggestions.git"
        "https://github.com/zsh-users/zsh-completions.git"
        "https://github.com/zsh-users/zsh-history-substring-search.git"
    )

    for plugin in "${plugins[@]}"; do
        clone_plugin "$plugin" "$HOME/.oh-my-zsh/custom/plugins/$(basename "$plugin" .git)"
    done
}

# Function to update .zshrc
update_zshrc() {
    if ! grep -q "plugins=(" "$HOME/.zshrc"; then
        echo "plugins=(git)" >> "$HOME/.zshrc" || handle_error "Failed to add plugins to .zshrc."
    fi

    # Add new plugins to the list
    local plugins_to_add=("zsh-syntax-highlighting" "zsh-autosuggestions" "zsh-completions" "zsh-history-substring-search")
    for plugin in "${plugins_to_add[@]}"; do
        if ! grep -q "$plugin" "$HOME/.zshrc"; then
            sed -i "/^plugins=(/ s/)/ $plugin)/" "$HOME/.zshrc" || handle_error "Failed to update .zshrc with the plugin: $plugin"
        fi
    done
}

# Function to install Powerlevel10k
install_powerlevel10k() {
    echo "Installing Powerlevel10k..."
    local powerlevel10k_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"

    # Remove the existing directory if it already exists
    [ -d "$powerlevel10k_dir" ] && rm -rf "$powerlevel10k_dir"

    # Clone the repository
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$powerlevel10k_dir" || handle_error "Failed to clone Powerlevel10k."

    # Change the theme in .zshrc
    sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="powerlevel10k\/powerlevel10k"/g' "${ZDOTDIR:-$HOME}/.zshrc" || handle_error "Failed to change the theme in .zshrc."
    echo "Powerlevel10k has been installed."
}

# Function to install fonts
install_font() {
    local font_name=$1
    echo "Installing $font_name..."
    sudo pacman -S "$font_name" --noconfirm || handle_error "Failed to install $font_name."
    echo "The font $font_name has been installed."
    # Wait for the user to press Enter to continue
    read -p "Press Enter to continue..."
}

# Main function that executes the script
main() {
    # Clear the terminal
    clear

    # Check internet connection
    check_internet

    # Check sudo permissions
    check_sudo

    # Check disk space
    check_disk_space

    # Check if Oh My Zsh is installed
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        echo "Oh My Zsh is not installed. Installing Oh My Zsh..."
        install_oh_my_zsh
    else
        echo "Oh My Zsh is already installed."
    fi

    # Install plugins
    install_plugins

    # Update .zshrc
    update_zshrc

    # Clear the terminal before asking about Powerlevel10k
    clear

    # Ask the user if they want to install Powerlevel10k
    read -p "Do you want to install Powerlevel10k? (y/n): " install_powerlevel10k
    if [[ "$install_powerlevel10k" =~ ^[yY]$ ]]; then
        install_powerlevel10k

        # Ask the user which fonts they want to install
        while true; do
            echo "Which fonts do you want to install?"
            echo "1) ttf-ubuntu-nerd"
            echo "2) ttf-cascadia-code-nerd"
            echo "3) Both"
            echo "4) None"
            read -p "Select an option (1-4): " font_choice

            case $font_choice in
                1)
                    install_font "ttf-ubuntu-nerd"
                    fonts_installed=true
                    break
                    ;;
                2)
                    install_font "ttf-cascadia-code-nerd"
                    fonts_installed=true
                    break
                    ;;
                3)
                    install_font "ttf-ubuntu-nerd"
                    install_font "ttf-cascadia-code-nerd"
                    fonts_installed=true
                    break
                    ;;
                4)
                    clear
                    echo "No fonts will be installed."
                    break
                    ;;
                *)
                    clear
                    echo "Invalid option. Please select an option from 1 to 4."
                    ;;
            esac
        done
    fi

    # Change the default shell to Zsh if it is not the current shell
    if [ "$SHELL" != "$(which zsh)" ]; then
        chsh -s "$(which zsh)" || handle_error "Failed to change the default shell to Zsh."
    else
        echo "Zsh is already set as your default shell."
    fi

    # Final message
    clear
    echo "Installation and configuration of plugins completed."
    echo "Zsh has been set as your default shell."
    echo ""
    echo "Please close and reopen your terminal to start using Zsh and configure Powerlevel10k for the first time."

    # Message about the fonts
    if [ "$fonts_installed" = true ]; then
        echo "Remember to set the installed fonts as default fonts in your terminal to improve the display of Powerlevel10k."
    fi

    # Wait for the user to press Enter to finish
    read -p "Press Enter to finish..."
}

# Run the main function
main
