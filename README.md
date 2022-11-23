░█████╗░██████╗░░█████╗░██╗░░██╗██╗███████╗
██╔══██╗██╔══██╗██╔══██╗██║░░██║██║██╔════╝
███████║██████╔╝██║░░╚═╝███████║██║█████╗░░
██╔══██║██╔══██╗██║░░██╗██╔══██║██║██╔══╝░░
██║░░██║██║░░██║╚█████╔╝██║░░██║██║███████╗
╚═╝░░╚═╝╚═╝░░╚═╝░╚════╝░╚═╝░░╚═╝╚═╝╚══════╝
## Table of contents

- [Disk Partitioning](#disk-partitioning)
- [Mount](#mount)

### Disk Partitioning

List disks

`# lsblk`

Choose the right disk..

In my case, it is /dev/sda

`# gdisk /dev/sda`

#### EFI Partition

Command (? for help): `n` - for 'New'

Partition number (1-128, default 1): `Enter`

First sector (...): `Enter`

Last sector (...): `+500M` - Stands for 500MB

Hex code or GUID (L to show codes, Enter = 8300): `ef00`

#### BTRFS Partition

Command (? for help): `n` - for 'New'

Partition number (2-128, default 2): `Enter`

First sector (...): `Enter`

Last sector (...): `Enter`

Hex code or GUID (L to show codes, Enter = 8300): `Enter`

#### Write

`w`

`y`

#### Formatting

`lsblk` to check the partition's names.

**EFI Partition**

`mkfs.fat -F32 /dev/sda1`

**BTRFS Partition with Encryption**

`cryptsetup --cipher aes-xts-plain64 --hash sha512 --use-random --verify-passphrase luksFormat /dev/sda2`

Are you sure?: `YES`

Enter passphrase for /dev/sda3: `your password`

Verify passphrase: `your password`

**Now we need to open the disk in order to use it**

`cryptsetup luksOpen /dev/sda2 <partition name>`, I call it `encrypted`

Enter passphrase: `your password`

**Now we can format this partition**

`mkfs.btrfs /dev/mapper/encrypted`

### Mount & Subvolumes

`mount /dev/mapper/encrypted /mnt`

`cd /mnt`

`btrfs subvolume create @`

`btrfs subvolume create @home`

> You can create more sub-volumes if you want.

`cd`

`umount /mnt`

> I unmounted the /mnt partition, because now i need to remount the 2 volumes i just created.

The `noatime` option makes your system perform better by reducing read and write access times on the system:

`mount -o noatime,compress=zstd,space_cache=v2,discard=async,ssd,subvol=@ /dev/mapper/encrypted /mnt`

**Home partition**

Now we need to do the same for the `@home` sub-volume

First we need to create a directory for it:

`mkdir /mnt/home`

`mount -o noatime,compress=zstd,space_cache=v2,discard=async,ssd,subvol=@home /dev/mapper/encrypted /mnt/home`

**EFI partition**

`mkdir /mnt/boot`

`mount /dev/sda1 /mnt/boot`

![image-20221123082615469](/home/arksec/.config/Typora/typora-user-images/image-20221123082615469.png)

### Installation

> intel-ucode for intel CPUs, amd-ucode for AMD CPUs

`pacstrap /mnt base linux linux-firmware git vim intel-ucode`

### Create File System Table

`genfstab -U /mnt >> /mnt/etc/fstab`

`arch-chroot /mnt`

`vim /etc/mkinitcpio.conf`

**Change the following:**

MODULES=(**btrfs**)

HOOKS=(base udev autodetect modconf block **encrypt** filesystems keyboard fsck)

Save & Exit

`mkinitcpio -p linux`

### Install Arch

`ln -sf /usr/share/zoneinfo/Europe/Tallinn /etc/localtime
hwclock --systohc
sed -i '178s/.//' /etc/locale.gen
locale-gen
echo "LANG=en_UK.UTF-8" >> /etc/locale.conf
echo "KEYMAP=en_US" >> /etc/vconsole.conf
echo "arch" >> /etc/hostname
echo "127.0.0.1 localhost" >> /etc/hosts
echo "::1       localhost" >> /etc/hosts
echo "127.0.1.1 arch.localdomain arch" >> /etc/hosts
echo root:password | chpasswd`

`pacman -S efibootmgr networkmanager network-manager-applet dialog wpa_supplicant mtools dosfstools  base-devel linux-headers avahi xdg-user-dirs xdg-utils gvfs gvfs-smb  nfs-utils inetutils dnsutils bluez bluez-utils cups hplip alsa-utils  pipewire pipewire-alsa pipewire-pulse pipewire-jack bash-completion  openssh rsync acpi acpi_call tlp virt-manager qemu  qemu-arch-extra edk2-ovmf bridge-utils dnsmasq vde2 openbsd-netcat  iptables-nft ipset firewalld flatpak sof-firmware nss-mdns acpid  os-prober terminus-font`

`# pacman -S --noconfirm xf86-video-amdgpu
pacman -S --noconfirm nvidia nvidia-utils nvidia-settings`

`#grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB #change the directory to /boot/efi is you mounted the EFI partition at /boot/efi`

`#grub-mkconfig -o /boot/grub/grub.cfg`

systemctl enable NetworkManager
systemctl enable bluetooth
systemctl enable cups.service
systemctl enable sshd
systemctl enable avahi-daemon
systemctl enable tlp # You can comment this command out if you didn't install tlp, see above
systemctl enable reflector.timer
systemctl enable fstrim.timer
systemctl enable libvirtd
systemctl enable firewalld
systemctl enable acpidsystemctl enable NetworkManager
systemctl enable bluetooth
systemctl enable cups.service
systemctl enable sshd
systemctl enable avahi-daemon
systemctl enable tlp # You can comment this command out if you didn't install tlp, see above
systemctl enable reflector.timer
systemctl enable fstrim.timer
systemctl enable libvirtd
systemctl enable firewalld
systemctl enable acpid

`useradd -m arksec
echo arksec:password | chpasswd
usermod -aG libvirt arksec`

`echo "arksec ALL=(ALL) ALL" >> /etc/sudoers.d/arksec`

`printf "\e[1;32mDone! Type exit, umount -a and reboot.\e[0m"`



#`git clone https://github.com/Ark-Sec/archie.git`

#`cd archie`

#`ls -l`

#`chmod +x base-uefi.sh`

#`cd /`

#`./archie/base-uefi.sh`

### Install Bootloader

`bootctl --path=/boot install`

`vim /boot/loader/loader.conf`

**Change the following:**

timeout 5

default arch

#console-mode keep

### Create Bootloader Entry

`blkid /dev/sda2`

`blkid /dev/mapper/encrypted`

`blkid /dev/sda2 >> /boot/loader/entries/arch.conf`

`blkid /dev/mapper/encrypted >> /boot/loader/enries/arch.conf`

**Now we will add the following:**

`vim /boot/loader/entries/arch.conf`

title Arch Linux

linux /vmlinuz-linux

initrd /initramfs-linux-fallback.img

**Now we clean up the appended information, we only need the UUIDs from /dev/sda2 and /dev/mapper/encrypted**

options cryptdevice=UUID=<sda2 UUID>:encrypted encrypted=UUID-<mapper UUID> rootflags=subvol=@ rw

### Fallback command

`cp /boot/loader/entries/arch.conf /boot/loader/entries/arch-fallback.conf`

### Reboot

umount -R /mnt

`reboot`

Arch Linux (arch.conf)

To enable EFI for a virtual machine using the graphical interface, open the settings of the virtual machine, choose *System* item from the panel on the left and *Motherboard* tab from the right panel, and check the checkbox *Enable EFI (special OSes only)*.
