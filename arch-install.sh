#!/bin/bash
#
# Arch Linux Install Script by EpicPlayzGames
# https://github.com/EpicPlayzGames/EpicArch
#
echo -ne "
-----------------------------------------------
- Arch Linux Install Script by EpicPlayzGames -
-----------------------------------------------
"
# Check the Current System Disks
check_disk() {
        # Detect Boot Drive
        lsblk
        echo -ne "Select Disk to Install To: "
        read DISK 

	# Check if the Boot Drive is NVME or not
	if [[ "${DISK}" =~ "nvme" ]] 
	then
		PARTITION1=${DISK}p1
		PARTITION2=${DISK}p2
		PARTITION3=${DISK}p3
	else
		PARTITION1=${DISK}1
		PARTITION2=${DISK}2
		PARTITION3=${DISK}3
	fi
}

# Determain Swap Needs
swap() {
        # Ask for Swap Allocation
        echo -ne "Swap? (y/n): "
        read SWAP

}

# Partition System Disks
partition_disk() {
	echo "Starting Disk Partitioning..."

	# Check if Swap is not answered with a Y|y
	if [[ "${SWAP}" == "y" || "${SWAP}" == "Y" ]]
	then # Make Swap + /mnt and /mnt/boot
		wipefs -a ${DISK} 
		parted -s ${DISK} mklabel gpt
		parted -s --align=optimal ${DISK} mkpart ESP fat32 1MiB 2GiB
		parted -s --align=optimal ${DISK} mkpart linux-swap 2GiB 6GiB
		parted -s --align=optimal ${DISK} mkpart primary ext4 6GiB 100%
		parted -s ${DISK} set 1 boot on
	else # Make /mnt and /mnt/boot
		wipefs -a ${DISK}
		parted -s ${DISK} mklabel gpt
		parted -s --align=optimal ${DISK} mkpart ESP fat32 1MiB 2GiB
		parted -s --align=optimal ${DISK} mkpart primary 2GiB 100%
		parted -s ${DISK} set 1 boot on
	fi
}

create_filesystem() {
	echo "Creating Filesystem..."

	# Create the Boot Drive Filesystem
	if [[ "${SWAP}" == "y" || "${SWAP}" == "Y" ]]
	then
		mkfs.fat -F32 ${PARTITION1}
		mkswap ${PARTITION2}
		mkfs.ext4 ${PARTITION3}
	else
		mkfs.fat -F32 ${PARTITION1}
		mkfs.ext4 ${PARTITION2}
	fi 
}

mount_filesystem() {
	echo "Mounting Filesystem..."

	# Mount partitions based on whether or not swap is present
	if [[ "${SWAP}" == "y" || "${SWAP}" == "Y" ]]
	then
		mount ${PARTITION3} /mnt
		swapon ${PARTITION2}
		mount --mkdir ${PARTITION1} /mnt/boot
	else
		mount ${PARTITION2} /mnt
		mount --mkdir ${PARTITION1} /mnt/boot
	fi
}

generate_mirrors() {
	echo "Generating Mirrors..."
	echo ""
	echo -ne "Enter your Country (ex. US): "
	read COUNTRY

	echo "Generating Pacman Mirrors... Please Wait..."
	reflector --country ${COUNTRY} --age 12 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
 	echo "Reflector Finished"
}

detectcpu() {
	# Detect whether CPU is AMD or Intel
	if lscpu | grep "AuthenticAMD"
	then
		CPU=amd
	else
		CPU=intel
	fi
}

detectgpu() {
	# Detect the system GPU for Driver Install
	pacman -Sy lshw --noconfirm

	# Detect whether GPU is Nvidia or AMD
	if lshw -C display | grep "NVIDIA"
	then
		GPU=nvidia
	fi

	if lshw -C display | grep "AMD"
	then
		GPU=amd
	fi

	# Set Drivers if GPU is Nvidia
        if [[ "${GPU}" == "nvidia" ]]
        then
                GPUDRIVER=nvidia
                GPUUTILS=nvidia-utils
        fi

	# Set Drivers if GPU is AMD
        if [[ "${GPU}" == "amd" ]]
        then
                GPUDRIVER=mesa
                GPUUTILS=vulkan-radeon
        fi
}

base_install() {
	echo "Starting Installation of Base System Packages..."

	# Install Base System Packages
	pacstrap -K /mnt base base-devel linux linux-headers linux-firmware ${CPU}-ucode efibootmgr grub sudo nano git curl wget os-prober man-db man-pages texinfo

	echo "Generating FSTAB File..."
	genfstab -U /mnt >> /mnt/etc/fstab
	echo "Success!"
}

set_timezone() {
	echo "Starting Timezone Configuration..."

	echo -ne "Enter your Region (ex. America/Chicago): "
	read REGION

	ln -sf /mnt/usr/share/zoneinfo/${REGION} /mnt/etc/localtime
	arch-chroot /mnt hwclock --systohc

	echo "en_US.UTF-8 UTF-8" | tee -a /mnt/etc/locale.gen
	arch-chroot /mnt locale-gen 

	touch /mnt/etc/locale.conf
	echo "LANG=en_US.UTF-8" >> /mnt/etc/locale.conf
}

set_hostname() {
	# Ask for Prefered Hostname
	echo -ne "Enter Hostname (Computer Name): "
	read HOSTNAME

	echo ${HOSTNAME} >> /mnt/etc/hostname
}

network_configuration() {
	echo "Starting Network Configuration..."
	
	# Setting up Resolv.conf
	echo -ne "Enter Router IP (ex. 192.168.1.1): "
	read GATEWAY

	echo "nameserver ${GATEWAY}" | tee -a /mnt/etc/resolv.conf

	echo -ne "Enter System IP (ex. 192.168.1.20): "
	read SYSTEM_IP

	ip link
	echo ""
	echo -ne "Enter Network Interface (ex. enp3s0): "
	read NET_INTERFACE

	touch /mnt/etc/systemd/network/default.network
	echo "
	[Match]
	Name=${NET_INTERFACE}

	[Network]
	Address=${SYSTEM_IP}
	Gateway=${GATEWAY}
	DNS=${GATEWAY}
	DHCP=no
	" | tee -a /mnt/etc/systemd/network/default.network

        ## Not listed in the wiki, but needed to make networks work properly
        echo "127.0.0.1       localhost" | tee -a /mnt/etc/hosts
        echo "::1             localhost" | tee -a /mnt/etc/hosts
        echo "127.0.1.1       ${HOSTNAME}.localdomain      ${HOSTNAME}" | tee -a /mnt/etc/hosts
}

create_user() {
	# Set Root Password
	echo "Enter Root Password"
	arch-chroot /mnt passwd

	# Create System User
	echo "Creating System User..."
	echo ""

	echo -ne "Enter your Username: "
	read USERNAME

 	arch-chroot /mnt useradd -m ${USERNAME} --badname -s /bin/bash 
        arch-chroot /mnt usermod -aG wheel ${USERNAME}

 	echo "Enter your Password"
  	arch-chroot /mnt passwd ${USERNAME}

	echo "%wheel ALL=(ALL:ALL) ALL" | tee -a /mnt/etc/sudoers
	echo "User Successfully Created"

}

grub_setup() {
	echo "Starting Grub Bootloader Configuration..."

	# Setup Grub
	echo "Starting Grub Install..."
	arch-chroot /mnt grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB

	echo "Generating Grub Config..."
	echo "GRUB_DISABLE_OS_PROBER=false" | tee -a /mnt/etc/default/grub
	arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg
}

enable_services() {
	arch-chroot /mnt systemctl --type=service enable systemd-networkd
	arch-chroot /mnt systemctl --type=service enable systemd-resolved
}

startup() {
	detectcpu
	check_disk
	swap
	partition_disk
	create_filesystem
	mount_filesystem
	generate_mirrors
	base_install
	set_timezone
	set_hostname
	network_configuration
	create_user
	grub_setup
	enable_services
}

umount -A --recursive /mnt # In case of mounted partitions on install start
startup

umount -A --recursive /mnt
echo "Unmounted /mnt"
echo "Installation Successful! Reboot System Now."
