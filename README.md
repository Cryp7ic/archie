# Arch Linux Installation Guide

A guide for installing Arch Linux made by Cryp7ic.

> **Note:** GRUB bootloader, ext4 file system, DWM.

## Table of contents

- [Network Configuration](#network-configuration)
- [Disk Configuration](#disk-configuration)
- [Mounting](#mounting)
- [Installation](#installation)
- [Create File System Table](#create-file-system-table)
- [Set Zoneinfo](#set-zoneinfo)
- [GRUB](#grub)
- [Unmount & Reboot](#unmount-&-reboot)
- [DWM](#dwm)
- [Additional Packages](#additional-packages)

## Network Configuration

Check whether you have Internet connection.

```shell
$ ping 8.8.8.8
```

**Wi-Fi connections**

Get into interactive mode

```shell
[iwd]# iwctl
```

If you do not know your wireless device name, list the wireless devices:

```shell
[iwd]# device list
```

List all available networks:

```shell
[iwd]# station <device> get-networks
```

Connect to a network:

```shell
[iwd]# station <device> connect <"SSID">
```

If it is asking for a pass phrase, you can supply it as a command line argument:

```shell
$ iwctl --passphrase <passphrase> station <device> connect <"SSID">
```

## Disk Configuration

#### Disk Partitioning

**List disks**

```shell
$ lsblk
```

Choose the right disk..

In my case, it is /dev/sda

```shell
# gdisk /dev/sda
```

**EFI Partition**

Command (? for help): `n` - for 'New'

Partition number (1-128, default 1): `Enter`

First sector (...): `Enter`

Last sector (...): `+300M` - Stands for 300MB

Hex code or GUID (L to show codes, Enter = 8300): `ef00`

**Swap Partition**

Command (? for help): `n` - for 'New'

Partition number (2-128, default 2): `Enter`

First sector (...): `Enter`

Last sector (...): `+1024M` - Stands for 1GB

Hex code or GUID (L to show codes, Enter = 8300): `8200`

**Root Partition**

Command (? for help): `n` - for 'New'

Partition number (3-128, default 3): `Enter`

First sector (...): `Enter`

Last sector (...): `Enter`

Hex code or GUID (L to show codes, Enter = 8300): `Enter`

**Write**

`w`

#### Disk Formatting

**Check partitions:**

```shell
$ lsblk
```

**EFI Partition**

```shell
# mkfs.fat -F 32 /dev/sda1
```

**Swap Partition**

```shell
# mkswap /dev/sda2
```

**Root Partition**

```shell
# mkfs.ext4 /dev/sda3
```

## Mounting

```shell
# mkdir -p /mnt/boot/efi
```

```shell
# mount /dev/sda1 /mnt/boot/efi
```

```shell
# swapon /dev/sda2
```

```shell
# mount /dev/sda3 /mnt
```

Check:

```shell
$ lsblk
```

## Installation

```shell
# pacman -Sy archlinux-keyring
```

> intel-ucode for intel CPUs, amd-ucode for AMD CPUs

`pacstrap /mnt base linux linux-firmware git networkmanager dhcpcd neovim man-db intel-ucode sudo iwd sof-firmware grub efibootmgr`

## Create File System Table

`genfstab -U /mnt >> /mnt/etc/fstab`

`arch-chroot /mnt`

## Set Zoneinfo

**Find yours:**

```shell
# ls /usr/share/zoneinfo
```

```shell
# ln -sf /usr/share/zoneinfo/Europe/Tallinn /etc/localtime
```

```sh
# hwclock --systohc
```



```shell
# vim /etc/locale.gen
```

Uncomment "en_US.UTF-8 UTF-8"



```shell
# locale-gen
```



```shell
# echo "LANG=en_UK.UTF-8" >> /etc/locale.conf
```

**Keyboard:**

```shell
# echo "KEYMAP=en_US" >> /etc/vconsole.conf
```

**Hostname file:**

```shell
# echo "arch" >> /etc/hostname
```

**Optional:**

```shell
# mkinitcpio -P
```

**Hosts file:**

```shell
# echo "127.0.0.1 localhost" >> /etc/hosts
# echo "::1       localhost" >> /etc/hosts
# echo "127.0.1.1 arch.localdomain arch" >> /etc/hosts
```

**Add a root password:**

```shell
# passwd

<Enter root password>
```

**Add a user:**

```shell
# useradd -m -G wheel <username>
```

```shell
# echo "<username> ALL=(ALL) ALL" >> /etc/sudoers.d/<username>
```

## GRUB

Install GRUB:

```shell
# grub-install
```

```shell
# grub-mkconfig -o /boot/grub/grub.cfg
```

**Check if you can switch users**

```shell
# su <username>
```

## Unmount & Reboot

```shell
# exit
# exit
# umount -R /mnt
# reboot
```

```shell
# systemctl enable NetworkManager
# systemctl start NetworkManager
# networkctl
```

## DWM

**Update & download xorg**

```shell
$ sudo pacman -Syu
```

```shell
$ sudo pacman -S xorg xorg-xinit
```

**Downloading some packages**

```shell
sudo pacman -S alacritty picom feh firefox dolphin
```

**Download & configure DWM**

```shell
$ cd ~/.config
[cryp7ic@arch .config]$ git clone https://github.com/cryp7ic/dwm.git
$ cd dwm
$ sudo make clean install
```

Set the alacritty path in **config.def.h**

**dmenu**

```shell
[cryp7ic@dwm]$ cd ..
[cryp7ic@.sources]$ git clone https://git.suckless.org/dmenu
$ cd dmenu
$ nvim config.def.h
(Change the font size to 16)
$ sudo make clean install
```

**startx**

```shell
$ nvim .xinitrc
---
picom &
dwm
```

**Alacritty**

Download the official alacritty.yml file

```shell
$ mkdir ~/.config/alacritty
```

Now move the official .yml file into *~/.config/alacritty*

```shell
$ mv alacritty.yml ~/.config/alacritty/
```

Configure alacritty:

```shell
$ cd ~/.config/alacritty
```

```shell
$ nvim alacritty.yml
Uncomment: 

window

padding
x: 15
y: 15

opacity: 0.5


font
normal:
family: Fira Code
style: regular
size: 10.0
```

**fish shell**

```shell
$ sudo pacman -S fish
```

```shell
$ which fish
/usr/bin/fish
```

```shell
$ nvim ~/.config/alacritty/alacritty.yml
Uncomment:
fish:
program: /usr/bin/fish
args:
- --login
```

**Wallpapers**

```shell
$ feh --bg-fill /path/to/file.png
```

The file *.fehbg* sets the recently used wallpaper if run.

If you want to set the wallpaper on start every single time:

```shell
$ nvim .xinitrc
picom &
~/.fehbg &
dwm
```

**neofetch**

```shell
$ nvim .config/fish/config.fish

Add those lines:
function fish_greeting
	neofetch
end
```

**sxhkd**

sxhkd is used for hot key management

```shell
$ sudo pacman -S sxhkd
$ nvim .config/sxhkdrc
Configure it. (i have some functions in github (cryp7ic/dotfiles))
$ nvim .xinitrc

it should look like this:
sxhkd -c ~/.config/sxhkdrc &
picom &
~/.fehbg &
dwm
```

**Date & time**

```shell
$ mkdir .scripts
$ cd .scripts
$ nvim time.sh
---
#!/bin/sh

while true; do
	xsetroot -name "$(date)"
	sleep 1
done
```

```shell
$ chmod +x time.sh
```

```shell
$ cd ..
$ nvim .xinitrc
---
sxhkd -c ~/.config/sxhkdrc &
~/.scripts/time.sh &
picom &
~/.fehbg &
dwm
```

**Audio**

```shell
$ sudo pacman -S pavucontrol
```

**Running startx:**

```shell
$ startx
```

## Additional Packages

```shell
pacman -S papirus-icon-theme arc-gtk-theme network-manager-applet dialog wpa_supplicant mtools dosfstools  base-devel linux-headers avahi xdg-user-dirs xdg-utils gvfs gvfs-smb  nfs-utils inetutils dnsutils bluez bluez-utils cups hplip alsa-utils  pipewire pipewire-alsa pipewire-pulse pipewire-jack bash-completion rsync acpi acpi_call tlp virt-manager qemu  qemu-arch-extra edk2-ovmf bridge-utils dnsmasq vde2 openbsd-netcat  iptables-nft ipset firewalld nss-mdns acpid  os-prober virtualbox wireshark-qt flameshot discord haruna 
```

**Graphics card drivers**

AMD:

```shell
$ pacman -S --noconfirm xf86-video-amdgpu
```

NVIDIA:

```shell
$ pacman -S --noconfirm nvidia nvidia-utils nvidia-settings nvidia-prime
```

**Enabling services**

```shell
systemctl enable NetworkManager
systemctl enable bluetooth
systemctl enable cups.service
systemctl enable sshd
systemctl enable avahi-daemon
systemctl enable tlp
systemctl enable reflector.timer
systemctl enable fstrim.timer
systemctl enable libvirtd
systemctl enable firewalld
systemctl enable NetworkManager
systemctl enable bluetooth
systemctl enable cups.service
systemctl enable sshd
systemctl enable avahi-daemon
systemctl enable tlp 
systemctl enable reflector.timer
systemctl enable fstrim.timer
systemctl enable libvirtd
systemctl enable firewalld
systemctl enable acpid
```

Arch Linux (arch.conf)

> **Note:** To enable EFI for a virtual machine using the graphical interface, open the settings of the virtual machine, choose *System* item from the panel on the left and *Motherboard* tab from the right panel, and check the checkbox *Enable EFI (special OSes only)*.

