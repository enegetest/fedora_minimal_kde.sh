#!/bin/bash

# Script: fedora_minimal_kde.sh
# Version: 2023.1

# dnf
echo -e "deltarpm=True
fastestmirror=True
max_parallel_downloads=10
defaultyes=True
install_weak_deps=False" | sudo tee -a /etc/dnf/dnf.conf

sudo dnf update -y

# base
sudo dnf install @base-x @Fonts @Multimedia @kde-desktop-minimal plasma-nm plasma-pa sddm sddm-x11 sddm-kcm dolphin ark gwenview elisa-player kate kcalc konsole spectacle plasma-systemmonitor kde-partitionmanager kinfocenter kdialog kscreen kwallet kwalletmanager kio-gdrive kdeplasma-addons plasma-workspace-x11 kde-gtk-config plasma-milou kffmpegthumbnailer kdegraphics-thumbnailers kde-print-manager bluedevil NetworkManager-wifi NetworkManager-bluetooth glibc-all-langpacks xdg-user-dirs xdg-user-dirs-gtk xdg-utils gvfs* systemd-boot-unsigned bash-completion -y
sudo systemctl enable sddm bluetooth NetworkManager

# repo
sudo dnf install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm -y

sudo dnf update -y

# grub to systemdboot
sudo mkdir -p /boot/efi/$(cat /etc/machine-id)
sudo rm /etc/dnf/protected.d/{grub*,shim*}
sudo dnf remove grubby grub2\* shim\* memtest86\* -y && sudo rm -rf /boot/{grub2,loader}
cat /proc/cmdline | cut -d ' ' -f2- | sudo tee /etc/kernel/cmdline
sudo bootctl install 
sudo kernel-install add $(uname -r) /lib/modules/$(uname -r)/vmlinuz
sudo dnf --releasever=$(rpm -E %fedora) reinstall kernel-core -y
sudo sed -i 's/#timeout/timeout/' /boot/efi/loader/loader.conf

# packages
sudo dnf install flatpak timeshift firefox iwlax2xx-firmware iwl7260-firmware neofetch ffmpegthumbnailer firewall-config 'dnf-command(versionlock)' -y
systemctl --user enable --now pipewire pipewire-pulse wireplumber

sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
sudo flatpak install flathub com.github.tchx84.Flatseal 

# graphical
sudo systemctl set-default graphical.target