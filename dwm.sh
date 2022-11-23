#!/bin/bash

# Variables
country=Poland
kbmap=ch
output=Virtual-1
resolution=1920x1080

# Options
aur_helper=true
install_ly=true
gen_xprofile=false

sudo timedatectl set-ntp true
sudo hwclock --systohc
sudo reflector -c $country -a 12 --sort rate --save /etc/pacman.d/mirrorlist

# sudo firewall-cmd --add-port=1025-65535/tcp --permanent
# sudo firewall-cmd --add-port=1025-65535/udp --permanent
# sudo firewall-cmd --reload
# sudo virsh net-autostart default

if [[ $aur_helper = true ]]; then
    cd /tmp
    git clone https://aur.archlinux.org/paru.git
    cd paru/;makepkg -si --noconfirm;cd
fi

# Install packages
sudo pacman -S xorg firefox polkit-gnome nitrogen lxappearance thunar

# Install fonts
sudo pacman -S --noconfirm dina-font tamsyn-font bdf-unifont ttf-bitstream-vera ttf-croscore ttf-dejavu ttf-droid gnu-free-fonts ttf-ibm-plex ttf-liberation ttf-linux-libertine noto-fonts ttf-roboto tex-gyre-fonts ttf-ubuntu-font-family ttf-anonymous-pro ttf-cascadia-code ttf-fantasque-sans-mono ttf-fira-mono ttf-hack ttf-fira-code ttf-inconsolata ttf-jetbrains-mono ttf-monofur adobe-source-code-pro-fonts cantarell-fonts inter-font ttf-opensans gentium-plus-font ttf-junicode adobe-source-han-sans-otc-fonts adobe-source-han-serif-otc-fonts noto-fonts-cjk noto-fonts-emoji

# Pull Git repositories and install
cd /tmp
repos=( "dmenu" "dwm" "dwmstatus" "st" "slock" )
for repo in ${repos[@]}
do
    git clone git://git.suckless.org/$repo
    cd $repo;make;sudo make install;cd ..
done

# XSessions and dwm.desktop
if [[ ! -d /usr/share/xsessions ]]; then
    sudo mkdir /usr/share/xsessions
fi

cat > ./temp << "EOF"
[Desktop Entry]
Encoding=UTF-8
Name=Dwm
Comment=Dynamic window manager
Exec=dwm
Icon=dwm
Type=XSession
EOF
sudo cp ./temp /usr/share/xsessions/dwm.desktop;rm ./temp

# Install ly
if [[ $install_ly = true ]]; then
    git clone https://aur.archlinux.org/ly
    cd ly;makepkg -si
    sudo systemctl enable ly
fi

# .xprofile
if [[ $gen_xprofile = true ]]; then
cat > ~/.xprofile << EOF
setxkbmap $kbmap
nitrogen --restore
xrandr --output $output --mode $resolution
EOF
fi

printf "\e[1;32mDone! you can now reboot.\e[0m\n"