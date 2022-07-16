#!/bin/sh
# Setup system clock
ln -s /usr/share/zoneinfo/Europe/Berlin /etc/localtime
hwclock --systohc --utc

# Set the hostname
echo xps > /etc/hostname

# set up locale
mv /etc/locale.gen /etc/locale.bak
cp ./locale.gen /etc/locale.gen
locale-gen 

# vconsole 
echo KEYMAP=de-latin1 > /etc/vconsole.conf
echo FONT=ter-132n >> /etc/vconsole.conf

# Set password for root
passwd

# Add real user remove -s flag if you don't whish to use zsh
useradd -m -g users -G wheel -s /bin/zsh joe
passwd joe

vim /etc/mkinitcpio.conf