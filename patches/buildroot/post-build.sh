#!/bin/sh
TARGETDIR=$1

#Copy the rootfs additions
cp -a rootfs-additions/* $TARGETDIR/

sed -i 's/INTERFACES=""/INTERFACES="wlan0"/g' $TARGETDIR/etc/init.d/S80dhcp-server

echo '/dev/mmcblk0p1 /boot vfat defaults 0 0' >> $TARGETDIR/etc/fstab