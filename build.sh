#!/bin/bash

rm -rf build
mkdir build
cd build

BUILDROOT_FILE=buildroot-2015.11.1

echo  "Downloading Buildroot"
wget https://buildroot.org/downloads/$BUILDROOT_FILE.tar.gz
echo "Extracting Buildroot"
tar xfz $BUILDROOT_FILE.tar.gz
rm $BUILDROOT_FILE.tar.gz

echo "Copying additional files"
cp ../patches/buildroot/post-build.sh ./$BUILDROOT_FILE/
cp -r ../patches/buildroot/rootfs-additions ./$BUILDROOT_FILE/
cp ../patches/buildroot/.config ./$BUILDROOT_FILE/
cp ../patches/buildroot/.linux_config ./$BUILDROOT_FILE/

cd $BUILDROOT_FILE
echo "Building image"
make

BR_OUT="$(pwd)/output"
export TOOLCHAIN_DIR=$BR_OUT/host/usr/

cd ../../
echo "Building patched hostapd for rtl8188/rtl8192"
unzip extras/RTL8188C_8192C_USB_linux_v4.0.2_9000.20130911.zip -d build/
cd build/RTL8188C_8192C_USB_linux_v4.0.2_9000.20130911/wpa_supplicant_hostapd
tar xfz wpa_supplicant_hostapd-0.8_rtw_r7475.20130812.tar.gz
cd wpa_supplicant_hostapd-0.8_rtw_r7475.20130812/hostapd
make CC=$TOOLCHAIN_DIR/bin/arm-linux-cc
cp hostapd ../../../../
cd ../../../../
rm -rf RTL8188C_8192C_USB_linux_v4.0.2_9000.20130911

echo "Building game engine"
cd ../led-matrix-games
./build.sh "rpi"
