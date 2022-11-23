#!/bin/bash

sudo timedatectl set-ntp true
sudo hwclock --systohc

sudo reflector -c Switzerland -a 12 --sort rate --save /etc/pacman.d/mirrorlist
sudo pacman -Syy

sudo firewall-cmd --add-port=1025-65535/tcp --permanent
sudo firewall-cmd --add-port=1025-65535/udp --permanent
sudo firewall-cmd --reload
# sudo virsh net-autostart default

git clone https://aur.archlinux.org/pikaur.git
cd pikaur/
makepkg -si --noconfirm

#pikaur -S --noconfirm lightdm-slick-greeter 
#pikaur -S --noconfirm lightdm-settings
#pikaur -S --noconfirm polybar
#pikaur -S --noconfirm nerd-fonts-iosevka
#pikaur -S --noconfirm ttf-icomoon-feather

#pikaur -S --noconfirm system76-power
#sudo systemctl enable --now system76-power
#sudo system76-power graphics integrated
#pikaur -S --noconfirm gnome-shell-extension-system76-power-git
#pikaur -S --noconfirm auto-cpufreq
#sudo systemctl enable --now auto-cpufreq

echo "MAIN PACKAGES"

sleep 5

sudo pacman -S --noconfirm archlinux-keyring qemu virt-manager virt-viewer vde2 bridge-utils openbsd-netcat vim zathura-pdf-mupdf zathura flameshot opera-ffmpeg-codecs opera nvidia-prime obsidian discord signal-desktop code wireshark-qt wireshark-cli virtualbox terminator fish steam obs-studio nicotine+ telegram-desktop github-cli qbittorrent neofetch bpytop nvtop htop ranger dolphin papirus-icon-theme ntfs-3g strawberry youtube-dl haruna xorg light-locker lightdm bspwm sxhkd firefox rxvt-unicode picom nitrogen lxappearance dmenu nautilus arandr simplescreenrecorder alsa-utils pulseaudio alsa-utils pulseaudio-alsa pavucontrol arc-gtk-theme arc-icon-theme obs-studio vlc dina-font tamsyn-font bdf-unifont ttf-bitstream-vera ttf-croscore ttf-dejavu ttf-droid gnu-free-fonts ttf-ibm-plex ttf-liberation ttf-linux-libertine noto-fonts ttf-roboto tex-gyre-fonts ttf-ubuntu-font-family ttf-anonymous-pro ttf-cascadia-code ttf-fantasque-sans-mono ttf-fira-mono ttf-hack ttf-fira-code ttf-inconsolata ttf-jetbrains-mono ttf-monofur adobe-source-code-pro-fonts cantarell-fonts inter-font ttf-opensans gentium-plus-font ttf-junicode adobe-source-han-sans-otc-fonts adobe-source-han-serif-otc-fonts noto-fonts-cjk noto-fonts-emoji ttf-font-awesome awesome-terminal-fonts archlinux-wallpaper rofi playerctl scrot obs-studio dunst pacman-contrib

#sudo flatpak install -y spotify
#sudo flatpak install -y kdenlive

sudo systemctl enable lightdm

mkdir -p .config/{bspwm,sxhkd,dunst}

install -Dm755 /usr/share/doc/bspwm/examples/bspwmrc ~/.config/bspwm/bspwmrc
install -Dm644 /usr/share/doc/bspwm/examples/sxhkdrc ~/.config/sxhkd/sxhkdrc

printf "\e[1;32mCHANGE NECESSARY FILES BEFORE REBOOT\e[0m"

# dnsmasq firefox iptables openssh ebtables
