# Load correct keyboard layout
# To check available layouts: ls -R /usr/share/kbd/keymaps
loadkeys de-latin1

# Execute all following commands under root.
sudo su

# Find correct disk
lsblk

# In some cases, the swap is mounted from the target disk
swapoff -a

# Create GUID Partition Table
parted -s /dev/sdX mklabel gpt

# Create boot partition
# https://unix.stackexchange.com/questions/286321/why-the-1mib-should-be-used-when-setting-the-first-partition
parted -s -a optimal /dev/sdX mkpart "boot" fat32 1MiB 1GiB
parted -s /dev/sdX set 1 esp on

# Create root partition
parted -s -a optimal /dev/sdX mkpart "root" btrfs 1GiB 100%
parted -s /dev/sdX set 2 lvm on

# Create and format the LUKS partition with your custom encryption flags (type YES in CAPITAL letters!)
cryptsetup luksFormat -v --type=luks1 /dev/sdX2

# Open and mount it using the device mapper - into i.e. lvm-system
cryptsetup luksOpen /dev/sdX2 lvm-system

# Note: later you will encounter the following warnings - they happen because /run is not available inside the chroot - so you can ignore them:
#   WARNING: Failed to connect to lvmetad. Falling back to device scanning.
#   /run/lvm/lvmetad.socket: connect failed: No such file or directory
#   WARNING: failed to connect to lvmetad: No such file or directory. Falling back to internal scanning.

# Create a physical volume using the Logical Volume Manager (LVM) and the previously used id lvm-system
pvcreate /dev/mapper/lvm-system

# Create a logical volume group named lvmSystem
vgcreate lvmSystem /dev/mapper/lvm-system

# And having the logical volume group, the logical volumes can be created as follows. As an example, a 8GiB for swap (volSwap) and the rest for the root partition (volRoot):
lvcreate -L 16g lvmSystem -n volSwap  # g = Gibibyte, G = Gigabyte
lvcreate -l 100%FREE lvmSystem -n volRoot

# Format swap partition
mkswap /dev/lvmSystem/volSwap

# Format boot partition
mkfs.fat -F32 -n BOOT /dev/sdX1

# Format root partition
# https://github.com/kdave/btrfs-progs/issues/319
mkfs.btrfs -m dup -L root /dev/lvmSystem/volRoot

# Create btrfs subvolumes
mount -o noatime,ssd,space_cache=v2,compress=zstd,discard=async /dev/lvmSystem/volRoot /mnt
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@snapshots
umount /mnt

# Mount all remaining partitions
# noatime,ssd,space_cache=v2,compress=zstd,discard=async
swapon /dev/lvmSystem/volSwap
mount -o subvol=@,noatime,ssd,space_cache=v2,compress=zstd,discard=async /dev/lvmSystem/volRoot /mnt
mkdir -p /mnt/home /mnt/boot
mount -o subvol=@home,noatime,ssd,space_cache=v2,compress=zstd,discard=async /dev/lvmSystem/volRoot /mnt/home
mount -o noatime /dev/sdX1 /mnt/boot

# Install base system
basestrap /mnt base base-devel s6-base elogind-s6

# Install kernel
basestrap /mnt linux linux-firmware

# Use fstabgen to generate /etc/fstab, use -U for UUIDs and -L for partition labels:
fstabgen -U /mnt >> /mnt/etc/fstab       # <- edit and verify, also set root, swap, home and etc...
nano /mnt/etc/fstab # add params to subvol=@ and subvol=@home: noatime,ssd,space_cache=v2,compress=zstd,discard=async

# Chroot into new Artix system
artix-chroot /mnt

# Set system clock (in this case to German time zone)
# ln -sf /usr/share/zoneinfo/Region/City /etc/localtime
ln -s /usr/share/zoneinfo/Europe/Berlin /etc/localtime
hwclock --systohc

# Localization, e.g. German
echo LANG=de_DE.UTF-8 > /etc/locale.conf
echo KEYMAP=de-latin1 > /etc/vconsole.conf
pacman -S nano
nano /etc/locale.gen  # uncomment the locales you desire in /etc/locale.gen
locale-gen

# Change host name
echo hostname > /etc/hostname

# Add entries to host (optional)
nano /etc/hosts

# Set root password
passwd

# Create regular user
useradd -mG wheel username
passwd username
# For root privileges, uncomment this in /etc/sudoers
# %wheel ALL=(ALL) ALL

# Enable kernel parameters for encryption
nano /etc/mkinitcpio.conf
# Change from 
# HOOKS=(base udev autodetect modconf block keyboard keymap filesystems fsck)
# to (added encrypt, lvm2 and resume), remove fsck (for btrfs)
# HOOKS=(base udev autodetect modconf block encrypt keyboard keymap lvm2 resume filesystems)

# A random-byte file can be generated in order to serve as key to automatically decrypt the system partition during boot by GRUB
# (only needed for encrypted boot partition, therefore not used)
#dd if=/dev/random of=/crypto_keyfile.bin bs=512 count=8 iflag=fullblock
#chmod 000 /crypto_keyfile.bin
#sed -i "s/FILES=(/FILES=(\/crypto_keyfile.bin/g" /etc/mkinitcpio.conf
#cryptsetup luksAddKey /dev/sdX2 /crypto_keyfile.bin
#mkinitcpio -p linux

# GRUB - Installation
pacman -S device-mapper-s6 lvm2-s6 cryptsetup-s6
# List all active services: s6-rc -a list
# List all services/bundles in the database: s6-rc-db list all
# List all services in the database: s6-rc-db list services
# List services in a bundle: s6-rc-db contents bundlename
touch /etc/s6/sv/boot/contents.d/dmeventd
s6-db-reload
pacman -S grub
pacman -S --asdeps --needed dosfstools efibootmgr freetype2 fuse2 libisoburn mtools  # And this, for more OS options: os-prober
pacman -S intel-ucode amd-ucode

# GRUB - Configuration /etc/default/grub

# Uncomment to enable booting from LUKS encrypted devices
# GRUB_ENABLE_CRYPTODISK=y

# Optionally, the GRUB setup needs to be changed in order to prevent the (e)udev from renaming the kernel eth0, wlan0 interfaces to enp0s25, wlp4s0 etc. using the optional net.ifnames=0 parameter
# GRUB_CMDLINE_LINUX_DEFAULT="... net.ifnames=0"

# Finally, it should look similar to this:
# GRUB_CMDLINE_LINUX_DEFAULT="cryptdevice=UUID=xxx:lvm-system loglevel=3 quiet resume=UUID=yyy net.ifnames=0"
# GRUB_ENABLE_CRYPTODISK=y
# xxx is the root partition uuid, and yyy is the swap partition uuid
# You can find these values via "fdisk -l"

mkinitcpio -p linux
grub-install --target=x86_64-efi --efi-directory=/boot --recheck --removable /dev/sdX
grub-mkconfig -o /boot/grub/grub.cfg
# efibootmgr -v # check if correct
# efibootmgr -c -d /dev/sdX -p 1 -L "artix" -l "\EFI\BOOT\BOOTX64.EFI" # check if necessary
# Also see: https://askubuntu.com/questions/771455/dual-boot-ubuntu-with-windows-on-acer-aspire

# Install connman and optionally a front-end
# https://wiki.archlinux.org/title/ConnMan (you might also want to set a custom DNS)
pacman -S connman-s6 connman-gtk # (or cmst for Qt)
pacman -S  --asdeps --needed iwd wpa_supplicant bluez # WiFi and Bluetooth support
touch /etc/s6/adminsv/default/contents.d/connmand
s6-db-reload

# TODO: add dbus-s6 to default bundle + check if udev started + elogind at boot + dmesg | grep zstd

# Some s6 services you may want to install (optional)
pacman -S syslogd-s6 cronie-s6 openssh-s6 iptables-s6 fail2ban-s6 cups-s6
touch /etc/s6/adminsv/default/contents.d/syslogd
touch /etc/s6/adminsv/default/contents.d/cronie
touch /etc/s6/adminsv/default/contents.d/sshd
touch /etc/s6/adminsv/default/contents.d/iptables
touch /etc/s6/adminsv/default/contents.d/ip6tables
touch /etc/s6/adminsv/default/contents.d/fail2ban
touch /etc/s6/adminsv/default/contents.d/cupsd
s6-db-reload

# Disable beep sounds
echo "blacklist pcspkr" > /etc/modprobe.d/nobeep.conf

# Reboot
exit  # exit chroot environment
shutdown -h now # TODO: or loginctl poweroff? # or: poweroff

# Post installation configuration (after reboot)

# Install Pipewire
sudo pacman -S pipewire pipewire-alsa pipewire-pulse pipewire-jack

# If you have a GPU, install GPU drivers
# NVIDIA: pacman -S mesa xf86-video-nouveau mesa-vdpau libva-mesa-driver vulkan-mesa-layers
# AMDGPU: pacman -S mesa xf86-video-amdgpu mesa-vdpau libva-mesa-driver opencl-mesa vulkan-radeon vulkan-mesa-layers

# Install and start sway
sudo pacman -S sway
sway

# Create local sway config
mkdir -p ~/.config/sway/
cp /etc/sway/config ~/.config/sway/config

# German keyboard
# input * xkb_layout "de"

# Enable NumLock by default
# input * xkb_numlock enable >> ~/.config/sway/config

# More Sway configuration options:
# https://wiki.archlinux.org/title/Sway#Configuration

# Add Arch repositories:
# https://wiki.artixlinux.org/Main/Repositories
# pacman -S artix-archlinux-support
# pacman-key --init
# pacman-key --populate artix
# pacman-key --populate archlinux
# pacman-key --refresh-keys

# export MOZ_ENABLE_WAYLAND=1
# export XDG_CURRENT_DESKTOP=sway
# export XDG_SESSION_TYPE=wayland
# export QT_QPA_PLATFORM=wayland