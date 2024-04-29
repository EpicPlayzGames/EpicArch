#!/bin/bash
#
# Desktop Environment Setup Script

# Have the user select a given DE to have installed after base-install
de_select() {
    clear
    echo -ne "Would you like to install a Desktop Environment? (y/n): "
    read CONFIRM

    if [[ "$CONFIRM" == "y" ]]
    then
        echo "1 - Gnome" 
        echo "2 - KDE Plasma"
        echo "3 - Cinnamon"

        echo -ne "Please Choose a DE To Install: "
        read SELECTION

        case ${SELECTION} in 
        "1") 
          echo "Beginning Gnome DE Setup..."
          arch-chroot /mnt pacman -Sy --needed xorg gnome gnome-tweaks nautilus-sendto gnome-nettool gnome-usage gnome gnome-multi-writer adwaita-icon-theme xdg-user-dirs-gtk fwupd arc-gtk-theme seahorse gdm xscreensaver archlinux-wallpaper pulseaudio pulseaudio-alsa pavucontrol firefox vlc neofetch nano ffmpeg --noconfirm
          arch-chroot /mnt systemctl enable gdm.service
          ;;
        "2") 
          echo "Beginning KDE Plasma Setup..."
          arch-chroot /mnt pacman -Sy plasma-desktop sddm pulseaudio pulseaudio-alsa pavucontrol firefox vlc akonadi-calendar-tools akonadi-import-wizard akonadiconsole akregator ark audiocd-kio colord-kde dolphin dolphin-plugins ffmpeg ffmpegthumbs kamera kate konsole kbackup kcolorchooser kcron kde-dev-scripts kde-dev-utils kdeconnect kdegraphics-thumbnailers kdenetwork-filesharing kdepim-addons kdesdk-kio kdesdk-thumbnailers kdialog kfind khelpcenter kio-admin kio-extras ksystemlog partitionmanager neofetch nano --noconfirm
          arch-chroot /mnt systemctl enable sddm.service
          ;;
        "3") 
          echo "Beginning Cinnamon Setup..."
          arch-chroot /mnt pacman -Sy cinnamon gnome-terminal xorg lightdm lightdm-gtk-greeter pulseaudio pulseaudio-alsa pavucontrol firefox vlc gedit gnome-system-monitor mate-icon-theme-faenza ffmpeg neofetch nano --noconfirm
          arch-chroot /mnt systemctl enable lightdm
          ;;
        *) 
          echo "Please choose a valid option."
          ;;
        esac
    else
        echo "Desktop Environment Installation Cancelled."
    fi
}

de_select