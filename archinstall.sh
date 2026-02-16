#!/usr/bin/env bash

# https://github.com/honze-net/dalu
# https://wiki.archlinux.org/index.php/installation_guide

set -euxo pipefail

LOGFILE="install.log"
exec &> >(tee -a "$LOGFILE")

# All variables should be exported, so that they will be availabe in the arch-chroot.
export LANG="en_US.UTF-8"
export LOCALE="en_US.UTF-8"
export TIMEZONE="Asia/Taipei"
export COUNTRY="Taiwan"
export HOSTNAME="arch"
export USERNAME="willyhu"
export PASSWORD=$USERNAME
export DISK="/dev/nvme0n1"

# Wipe entire disk.
wipefs -a "$DISK"

# Create EFI System Partition: 1GiB.
parted --script "$DISK" mklabel gpt
parted --script "$DISK" mkpart ESP fat32 1MiB 1025MiB
parted --script "$DISK" set 1 esp on

# Create Linux root partition: rest of disk.
parted --script "$DISK" mkpart primary ext4 1025MiB 100%

# Format partitions.
mkfs.fat -F32 "${DISK}p1"
mkfs.ext4 -F "${DISK}p2"

# Mount partitions.
mount "${DISK}p2" /mnt
mount --mkdir "${DISK}p1" /mnt/boot

# Find and set fastest mirrors, this mirror list will be automatically copied into the installed system.
reflector --country $COUNTRY --protocol https --age 24 --sort delay --save /etc/pacman.d/mirrorlist

# Refresh package database.
pacman -Sy

# Install base files and update fstab.
pacstrap -K /mnt base linux linux-firmware
genfstab -U /mnt >>/mnt/etc/fstab

# Extend logging to persistant storage.
cp "$LOGFILE" /mnt/root/
exec &> >(tee -a "$LOGFILE" | tee -a "/mnt/root/$LOGFILE")

# This function will be executed inside the arch-chroot.
archroot() {
  # Enable error handling again, as this is technically a new execution.
  set -euxo pipefail

  # Set timezone and clock.
  ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime
  hwclock --systohc

  # Set locales.
  sed -i "/$LOCALE/s/^#//" /etc/locale.gen # Uncomment line with sed
  locale-gen
  echo "LANG=$LANG" >>/etc/locale.conf

  # Set hostname.
  echo "$HOSTNAME" >/etc/hostname

  # Install and configure sudo.
  pacman -S --noconfirm sudo
  sed -i '/^# %wheel ALL=(ALL:ALL) NOPASSWD: ALL/s/^# //' /etc/sudoers

  # Create user and add it to the wheel group.
  useradd -m -G wheel $USERNAME
  echo $USERNAME:$PASSWORD | chpasswd

  # Force user to change password at next login.
  passwd -e $USERNAME

  # Delete root password and lock root account.
  passwd -dl root

  # Set boot loader.
  pacman -S --noconfirm grub efibootmgr
  grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
  grub-mkconfig -o /boot/grub/grub.cfg

  # Install nvidia driver (optional).
  pacman -S --noconfirm nvidia-open nvidia-utils nvidia-settings nvtop switcheroo-control

  # Install the minimal GNOME desktop environment.
  pacman -S --noconfirm networkmanager gnome-control-center gdm alacritty tmux neovim git

  # Enable the experimental fractional scaling feature.
  gsettings set org.gnome.mutter experimental-features "['scale-monitor-framebuffer']"

  # enable services
  systemctl enable gdm.service
  systemctl enable NetworkManager
  systemctl enable bluetooth.service
  systemctl enable switcheroo-control.service

  echo "Finished archroot."
}

# Export the function so that it is visible by bash inside arch-chroot.
export -f archroot
arch-chroot /mnt /bin/bash -c "archroot" || echo "arch-chroot returned: $?"

# Lazy unmount.
umount -l /mnt

cat <<'EOT'
******************************************************
* Finished. You can now reboot into your new system. *
******************************************************
EOT
