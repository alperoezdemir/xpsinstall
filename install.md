# Having problems with the nvidia drivers
# Arch wiki page on XPS 15
# https://wiki.archlinux.org/index.php/Dell_XPS_15_9560

# Install ARCH Linux with encrypted file-system and UEFI on Dell XPS 15
# The official installation guide (https://wiki.archlinux.org/index.php/Installation_Guide) contains a more verbose description.

# Download the archiso image from https://www.archlinux.org/
# Copy to a usb-drive
dd if=archlinux.img of=/dev/sdX bs=16M && sync # on linux

# Boot from the usb. If the usb fails to boot, make sure that secure boot is disabled in the BIOS configuration.

# Set DE keymap
loadkeys de


# This assumes a wifi only system...
iwctl station wlan0 connect C-Style-5G

# Create partitions
gdisk /dev/nvme0n1 
1 512MB EFI partition # Hex code ef00
2 100% size partiton # (to be encrypted) Hex code 8300

# Format disks
mkfs.vfat -F32 /dev/nvme0n1p1

# Setup the encryption of the system
cryptsetup -c aes-xts-plain64 -y --use-random luksFormat /dev/nvme0n1p2
cryptsetup luksOpen /dev/nvme0n1p2 luks

# Create encrypted partitions
# This creates one partions for root, modify if /home or other partitions should be on separate partitions
pvcreate /dev/mapper/luks
vgcreate vg0 /dev/mapper/luks
lvcreate --size 16G vg0 --name swap
lvcreate -l +100%FREE vg0 --name root

# Create filesystems on encrypted partitions
mkfs.ext4 /dev/mapper/vg0-root
mkswap /dev/mapper/vg0-swap

# Mount the new system 
mount /dev/mapper/vg0-root /mnt 
swapon /dev/mapper/vg0-swap
mkdir /mnt/boot
mount /dev/nvme0n1p1 /mnt/boot

# Install the system also includes stuff needed for starting wifi when first booting into the newly installed system
# Unless vim and zsh are desired these can be removed from the command
pacstrap /mnt base base-devel dosfstools gptfdisk lvm2 linux linux-firmware dhcpcd vim git terminus-font

# 'install' fstab
genfstab -Lp /mnt > /mnt/etc/fstab

# Enter the new system
arch-chroot /mnt /bin/bash

# Setup system clock
ln -s /usr/share/zoneinfo/Europe/Berlin /etc/localtime
hwclock --systohc --utc

# Set the hostname
echo xps > /etc/hostname



# Update locale
#/etc/locale.gen
# de_DE.UTF-8 UTF-8
# en_DK.UTF-8 UTF-8
# en_US.UTF-8 UTF-8


# Set password for root
passwd

# Add real user remove -s flag if you don't whish to use zsh
useradd -m -g users -G wheel -s /bin/zsh joe
passwd joe

# Configure mkinitcpio with modules needed for the initrd image
vim /etc/mkinitcpio.conf
# Add 'ext4' to MODULES
# Add 'encrypt' and 'lvm2' to HOOKS before filesystems


MODULES=(ext4)
HOOKS=(base udev autodetect modconf block keyboard keymap encrypt lvm2 filesystems fsck shutdown)

# cp arch.conf /boot/loader/entries/arch.conf


# Regenerate initrd image
mkinitcpio -p linux

# Unmount all partitions
umount -R /mnt
swapoff -a

