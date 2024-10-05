#!/bin/bash
#
# Install programs for my Debian DWM Desktop

echo "Will Create folders  pattern in portuguese"
mkdir -p /home/$USER/{Desktop,Downloads,Documentos,git,Imagens/Screenshoots,Músicas,.lyrics,.programas,.appimage}

echo "install git"
sudo apt install -y git stow timeshift

# Create backup in timeshift
sudo timeshift --create --comments "First, before install suckless programs"

# Instalando suckless build
echo "Instalando suckless build..."

# DWM debian
sudo apt install -y make gcc build-essential libx11-dev libxft-dev libxinerama-dev  \
    libharfbuzz-dev  libimlib2-dev libxrandr-dev libxcb-res0-dev libx11-xcb-dev libxcb-util0-dev

# dwm
git clone https://github.com/nosrednawall/suckless.git ~/.config/suckless
cd ~/.config/suckless/dwm
mkdir -p ~/.fonts
cp fonts/* ~/.fonts/
fc-cache -fvr
sudo make clean install

# Copy autostart dwm - I have this files in dotfiles repository
#mkdir -p ~/.local/share/dwm
#cp autostart.sh ~/.local/share/dwm/
#cp autostart_blocking.sh ~/.local/share/dwm/

# Copy desktop laucher for session manager
sudo cp dwm.desktop /usr/share/xsessions

cd ../st
sudo make clean install

cd ../dmenu
sudo make clean install

cd ../dwmblocks-async
sudo make clean install

cd ../slock
sudo make clean install

# create backup in timeshift
sudo timeshift --create --comments "before install drivers"

# Dependencias para o ambiente
# Programs
sudo apt install -y aptitude xserver-xorg curl htop pv lm-sensors picom rofi network-manager dunst xdotool copyq xautolock feh libnotify-bin \
    pinentry-gnome3 ssh-askpass-gnome

# Drivers nvidia
install_drivers_nvidia() {
    echo "Instalando drivers nvidia"
    # Driver Nvidia
    sudo apt install -y dkms linux-headers-amd64 firmware-misc-nonfree
    sudo apt install -y nvidia-driver nvidia-xconfig xserver-xorg-video-amdgpu \
        nvidia-cuda-dev nvidia-cuda-toolkit libnvidia-encode1
    # sudo reboot
    sudo nvidia-xconfig --prime

}

# Drivers amd
install_drivers_amd() {
    echo "Instalando drivers amd"
    sudo apt install -y firmware-amd-graphics libgl1-mesa-dri libglx-mesa0 \
        mesa-vulkan-drivers xserver-xorg-video-all
}

# Drivers Intel
install_drivers_intel() {
    echo "Instalando drivers intel"
    sudo apt install -y xserver-xorg-video-intel libgl1-mesa-dri libglx-mesa0 \
        mesa-vulkan-drivers xserver-xorg-video-all
}

# Funcao para o usuario escolher qual drive de vídeo quer instalar
escolha_driver() {
    local wm_name="$1"
    echo "$wm_name Instalação"
    echo "1. Instalar $wm_name com driver Nvdia"
    echo "2. Instalar $wm_name com driver Amd"
    echo "3. Instalar $wm_name com driver Intel"
    echo "Ou ENTER para pular"
    read -r choice

   case "$choice" in
        1)
            install_drivers_nvidia
            ;;
        2)
            install_driver_amd
            ;;
        3)
            install_driver_intel
            ;;
        *)
            echo "Pulando essa etapa, e instalando o resto..."
            ;;
    esac

    # Adding a couple of line returns
    echo -e "\n\n"
}

# Apresenta um prompt para escolher o driver
escolha_driver


# Session Manager
sudo apt install -y lightdm  lightdm-gtk-greeter

choise_laptop_acer() {
    echo "This hardware is a Acer Laptop? If Yes then install this configuration"
    echo "1. Install script for change primary monitor in lightdm"
    echo "Or Enter to skip..."
    read -r choice

    case "$choice" in
        1)
            # Configure laptop monitor to first in lightdm
            sudo cat > /usr/share/multiple-monitors.sh << EOF
#!/bin/bash
xrandr --output  HDMI-0 --off --output eDP-1-1 --primary --mode 1920x1080 --rotate normal --dpi 96
EOF
            sudo chmod +x /usr/share/multiple-monitors.sh
            sudo sed -i 's|^\#display-setup-script=|display-setup-script=/usr/share/multiple-monitors.sh|' /etc/lightdm/lightdm.conf
            ;;
        *)
            echo "Skiping ...."
            ;;
    esac

    # Battery
    sudo apt install -y xfce4-power-manager tlp
    sudo systemctl enable --now tlp

    # Adding a couple of line returns
    echo -e "\n\n"
}
choise_laptop_acer

# Enable the service
sudo systemctl enable lightdm.service

# Appearence
sudo apt install -y numix-icon-theme-circle papirus-icon-theme lxappearance \
    qt5ct qt5-style-plugins

# File manager
sudo apt install -y thunar ranger thunar-archive-plugin thunar-media-tags-plugin \
    gvfs-backends gvfs smbclient samba

# extracao de arquivos
sudo apt install -y arc arj cabextract lhasa p7zip p7zip-full p7zip-rar rar \
    unrar unace unzip xz-utils zip xarchiver

# Bluetooth
sudo apt install blueman bluez bluez-firmware

# Conky
sudo apt install conky-all

# Brightness
sudo apt install -y brightnessctl redshift

# Sound
choise_sound_program(){
    echo "Select your sound software prefer:"
    echo "1. Pulseaudio"
    echo "2. Pipewire"
    echo "Or Enter to skip..."
    read -r choice

    case "$choice" in
        1)
            sudo apt install -y pulseaudio pavucontrol pamixer
            ;;
        2)
            sudo apt install pipewire pipewire-pulse wireplumber pipewire-media-session pulsemixer
            systemctl --user --now enable wireplumber.service
            ;;
        *)
            echo "skiping ..."
            ;;
    esac
    # Adding a couple of line returns
    echo -e "\n\n"
}

choise_sound_program

# Music
sudo apt install -y playerctl mpd ncmpcpp mpc
sudo systemctl disable mpd  # Disable service
sudo systemctl stop  mpd  # Stop
systemctl --user enable mpd  # Enable by user

# Video
sudo apt install -y mpv ytfzf vlc yt-dlp

# Pass, qtpass, pinentry e askpass
sudo apt install -y pass qtpass pinentry-gnome3 ssh-askpass-gnome

# Fonts
sudo apt install -y cabextract curl fontconfig xfonts-utils
sudo apt install -y ttf-mscorefonts-installer

# Office
sudo apt install -y libreoffice-gtk3 libreoffice-l10n-pt-br libreoffice atril xournalpp qalculate-gtk

# Programs for tilling windows managers
sudo apt install -y feh rofi network-manager xautolock picom dunst xdotool copyq solaar blueman flameshot btop libnotify-bin gpicview

# Google-chrome
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo apt install -y ./google-chrome-stable_current_amd64.deb
sudo apt install -f -y
rm -rf google-chrome-stable_current_amd64.deb

# Flatpak
sudo apt install flatpak
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
flatpak install  ch.openboard.OpenBoard
flatpak install  com.bitwarden.desktop
flatpak install  com.discordapp.Discord
flatpak install  com.github.KRTirtho.Spotube
flatpak install  com.github.d4nj1.tlpui
flatpak install  com.github.tchx84.Flatseal
flatpak install  com.obsproject.Studio
flatpak install  io.dbeaver.DBeaverCommunity
flatpak install  io.freetubeapp.FreeTube
flatpak install  io.github.flattool.Warehouse
flatpak install  md.obsidian.Obsidian
flatpak install  org.filezillaproject.Filezilla
flatpak install  org.jupyter.JupyterLab
flatpak install  org.mozilla.Thunderbird
flatpak install  org.telegram.desktop


choise_term_program(){
    echo "Select your sound software prefer:"
    echo "1. OhMyBash"
    echo "2. ZSh + OhMyZsh"
    echo "3. Fish"
    echo "Or Enter to skip..."
    read -r choice

    case "$choice" in
        1)
            #Instala o Oh My Bash
            cd ~
            bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh)"
            rm .bashrc
            # stow bashrc in .dotfiles
            ;;
        2)
            echo "Under contruction ..."
            ;;
        3)
            echo "Under contruction ..."
            ;;
        *)
            echo "skiping ..."
            ;;
    esac
    # Adding a couple of line returns
    echo -e "\n\n"
}

choise_term_program

echo "cloning dotfiles"
git clone https://github.com/nosrednawall/dotfiles ~/.dotfiles/

cd ~/.dotfiles
stow .

# emacs and doom emacs
sudo apt install emacs-lucid ripgrep fd-find findutils
git clone --depth 1 https://github.com/doomemacs/doomemacs ~/.config/emacs
~/.config/emacs/bin/doom install

# create backup in timeshift
sudo timeshift --create --comments "after install all"

echo "All installations completed."
