#!/bin/bash

if [ -z "$1" ]; then
	echo "provide the path to buildroot folder as parameter"
	exit 1
fi

echo "Generating SD card image"
cd build/
rm -f sdcard.img
rm -rf boot
rm -rf root
dd if=/dev/zero of=./sdcard.img bs=1M count=250
losetup /dev/loop0 ./sdcard.img
echo -e "o\nn\np\n1\n\n+60M\nn\np\n2\n\n\nt\n1\nb\np\nw" | fdisk /dev/loop0
losetup -o 1048576 /dev/loop1 /dev/loop0
losetup -o 63963136 /dev/loop2 /dev/loop0
mkfs.vfat /dev/loop1
mkfs.ext3 /dev/loop2
mkdir boot
mkdir root
mount /dev/loop1 ./boot
mount /dev/loop2 ./root
cp $1/output/images/*.dtb ./boot
#cp $1/output/images/zImage ./boot
cp $1/output/images/rpi-firmware/* ./boot
tar xf $1/output/images/rootfs.tar -C ./root
$1/output/host/usr/bin/mkknlimg $1/output/images/zImage ./boot/zImage

echo "Replacing hostapd with rtl-build"
mv hostapd ./root/usr/sbin/

echo "Installing game engine to root fs"
unzip ../led-matrix-games/build/led-matrix-games.zip -d ./root/
#mv ./root/led-matrix-games/led_games.ini ./boot
mv ./root/led-matrix-games/games ./boot
mv ./root/led-matrix-games/lib/* ./root/lib/
mv ./root/led-matrix-games/www/* ./root/var/www/data/
rm -r ./root/led-matrix-games/lib
rm -r ./root/led-matrix-games/www

echo "Finishing"
umount ./boot
umount ./root
rm -r boot
rm -r root
losetup -D