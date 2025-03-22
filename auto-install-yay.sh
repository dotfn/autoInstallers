#!/bin/bash

set -e  # Stop the script if there is an error

# Update the system and ensure git and base-devel are installed
sudo pacman -Syu --needed git base-devel --noconfirm

# Check if yay is already installed
if command -v yay &> /dev/null; then
    echo "yay is already installed."
else
    # Clone the yay repository
    git clone --depth 1 https://aur.archlinux.org/yay.git

    # Change to the yay directory and build and install yay
    (
        cd yay
        yes | makepkg -si
    )

    # Remove the yay directory
    rm -rf yay

    echo "yay has been installed and temporary files have been removed."
fi

# Ask the user if they want to install AUR packages
read -p "Do you want to install some AUR packages? (y/n): " response

if [[ "$response" =~ ^[yY]$ ]]; then
    while true; do
        echo "Select the packages you want to install (you can select multiple options separated by spaces):"
        echo "Example: to install Visual Studio Code and Brave, type: 1 2"
        echo "1) Visual Studio Code (visual-studio-code-bin)"
        echo "2) Brave Browser (brave-bin)"
        echo "3) Volta (volta)"
        echo "4) Node Version Manager (nvm)"
        echo "5) None"

        read -r options

        # Convert the input into an array
        read -r -a selected <<< "$options"

        # Check if at least one valid option was selected
        if [[ " ${selected[@]} " =~ " 1 " || " ${selected[@]} " =~ " 2 " || " ${selected[@]} " =~ " 3 " || " ${selected[@]} " =~ " 4 " ]]; then
            for option in "${selected[@]}"; do
                case $option in
                    1) yay -S --noconfirm visual-studio-code-bin ;;
                    2) yay -S --noconfirm brave-bin ;;
                    3) yay -S --noconfirm volta ;;
                    4) yay -S --noconfirm nvm ;;
                    *) echo "Invalid option: $option" ;;
                esac
            done
            break  # Exit the loop if at least one valid option was selected
        else
            clear
            echo "No valid option was selected. Please try again."
        fi
    done
else
    echo "No packages will be installed."
fi
