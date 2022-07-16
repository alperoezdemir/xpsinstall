#bootloader
cp ./loader.conf /boot/loader/loader.conf
cp ./arch.conf /boot/loader/entries/arch.conf

mkinitcpio -p linux

umount -R /mnt
swapoff -a
reboot
