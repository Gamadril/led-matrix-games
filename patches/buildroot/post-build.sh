#!/bin/sh
TARGETDIR=$1

echo "-----"
echo $TARGETDIR
echo "-----"

export TOOLCHAIN_DIR=$TARGETDIR/../host/usr/

#Copy the rootfs additions
cp -a rootfs-additions/* $TARGETDIR/

cd ../../
echo "Building patched hostapd for rtl8188/rtl8192"
unzip extras/RTL8188C_8192C_USB_linux_v4.0.2_9000.20130911.zip -d build/
cd build/RTL8188C_8192C_USB_linux_v4.0.2_9000.20130911/wpa_supplicant_hostapd
tar xfz wpa_supplicant_hostapd-0.8_rtw_r7475.20130812.tar.gz
cd wpa_supplicant_hostapd-0.8_rtw_r7475.20130812/hostapd
make CC=$TOOLCHAIN_DIR/bin/arm-linux-cc
cp hostapd $TARGETDIR/usr/sbin/
cd ../../../../
rm -rf RTL8188C_8192C_USB_linux_v4.0.2_9000.20130911

sed -i 's/INTERFACES=""/INTERFACES="wlan0"/g' $TARGETDIR/etc/init.d/S80dhcp-server

echo '/dev/mmcblk0p1 /boot vfat defaults 0 0' >> $TARGETDIR/etc/fstab

echo "Building game engine"
cd $TARGETDIR/../../../../led-matrix-games
./build.sh "rpi"
unzip build/led-matrix-games.zip -d $TARGETDIR