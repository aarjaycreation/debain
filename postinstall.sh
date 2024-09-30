#!/bin/bash

# Define base directories
USER_HOME="/home/$USER"
CONFIG_DIR="$USER_HOME/.config"
SCRIPTS_DIR="$USER_HOME/debain/scripts"
DOTFILES_DIR="$USER_HOME/debain/dotfiles"
DESTINATION="$CONFIG_DIR"

# Check if script is running as root
if [[ $EUID -ne 0 ]]; then
    echo -e "${RED}This script must be run as root${NC}" 1>&2
    exit 1
fi

# Define colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Running script...${NC}"

# Create directories safely
mkdir -p "$CONFIG_DIR"
mkdir -p "$USER_HOME/scripts"

chown -R "$USER":"$USER" "$SCRIPTS_DIR"

# Copy scripts from the debain folder
echo -e "${GREEN}Copying scripts...${NC}"
sudo cp -r "$SCRIPTS_DIR/"* "$USER_HOME/scripts/" || { echo -e "${RED}Failed to copy scripts${NC}"; exit 1; }

# Navigate to scripts directory safely
if [ -d "$USER_HOME/scripts" ]; then
    cd "$USER_HOME/scripts" || { echo -e "${RED}Failed to navigate to scripts directory.${NC}"; exit 1; }
    chmod +x install_packages install_nala picom
    ./install_packages || { echo -e "${RED}Failed to run install_packages.${NC}"; exit 1; }
else
    echo -e "${RED}Scripts directory does not exist.${NC}"
    exit 1
fi

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
chown -R "$USER":"$USER" "$USER_HOME/scripts"
chown "$USER":"$USER" "$USER_HOME/.bashrc"
chown -R "$USER":"$USER" "$USER_HOME/.local"
chown "$USER":"$USER" "$USER_HOME/.xinitrc"

# Timezone configuration
echo -e "${GREEN}---------------------------------------------------"
echo -e "                 Updating Timezone"
echo -e "---------------------------------------------------${NC}"

if command -v apt > /dev/null 2>&1; then
    dpkg-reconfigure tzdata || { echo -e "${YELLOW}Timezone reconfiguration failed.${NC}"; }
else
    echo -e "${YELLOW}Unable to detect APT. Skipping timezone configuration.${NC}"
fi

# Building DWM and SLStatus
echo -e "${GREEN}---------------------------------------------------"
echo -e "            Building DWM and SLStatus"
echo -e "---------------------------------------------------${NC}"

for dir in dwm slstatus; do
    cd "$CONFIG_DIR/suckless/$dir" || { echo -e "${RED}Failed to navigate to $dir${NC}"; exit 1; }
    make clean install || { echo -e "${RED}Build failed for $dir.${NC}"; exit 1; }
done

# Prompt to run Linux Toolbox
while true; do
    read -r -p "Do you want to start Linux Toolbox? (y/n): " response
    case $response in
        [Yy]* )
            echo -e "${YELLOW}Press Q to exit ${NC}"
            echo -e "${GREEN}Launching in...${NC}"
            for i in {5..1}; do
                echo -e "${YELLOW}$i..${NC}"
                sleep 1
            done
            curl -fsSL https://christitus.com/linux | sh
            break
            ;;
        [Nn]* )
            echo -e "${GREEN}Skipping...${NC}"
            break
            ;;
        * )
            echo -e "${RED}Please answer y or n.${NC}"
            ;;
    esac
done

# Prompt for reboot
while true; do
    read -r -p "Do you want to restart the system now? (y/n): " response
    case $response in
        [Yy]* )
            echo -e "${GREEN}Restarting the system...${NC}"
            reboot
            break
            ;;
        [Nn]* )
            echo -e "${GREEN}Restart skipped. Please remember to restart your system later.${NC}"
            break
            ;;
        * )
            echo -e "${RED}Please answer y or n.${NC}"
            ;;
    esac
done
