#!/bin/bash

set -exuo pipefail

SD_CARD=/dev/mmcblk0

while [ ! -e ${SD_CARD} ]; do
    echo "waiting for sd card"
    sleep 5
done
echo "sd card found"

# check if sd card is present
ls ${SD_CARD}

# nuke sd card partition table
dd if=/dev/zero of=${SD_CARD} bs=512 count=100

# reload partition table
partprobe ${SD_CARD}

# make a partition table
fdisk /dev/mmcblk0 <<EOF
o
w
EOF

# make a 50M boot partition of type W95 FAT32 (LBA)
fdisk /dev/mmcblk0 <<EOF
n
p
1

+100M
t
c
w
EOF

sleep 5

# make a root partition of type linux
fdisk /dev/mmcblk0 <<EOF
n
p
2


t
2
83
w
EOF

echo "formatting"

# format partitions
mkfs.fat -F 32 -n BOOT /dev/mmcblk0p1
mkfs.ext4 -F -L rootfs -O ^64bit,^huge_file,^metadata_csum /dev/mmcblk0p2

# mount new partitions
mkdir /tmp/boot
mkdir /tmp/root
mount /dev/mmcblk0p1 /tmp/boot
mount /dev/mmcblk0p2 /tmp/root

echo "untaring"

# untar
tar -C /tmp/boot -xJf /boot.tar.xz
rsync -ah --info=progress2 /copyme/ /tmp/root/

echo "patching"

# patch partition UUID in fstab and boot args
BOOT_UUID=$(blkid /dev/mmcblk0 -s PTUUID -o value)
sed -i "s/56cd6262/${BOOT_UUID}/g" /tmp/root/etc/fstab
sed -i "s/56cd6262/${BOOT_UUID}/g" /tmp/boot/cmdline.txt
touch /tmp/boot/ssh

# patch hostname with mac address
MAC_ADDRESS=$(sed -e "s/://g" /sys/class/net/eth0/address)
CUSTOM_HOSTNAME=$(grep -m 1 ${MAC_ADDRESS} /payload/hosts.cfg | awk '{print $2}')
[ -z "$CUSTOM_HOSTNAME" ] && CUSTOM_HOSTNAME=${MAC_ADDRESS}
sed -i "s/raspberrypi/${MAC_ADDRESS}/g" /tmp/root/etc/hostname
sed -i "s/raspberrypi/${MAC_ADDRESS}/g" /tmp/root/etc/hosts

sync

echo "rebooting"

sleep 5

reboot
