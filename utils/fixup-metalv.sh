#!/bin/sh 
# Note: This script requires access to NI internal systems to function correctly
# and is not intended to be run by end users. If you need to rebuild a
# LINX lvrt image, make any modifications you need directly to the
# recipes or images in meta-labview/ and use 'bitbake core-image-minimal-chroot'
# to rebuild using Yocto/poky.

#
# Usage: utils/fixup-metalv.sh <LV-Build-Dir> [package-to-fixup]
#
# NOTE: The script is normally run by utils/mk-recipes-from-rtimage.pl
# when you give it a <LV-Build-Dir> second argument (which is passed to this
# script as its sole argument).
#
# This script patches a Yocto meta-labview folder to update
# webservice-related library binaries (libws_runtine, mod_niws, etc.)
# with versions from 14.5 which have been patched to stub out niauth usage.
#
# If you uncomment the 'UPDATELV=y' line below, it can also update
# the liblvrt.so binary with a locally built version.
#
# If you run this script directly, run it from the meta-labview folder
# (after first running utils/mk-recipes-from-rtimage.pl), to overwrite
# specific files from an RT Images-based release.
#

# Update as needed:
#UPDATELV=y
#LVVERS=19
#NEWMINORVERS=0.1

UPDATELV=
LVVERS=21
NEWMINORVERS=0.0

LVVERSMIN=.0
OLDMINORVERS=0.0

OLDLVALARMVERS=12.0.0
LVALARMMAJVERS=12
LVALARMVERS=12.5.0
LVALARMEXPORTPATH=12.5/12.5.0f0
LVALARMP4PATH=//labviewrt/Core/rt_exec/export/12.5/12.5.0f0/targets/linuxU/armv7-a/gcc-4.7-oe/release/liblvalarms.so.$LVALARMVERS


if [ $# != 1 -a $# != 2 ]; then
	echo "Usage: $0 <lv-build-dir> [package-name]"
	echo "If [package-name] is specified, only files installed by that package will be updated."
	exit 1
fi

METALV="$PWD"
LVBUILD="$1"
shift
PKG=
if [ $# = 1 ]; then
 PKG="$1"
 shift
fi

if [ "$PKG" != "" -a "$PKG" != "labview" ]; then
	UPDATELV=
fi

if [ ! -f "$METALV/conf/layer.conf" -o ! -d "$METALV/../meta-labview" ]; then
	echo "$0 should be run from the bitbake meta-labview directory."
	exit 1
fi

cd "$LVBUILD"
unset PERL5LIB
. setupEnv.sh

P4="p4 -p penguin.natinst.com:1666 -c  $nibuild_penguin_clientspec"

USRLOCALDIR=armv7-a/usr/local
NIDIR=$USRLOCALDIR/natinst
LVDIR=$NIDIR/labview

LVPKG=recipes-devtools/labview/labview_$LVVERS.$NEWMINORVERS
APPWEBPKG=recipes-devtools/lv-appweb-support/lv-appweb-support_$LVVERS.0.0


MODNIWSP4PATH=//user/ksharp/web/webservices/ws_core/export/14.5/14.5.0f5/targets/linuxU/armv7-a/gcc-4.4-arm/release/mod_niws.so.14.5.0
LIBWSRTP4PATH=//user/ksharp/web/webservices/ws_core/export/14.5/14.5.0f5/targets/linuxU/armv7-a/gcc-4.4-arm/release/libws_runtime.so.14.5.0
WSCONTP4PATH=//user/ksharp/web/webservices/ws_core/export/14.5/14.5.0f5/targets/linuxU/armv7-a/gcc-4.4-arm/release/NIWebServiceContainer
NIWSVERS=14.5.0
WEBSRVDIR=$NIDIR/share/NIWebServer
LIBMODNIWS=$WEBSRVDIR/mod_niws.so

MODNIAUTHP4PATH=//user/ksharp/niauth/export/14.0/14.0.0f2/targets/linuxU/armv7-a/gcc-4.4-arm/release/mod_niauth.so.14.0.0
MODNIAUTHFILE=mod_niauth.so
MODNIAUTHVERS=14.0.0
LIBMODNIAUTH=$WEBSRVDIR/$MODNIAUTHFILE

RTPIP4PATH=//nilinux/librtpi/export/0.0/0.0.0d4/targets/linuxU/armv7-a/gcc-4.9-oe/release/librtpi.so.0.0.0

if [ -n "$UPDATELV" ]; then
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
fi

PENGDEPS=$($P4 where //labviewrt/dev | awk '{print $3;}')
(cd $PENGDEP
 test -z "$PKG" -o "$PKG" = "labview" && p4sync penguin:$LVALARMP4PATH
 test -z "$PKG" -o "$PKG" = "labview" && p4sync penguin:$RTPIP4PATH
 test -z "$PKG" -o "$PKG" = "lv-appweb-support" && p4sync penguin:$MODNIWSP4PATH
 test -z "$PKG" -o "$PKG" = "lv-appweb-support" && p4sync penguin:$LIBWSRTP4PATH
 test -z "$PKG" -o "$PKG" = "lv-appweb-support" && p4sync penguin:$WSCONTP4PATH
 test -z "$PKG" -o "$PKG" = "lv-appweb-support" && p4sync penguin:$MODNIAUTHP4PATH
)

if [ -n "$UPDATELV" ]; then
 LVALRMLIB=$($P4 where $LVALARMP4PATH | awk '{print $3;}')
 cp -fv "$LVALRMLIB" $METALV/$LVPKG/$LVDIR/
 rm -f  $METALV/$LVPKG/$LVDIR/liblvalarms.so.$OLDLVALARMVERS
 ln -sfv liblvalarms.so.$LVALARMVERS  $METALV/$LVPKG/$LVDIR/liblvalarms.so.$LVALARMMAJVERS
fi

if [ -z "$PKG" -o "$PKG" = "lv-appweb-support" ]; then
 MODNIWSLIB=$($P4 where $MODNIWSP4PATH | awk '{print $3;}')
 rm -fv $METALV/$APPWEBPKG/$LIBMODNIWS.*
 cp -fv $MODNIWSLIB $METALV/$APPWEBPKG/$LIBMODNIWS.$NIWSVERS
 chmod 755 $METALV/$APPWEBPKG/$LIBMODNIWS.$NIWSVERS
 ln -sfv mod_niws.so.$NIWSVERS $METALV/$APPWEBPKG/$LIBMODNIWS

 WSRTLIB=$($P4 where $LIBWSRTP4PATH | awk '{print $3;}')
 rm -fv $METALV/$APPWEBPKG/$WEBSRVDIR/libws_runtime.so.*
 rm -fv $METALV/$APPWEBPKG/$NIDIR/lib/libws_runtime.so*
 rm -fv $METALV/$APPWEBPKG/$NIDIR/lib/ws_runtime.so*
 cp -fv $WSRTLIB $METALV/$APPWEBPKG/$WEBSRVDIR/libws_runtime.so.$NIWSVERS
 chmod 755 $METALV/$APPWEBPKG/$WEBSRVDIR/libws_runtime.so.$NIWSVERS
 ln -sfv libws_runtime.so.$NIWSVERS $METALV/$APPWEBPKG/$WEBSRVDIR/libws_runtime.so.13
 ln -sfv libws_runtime.so.$NIWSVERS $METALV/$APPWEBPKG/$WEBSRVDIR/libws_runtime.so

 WSCONT=$($P4 where $WSCONTP4PATH | awk '{print $3;}')
 cp -fv $WSRTLIB $METALV/$APPWEBPKG/$WEBSRVDIR/NIWebServiceContainer
 chmod 755 $METALV/$APPWEBPKG/$WEBSRVDIR/NIWebServiceContainer

 MODNIAUTHLIB=$($P4 where $MODNIAUTHP4PATH | awk '{print $3;}')
 rm -fv $METALV/$APPWEBPKG/$LIBMODNIAUTH.*
 cp -fv $MODNIAUTHLIB $METALV/$APPWEBPKG/$LIBMODNIAUTH.$MODNIAUTHVERS
 chmod 755 $METALV/$APPWEBPKG/$LIBMODNIAUTH.$MODNIAUTHVERS
 ln -sfv $MODNIAUTHFILE.$MODNIAUTHVERS $METALV/$APPWEBPKG/$LIBMODNIAUTH
fi

if [ -n "$UPDATELV" -a "$LVVERS" = "19" ]; then
 RTPILIB=$($P4 where $RTPIP4PATH | awk '{print $3;}')
 mkdir -p $METALV/$LVPKG/armv7-a/usr/lib
 cp -fv $RTPILIB $METALV/$LVPKG/armv7-a/usr/lib
 ln -sfv librtpi.so.0.0.0 $METALV/$LVPKG/armv7-a/usr/lib/librtpi.so.0
fi

echo ""
echo "Updated LabVIEW $LVVERS.$NEWMINORVERS $PKG image."
