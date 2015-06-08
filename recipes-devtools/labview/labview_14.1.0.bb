SUMMARY = "LabVIEW embedded run-time engine"
HOMEPAGE = "http://ni.com/labview"
LICENSE = "CLOSED"

LIC_FILES_CHKSUM = ""

FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}_${PV}:"

S = "${WORKDIR}"

# Automatically choose java package based on target architecture
def get_lv_arch(d):
       TA = d.getVar('TARGET_ARCH', True)
       if TA == "arm":
               lvArch = "armv7-a"
       elif TA == "x86_64":
               lvArch = "x64"
       else:
               raise bb.parse.SkipPackage("Target architecture '%s' is not supported by the meta-labview layer" %TA)
       return lvArch

LV_ARCH = "${@get_lv_arch(d)}"

SRC_URI = "file://ni-rt.ini \
	   file://labview.dir \
	   file://rtapp.rsc \
	   file://tdtable.tdr \
	   file://Errors/* \
	   file://${LV_ARCH}/* \
	  "

SRC_URI[md5sum] = ""
SRC_URI[sha256sum] = ""

# various path constants
#PROC_DIR=armv7-a
LV_LANGUAGE=English
SRC_DIR=./
SRC_ERROR_DIR=$SRC_DIR/Errors/$LV_LANGUAGE
STAGE_LIB_DIR=/usr/local/natinst/lib
STAGE_LV_DIR=/usr/local/natinst/labview
STAGE_LV_VAR_DIR=/var/local/natinst/labview
STAGE_INITD_DIR=/etc/init.d
STAGE_NATINST_DIR=/etc/natinst
STAGE_SHARE_DIR=$STAGE_NATINST_DIR/share
STAGE_LV_INITD_DIR=/usr/local/natinst/etc/init.d

do_install() {
	mkdir -p $STAGE_LIB_DIR
	mkdir -p $STAGE_LV_DIR
	mkdir -p $STAGE_SHARE_DIR
	mkdir -p $STAGE_INITD_DIR
	mkdir -p $STAGE_LV_INITD_DIR
	mkdir -p $STAGE_LV_DIR/english

	cp -f $SRC_DIR/$PROC_DIR/lvrt $STAGE_LV_DIR
	cp -f $SRC_DIR/$PROC_DIR/liblvrt* $STAGE_LV_DIR
	ln -sf liblvrt.so.14.0.1 $STAGE_LV_DIR/liblvrt.so.14.0
	cp -f $SRC_DIR/$PROC_DIR/lvanlys.so $STAGE_LV_DIR
	cp -f $SRC_DIR/$PROC_DIR/lvblas.so $STAGE_LV_DIR
	cp -f $SRC_DIR/rtapp.rsc $STAGE_LV_DIR/english
	cp -f $SRC_DIR/labview.dir $STAGE_NATINST_DIR
	cp -f $SRC_DIR/$PROC_DIR/liblvalarms.so.7.10.0 $STAGE_LV_DIR
	ln -sf liblvalarms.so.7.10.0 $STAGE_LV_DIR/liblvalarms.so.7
	ln -sf liblvalarms.so.7 $STAGE_LV_DIR/liblvalarms.so
	cp -f $SRC_DIR/$PROC_DIR/libni_emb.so.7.10.0 $STAGE_LIB_DIR
	ln -sf libni_emb.so.7.10.0 $STAGE_LIB_DIR/libni_emb.so.6
	ln -sf libni_emb.so.6 $STAGE_LIB_DIR/libni_emb.so
	cp -f $SRC_DIR/$PROC_DIR/libni_rtlog.so.2.3.0 $STAGE_LIB_DIR
	ln -sf libni_rtlog.so.2.3.0 $STAGE_LIB_DIR/libni_rtlog.so.2
	cp -f $SRC_DIR/$PROC_DIR/libniCPULib.so.14.0.0 $STAGE_LV_DIR
	ln -sf libniCPULib.so.14.0.0 $STAGE_LV_DIR/libniCPULib.so.14
	ln -sf libniCPULib.so.14 $STAGE_LV_DIR/libniCPULib.so
	cp -f $SRC_DIR/tdtable.tdr $STAGE_LV_DIR

	# install error files
	mkdir -p $STAGE_LV_DIR/errors/English
	cp -f $SRC_ERROR_DIR/LabVIEW-errors.txt $STAGE_LV_DIR/errors/$LV_LANGUAGE/labview.err
	cp -f $SRC_ERROR_DIR/Analysis-errors.txt $STAGE_LV_DIR/errors/$LV_LANGUAGE/analysis.err
	cp -f $SRC_ERROR_DIR/Measure-errors.txt $STAGE_LV_DIR/errors/$LV_LANGUAGE/measure.err
	cp -f $SRC_ERROR_DIR/NI-Reports-errors.txt $STAGE_LV_DIR/errors/$LV_LANGUAGE/reports.err
	cp -f "$SRC_ERROR_DIR/OS and Network Services-errors.txt" $STAGE_LV_DIR/errors/$LV_LANGUAGE/Services.err

	# copy ini file
	cp -f $SRC_DIR/ni-rt.ini $STAGE_SHARE_DIR/ni-rt.ini

	# add /usr/local/natinst/lib to ld.cache
	printf "/usr/local/natinst/lib\n" >> /etc/ld.so.conf
	ldconfig
}

