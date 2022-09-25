#!/bin/bash

set -e

JDK_VER="11.0.16"
JDK_BUILD="8"
PACKR_VERSION="runelite-1.3"
APPIMAGE_VERSION="13"

umask 022

if ! [ -f OpenJDK11U-jre_aarch64_linux_hotspot_${JDK_VER}_${JDK_BUILD}.tar.gz ] ; then
    curl -Lo OpenJDK11U-jre_aarch64_linux_hotspot_${JDK_VER}_${JDK_BUILD}.tar.gz \
        https://github.com/adoptium/temurin11-binaries/releases/download/jdk-${JDK_VER}%2B${JDK_BUILD}/OpenJDK11U-jre_aarch64_linux_hotspot_${JDK_VER}_${JDK_BUILD}.tar.gz
fi

echo "3fa9cb99229ede53d4efddb686106df77794e02b1f4defea6b70b2b53380a8c7 OpenJDK11U-jre_aarch64_linux_hotspot_${JDK_VER}_${JDK_BUILD}.tar.gz" | sha256sum -c

# packr requires a "jdk" and pulls the jre from it - so we have to place it inside
# the jdk folder at jre/
if ! [ -d linux-aarch64-jdk ] ; then
    tar zxf OpenJDK11U-jre_aarch64_linux_hotspot_${JDK_VER}_${JDK_BUILD}.tar.gz
    mkdir linux-aarch64-jdk
    mv jdk-$JDK_VER+$JDK_BUILD-jre linux-aarch64-jdk/jre
fi

if ! [ -f packr_${PACKR_VERSION}.jar ] ; then
    curl -Lo packr_${PACKR_VERSION}.jar \
        https://github.com/runelite/packr/releases/download/${PACKR_VERSION}/packr.jar
fi

echo "f200fb7088dbb5e61e0835fe7b0d7fc1310beda192dacd764927567dcd7c4f0f  packr_${PACKR_VERSION}.jar" | sha256sum -c

# Note: Host umask may have checked out this directory with g/o permissions blank
chmod -R u=rwX,go=rX appimage
# ...ditto for the build process
chmod 644 target/Lazepa.jar

rm -rf native-linux-aarch64

java -jar packr_${PACKR_VERSION}.jar \
    packr/linux-aarch64-config.json

pushd native-linux-aarch64/Lazepa.AppDir
mkdir -p jre/lib/amd64/server/
ln -s ../../server/libjvm.so jre/lib/amd64/server/ # packr looks for libjvm at this hardcoded path

# Symlink AppRun -> RuneLite
ln -s Lazepa AppRun

# Ensure RuneLite is executable to all users
chmod 755 Lazepa
popd

if ! [ -f appimagetool-x86_64.AppImage ] ; then
    curl -Lo appimagetool-x86_64.AppImage \
        https://github.com/AppImage/AppImageKit/releases/download/$APPIMAGE_VERSION/appimagetool-x86_64.AppImage
    chmod +x appimagetool-x86_64.AppImage
fi

echo "df3baf5ca5facbecfc2f3fa6713c29ab9cefa8fd8c1eac5d283b79cab33e4acb  appimagetool-x86_64.AppImage" | sha256sum -c

if ! [ -f runtime-aarch64 ] ; then
    curl -Lo runtime-aarch64 \
	    https://github.com/AppImage/AppImageKit/releases/download/$APPIMAGE_VERSION/runtime-aarch64
fi

echo "d2624ce8cc2c64ef76ba986166ad67f07110cdbf85112ace4f91611bc634c96a  runtime-aarch64" | sha256sum -c

ARCH=arm_aarch64 ./appimagetool-x86_64.AppImage \
	--runtime-file runtime-aarch64  \
	native-linux-aarch64/Lazepa.AppDir/ \
	native-linux-aarch64/Lazepa-aarch64.AppImage
