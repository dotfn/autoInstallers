#!/bin/bash

configure_pacman() {
    echo "Configuring Pacman..."
    sudo sed -i 's/#Color/Color/g' "/etc/pacman.conf"
    sudo sed -i 's/ParallelDownloads = 5/ParallelDownloads = 20\nILoveCandy/g' "/etc/pacman.conf"
}

install_reflector() {
    echo "Installing reflector..."
    sudo pacman -Syu --noconfirm reflector
}

configure_mirrors() {
    echo "Configuring mirrors..."
    sudo reflector --protocol https --latest 10 --sort rate --age 48 \
    --country 'US' --country 'DE' --country 'FR' --country 'GB' --country 'CA' \
    --country 'SE' --country 'CH' --country 'NL' --country 'AU' --country 'ES' \
    --country 'AR' --country 'BR' --country 'CL' --country 'CO' --country 'MX' \
    --verbose --save /etc/pacman.d/mirrorlist
}

install_applications() {
    echo "Installing applications..."
    sudo pacman -S --noconfirm fastfetch keepassxc yt-dlp gnome-boxes exa
}

install_fonts() {
    echo "Installing fonts..."
    sudo pacman -S --noconfirm ttf-ubuntu-nerd ttf-cascadia-code-nerd
}

install_kde_tools() {
    echo "Installing KDE tools..."
    sudo pacman -S --noconfirm gwenview partitionmanager okular kdeconnect spectacle kdenlive haruna filelight kclock qpwgraph
}

setup_firewall() {
    echo "Installing and configuring the firewall..."
    sudo pacman -S --noconfirm ufw
    echo "Enabling the UFW service..."
    sudo systemctl enable ufw.service
    sudo ufw enable
}

install_kde_themes() {
    echo "Installing icon themes..."
    sudo pacman -S --noconfirm papirus-icon-theme
    echo "Configuring Papirus folders..."
    wget -qO- https://git.io/papirus-folders-install | sh
    papirus-folders -C bluegrey
}

install_hblock() {
    echo "Installing hblock..."
    sudo pacman -S --noconfirm hblock
    echo "Activating hblock..."
    hblock
}

install_obs_flatpak() {
    echo "Installing OBS via Flatpak..."
    sudo pacman -S flatpak
    flatpak install flathub com.obsproject.Studio
    flatpak run com.obsproject.Studio && exit
}

main() {
    configure_pacman
    install_reflector
    configure_mirrors
    install_applications
    install_fonts
    install_kde_tools
    setup_firewall
    install_kde_themes
    install_hblock
    install_obs_flatpak
    echo "Post-installation completed."
}

# Run the main function
main
