#!/bin/bash

rm -rf build
mkdir build
cd build

BUILDROOT_FILE=buildroot-2016.02

echo  "Downloading Buildroot"
wget https://buildroot.org/downloads/$BUILDROOT_FILE.tar.gz
echo "Extracting Buildroot"
tar xfz $BUILDROOT_FILE.tar.gz
rm $BUILDROOT_FILE.tar.gz

echo "Copying additional files"
cp ../patches/buildroot/post-build.sh ./$BUILDROOT_FILE/
cp -r ../patches/buildroot/rootfs-additions ./$BUILDROOT_FILE/
cp ../patches/buildroot/.config ./$BUILDROOT_FILE/
#cp ../patches/buildroot/.linux_config ./$BUILDROOT_FILE/

cd $BUILDROOT_FILE
echo "Building image"
make

cp build/$BUILDROOT_FILE/output/images/sdcard.img ./

