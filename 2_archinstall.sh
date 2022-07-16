#!/bin/sh
# Setup the encryption of the system
mkfs.vfat -F32 /dev/nvme0n1p1
cryptsetup -c aes-xts-plain64 -y --use-random luksFormat /dev/nvme0n1p2
cryptsetup luksOpen /dev/nvme0n1p2 luks

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
pacstrap /mnt base base-devel dosfstools gptfdisk lvm2 linux linux-firmware dhcpcd vim git terminus-font

# 'install' fstab
genfstab -Lp /mnt > /mnt/etc/fstab

# Enter the new system
arch-chroot /mnt /bin/bash
