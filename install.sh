#!/bin/bash

GREEN="\033[1;32m"
RED="\033[1;31m"
YELLOW="\033[1;33m"
NC="\033[0m"

echo -e "${YELLOW}Running script...${NC}"

# Define base directories
USER_HOME="/home/$USER"
CONFIG_DIR="$USER_HOME/.config"
SCRIPTS_DIR="$USER_HOME/debain/scripts"
DOTFILES_DIR="$USER_HOME/debain/dotfiles"
DESTINATION="$CONFIG_DIR"




# Corrected the path to scripts directory for chown
chown -R "$USER":"$USER" "$SCRIPTS_DIR"

echo -e "${GREEN}---------------------------------------------------"
echo -e "${GREEN}            Installing dependencies"
echo -e "${GREEN}---------------------------------------------------${NC}"

# Create directories safely
mkdir -p "$CONFIG_DIR"
cd "$SCRIPTS_DIR"

# Make sure all scripts are executable

sudo chmod +x install_packages
sudo chmod +x install_nala
sudo chmod +x picom
# ./install_packages
pwd

# Moving dotfiles to correct location
echo -e "${GREEN}---------------------------------------------------"
echo -e "       Moving dotfiles to correct location"
echo -e "---------------------------------------------------${NC}"

if [ -d "$DOTFILES_DIR" ]; then
    cp -r "$DOTFILES_DIR/alacritty" "$DOTFILES_DIR/backgrounds" "$DOTFILES_DIR/fastfetch" \
          "$DOTFILES_DIR/kitty" "$DOTFILES_DIR/picom" "$DOTFILES_DIR/rofi" \
          "$DOTFILES_DIR/suckless" "$DESTINATION/" || { echo -e "${RED}Failed to copy dotfiles.${NC}"; exit 1; }

    cp "$DOTFILES_DIR/.bashrc" "$USER_HOME/" || { echo -e "${RED}Failed to copy .bashrc.${NC}"; exit 1; }
    cp -r "$DOTFILES_DIR/.local" "$USER_HOME/" || { echo -e "${RED}Failed to copy .local directory.${NC}"; exit 1; }
    cp "$DOTFILES_DIR/.xinitrc" "$USER_HOME/" || { echo -e "${RED}Failed to copy .xinitrc.${NC}"; exit 1; }
else
    echo -e "${RED}Dotfiles directory does not exist.${NC}"
    exit 1
fi

# Fixing permissions
echo -e "${GREEN}---------------------------------------------------"
echo -e "            Fixing Home dir permissions"
echo -e "---------------------------------------------------${NC}"

chown -R "$USER":"$USER" "$CONFIG_DIR"
chown "$USER":"$USER" "$USER_HOME/.bashrc"
chown -R "$USER":"$USER" "$USER_HOME/.local"
chown "$USER":"$USER" "$USER_HOME/.xinitrc"

# echo -e "${GREEN}---------------------------------------------------"
# echo -e "${GREEN}                 Updating Timezone"
# echo -e "${GREEN}---------------------------------------------------${NC}"

# if command -v apt > /dev/null 2>&1; then
#     sudo dpkg-reconfigure tzdata
# else
#     echo -e "${YELLOW}Unable to detect APT. Skipping."
# fi

# echo -e "${GREEN}---------------------------------------------------"
# echo -e "${GREEN}            Building DWM and SLStatus"
# echo -e "${GREEN}---------------------------------------------------${NC}"

# cd "$HOME/.config/suckless/dwm"
# sudo make clean install 
# cd "$HOME/.config/suckless/slstatus"
# sudo make clean install 

# if [ $? -eq 0 ]; then
#     echo -e "${GREEN}Build completed successfully.${NC}"
# else
#     echo -e "${RED}Build failed. Check the log file for details: $LOG_FILE${NC}"
# fi

# echo -e "${GREEN}---------------------------------------------------${NC}"
# echo -e "${GREEN}    Do you want to start Linux Toolbox? (y/n)"
# echo -e "${GREEN}---------------------------------------------------${NC}"

# read response

# if [[ "$response" == "y" || "$response" == "Y" ]]; then
#     echo -e "${YELLOW}Press Q to exit ${NC}"
#     echo -e "${GREEN}Launching in...${NC}"

#     echo -e "${YELLOW}5..${NC}"
#     sleep 1
#     echo -e "${YELLOW}4..${NC}"
#     sleep 1
#     echo -e "${YELLOW}3..${NC}"
#     sleep 1
#     echo -e "${YELLOW}2..${NC}"
#     sleep 1
#     echo -e "${YELLOW}1..${NC}"

#     curl -fsSL https://christitus.com/linux | sh
# else
#     echo -e "${GREEN}Skipping...${NC}"
# fi

# echo -e "${GREEN}---------------------------------------------------"
# echo -e "${GREEN}     Script finished. Reboot is recommended"
# echo -e "${GREEN}---------------------------------------------------${NC}"
# echo -e "${GREEN}    Do you want to restart the system now? (y/n)"
# echo -e "${GREEN}---------------------------------------------------${NC}"

# read response

# if [[ "$response" == "y" || "$response" == "Y" ]]; then
#     echo -e "${GREEN}Restarting the system...${NC}"
#     sudo reboot
# else
#     echo -e "${GREEN}Restart skipped. Please remember to restart your system later.${NC}"
# fi