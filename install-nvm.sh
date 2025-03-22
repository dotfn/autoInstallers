#!/bin/zsh
# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No color
# Script to install and configure NVM on Arch Linux

# Check if NVM is already installed
if [ -d "$HOME/.nvm" ]; then
    echo "${GREEN}NVM is already installed in $HOME/.nvm. ${NC}"
else
    # Clone the NVM repository
    echo "${YELLOW}Cloning the NVM repository... ${NC}"
    git clone https://github.com/nvm-sh/nvm.git ~/.nvm

    # Change to the NVM directory and get the latest version
    cd ~/.nvm
    git checkout `git describe --abbrev=0 --tags`
fi

# Add configuration to .bashrc or .zshrc
if [ -f "$HOME/.zshrc" ]; then
    SHELL_CONFIG="$HOME/.zshrc"
elif [ -f "$HOME/.bashrc" ]; then
    SHELL_CONFIG="$HOME/.bashrc"
else
    echo "Neither .bashrc nor .zshrc was found. Aborting."
    exit 1
fi

# Check if the NVM configuration lines are already in the config file
#if ! grep -q "export NVM_DIR=\"$HOME/.nvm\"" "$SHELL_CONFIG"; then
#    echo "Adding NVM configuration to $SHELL_CONFIG..."
#        ### If it already exists, I need to remove them <------------------------------------------------------------------------
#    {
#        echo "export NVM_DIR=\"$HOME/.nvm\""
#        echo "[ -s \"$NVM_DIR/nvm.sh\" ] && \. \"$NVM_DIR/nvm.sh\" # This loads nvm"
#        echo "[ -s \"$NVM_DIR/bash_completion\" ] && \. \"$NVM_DIR/bash_completion\" # This loads nvm bash_completion"
#    } >> "$SHELL_CONFIG"
#else
#    echo -e "${RED}NVM configuration is already present in $SHELL_CONFIG.${NC}"
#    {
#        echo "export NVM_DIR=\"$HOME/.nvm\""
#        echo "[ -s \"$NVM_DIR/nvm.sh\" ] && \. \"$NVM_DIR/nvm.sh\" # This loads nvm"
#        echo "[ -s \"$NVM_DIR/bash_completion\" ] && \. \"$NVM_DIR/bash_completion\" # This loads nvm bash_completion"
#    } >> "$SHELL_CONFIG"
#fi
#
# Load the NVM configuration in the current session
# echo "HELLO"
source "$SHELL_CONFIG"
# echo "END HELLO"
#
# Check the NVM installation
echo "${YELLOW}Checking the NVM installation...${NC}"
if command -v nvm &> /dev/null; then
    echo "NVM installed successfully. Version: $(nvm --version)"
else
    echo -e "${RED}Error: NVM did not install correctly.${NC}"
    exit 1
fi

# Install the latest LTS version of Node.js
echo "Installing the latest LTS version of Node.js..."
nvm install --lts

# Inform the user that the installation has completed
echo -e "${BLUE}NVM installation and configuration completed.${NC}"
echo -e "${GREEN}NVM and the latest LTS version of Node.js have been installed successfully.${NC}"
