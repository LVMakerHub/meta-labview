#!/bin/sh 

# utils/fixup-metalv.sh
# Run this script from the meta-labview folder, after running mk-recipes-from-rtimage.pl,
# to overwrite files from an SP1 release.

# Update as needed:
LVVERS=19
LVVERSMIN=.0
OLDMINORVERS=0.0
NEWMINORVERS=0.1

OLDLVALARMVERS=12.0.0
LVALARMMAJVERS=12
LVALARMVERS=12.5.0
LVALARMEXPORTPATH=12.5/12.5.0f0

if [ $# != 1 ]; then
	echo "Usage: $0 [lv-build-dir]"
	exit 1
fi

METALV="$PWD"
LVBUILD="$1"

if [ ! -f "$METALV/conf/layer.conf" -o ! -d "$METALV/../meta-labview" ]; then
	echo "$0 should be run from the bitbake meta-labview directory."
	exit 1
fi

cd "$LVBUILD"
LVPKG=recipes-devtools/labview/labview_$LVVERS.0.1
LVDIR=armv7-a/usr/local/natinst/labview

cp -fv dist64/resource/rtapp.rsc $METALV/$LVPKG/$LVDIR/english/
cp -fv distarm/resource/tdtable.tdr $METALV/$LVPKG/$LVDIR/
cp -fv distarm/AppLibs/lvrt $METALV/$LVPKG/$LVDIR/
cp -fv distarm/AppLibs/liblvrt.so.$LVVERS.$NEWMINORVERS $METALV/$LVPKG/$LVDIR/
rm -f $METALV/$LVPKG/$LVDIR/liblvrt.so.$LVVERS.$OLDMINORVERS
ln -sfv liblvrt.so.$LVVERS.$NEWMINORVERS $METALV/$LVPKG/$LVDIR/liblvrt.so.$LVVERS$LVVERSMIN
ln -sfv liblvrt.so.$LVVERS.$NEWMINORVERS $METALV/$LVPKG/$LVDIR/liblvrt.so.$LVVERS
ln -sfv liblvrt.so.$LVVERS $METALV/$LVPKG/$LVDIR/liblvrt.so
rm -f $METALV/$LVPKG/$LVDIR/libNILVRuntimeManager.so.$LVVERS.$OLDMINORVERS
cp -fv distarm/AppLibs/libNILVRuntimeManager.so.$LVVERS.$NEWMINORVERS $METALV/$LVPKG/$LVDIR/
ln -sfv libNILVRuntimeManager.so.$LVVERS.$NEWMINORVERS  $METALV/$LVPKG/$LVDIR/libNILVRuntimeManager.so.$LVVERS
ln -sfv libNILVRuntimeManager.so.$LVVERS  $METALV/$LVPKG/$LVDIR/libNILVRuntimeManager.so

# This may need to be updated
LVALRMLIB=$(p4 -p penguin.natinst.com:1666 -c  $nibuild_penguin_clientspec where //labviewrt/Core/rt_exec/export/$LVALARMEXPORTPATH/targets/linuxU/armv7-a/gcc-4.7-oe/release/liblvalarms.so.$LVALARMVERS | awk '{print $3;}')
cp -fv "$LVALRMLIB" $METALV/$LVPKG/$LVDIR/
rm -f  $METALV/$LVPKG/$LVDIR/liblvalarms.so.$OLDLVALARMVERS
ln -sfv liblvalarms.so.$LVALARMVERS  $METALV/$LVPKG/$LVDIR/liblvalarms.so.$LVALARMMAJVERS

echo ""
echo "Updated LabVIEW $LVVERS.0.1 image."
