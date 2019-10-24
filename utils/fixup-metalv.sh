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
unset PERL5LIB
. setupEnv.sh

P4="p4 -p penguin.natinst.com:1666 -c  $nibuild_penguin_clientspec"

NIDIR=armv7-a/usr/local/natinst
LVDIR=$NIDIR/labview

LVPKG=recipes-devtools/labview/labview_$LVVERS.0.1
APPWEBPKG=recipes-devtools/lv-appweb-support/lv-appweb-support_$LVVERS.0.0

OLDLVALARMVERS=12.0.0
LVALARMMAJVERS=12
LVALARMVERS=12.5.0
LVALARMP4PATH=//labviewrt/Core/rt_exec/export/12.5/12.5.0f0/targets/linuxU/armv7-a/gcc-4.7-oe/release/liblvalarms.so.$LVALARMVERS

MODNIWSP4PATH=//user/ksharp/web/webservices/ws_core/export/14.5/14.5.0f4/targets/linuxU/armv7-a/gcc-4.4-arm/release/mod_niws.so.14.5.0
MODNIWSFILE=mod_niws.so
MODNIWSVERS=14.5.0
LIBMODNIWS=$NIDIR/share/NIWebServer/$MODNIWSFILE

MODNIAUTHP4PATH=//user/ksharp/niauth/export/14.0/14.0.0f2/targets/linuxU/armv7-a/gcc-4.4-arm/release/mod_niauth.so.14.0.0
MODNIAUTHFILE=mod_niauth.so
MODNIAUTHVERS=14.0.0
LIBMODNIAUTH=$NIDIR/share/NIWebServer/$MODNIAUTHFILE

cp -fv dist64/resource/rtapp.rsc $METALV/$LVPKG/$LVDIR/english/
cp -fv distarm/resource/tdtable.tdr $METALV/$LVPKG/$LVDIR/
cp -fv distarm/AppLibs/lvrt $METALV/$LVPKG/$LVDIR/
cp -fv distarm/AppLibs/liblvrt.so.$LVVERS.$NEWMINORVERS $METALV/$LVPKG/$LVDIR/
rm -f $METALV/$LVPKG/$LVDIR/liblvrt.so.$LVVERS.$OLDMINORVERS
ln -sfv liblvrt.so.$LVVERS.$NEWMINORVERS $METALV/$LVPKG/$LVDIR/liblvrt.so.$LVVERS$LVVERSMIN
ln -sfv liblvrt.so.$LVVERS.$NEWMINORVERS $METALV/$LVPKG/$LVDIR/liblvrt.so.$LVVERS
ln -sfv liblvrt.so.$LVVERS $METALV/$LVPKG/$LVDIR/liblvrt.so
rm -f $METALV/$LVPKG/$LVDIR/libNILVRuntimeManager.so.$LVVERS.$OLDMINORVERS
rm -f $METALV/$LVPKG/$LVDIR/libNILVRuntimeManager.so.$LVVERS$LVVERSMIN
cp -fv distarm/AppLibs/libNILVRuntimeManager.so.$LVVERS.$NEWMINORVERS $METALV/$LVPKG/$LVDIR/
ln -sfv libNILVRuntimeManager.so.$LVVERS.$NEWMINORVERS  $METALV/$LVPKG/$LVDIR/libNILVRuntimeManager.so.$LVVERS
ln -sfv libNILVRuntimeManager.so.$LVVERS.$NEWMINORVERS  $METALV/$LVPKG/$LVDIR/libNILVRuntimeManager.so.$LVVERS$LVVERSMIN
ln -sfv libNILVRuntimeManager.so.$LVVERS  $METALV/$LVPKG/$LVDIR/libNILVRuntimeManager.so

PENGDEPS=$($P4 where //labviewrt/dev | awk '{print $3;}')
(cd $PENGDEP
 p4sync penguin:$LVALARMP4PATH
 p4sync penguin:$MODNIWSP4PATH
 p4sync penguin:$MODNIAUTHP4PATH
)

LVALRMLIB=$($P4 where $LVALARMP4PATH | awk '{print $3;}')
cp -fv "$LVALRMLIB" $METALV/$LVPKG/$LVDIR/
rm -f  $METALV/$LVPKG/$LVDIR/liblvalarms.so.$OLDLVALARMVERS
ln -sfv liblvalarms.so.$LVALARMVERS  $METALV/$LVPKG/$LVDIR/liblvalarms.so.$LVALARMMAJVERS

MODNIWSLIB=$($P4 where $MODNIWSP4PATH | awk '{print $3;}')
cp -fv $MODNIWSLIB $METALV/$APPWEBPKG/$LIBMODNIWS.$MODNIWSVERS
chmod 755 $METALV/$APPWEBPKG/$LIBMODNIWS.$MODNIWSVERS
ln -sfv $MODNIWSFILE.$MODNIWSVERS $METALV/$APPWEBPKG/$LIBMODNIWS

MODNIAUTHLIB=$($P4 where $MODNIAUTHP4PATH | awk '{print $3;}')
cp -fv $MODNIAUTHLIB $METALV/$APPWEBPKG/$LIBMODNIAUTH.$MODNIAUTHVERS
chmod 755 $METALV/$APPWEBPKG/$LIBMODNIAUTH.$MODNIAUTHVERS
ln -sfv $MODNIAUTHFILE.$MODNIAUTHVERS $METALV/$APPWEBPKG/$LIBMODNIAUTH

echo ""
echo "Updated LabVIEW $LVVERS.0.1 image."
