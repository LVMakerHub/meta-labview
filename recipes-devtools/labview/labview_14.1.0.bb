SUMMARY = "LabVIEW embedded run-time engine"
HOMEPAGE = "http://ni.com/labview"

LICENSE_FLAGS = "national-instruments"
LICENSE = "NI_Maker_Software_License_Agreement"
LIC_FILES_CHKSUM = "file://LICENSE;md5=2c6c2a1463b05f89279c9242eae7d3a8"

FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}_${PV}:"

S = "${WORKDIR}"

inherit update-rc.d

INITSCRIPT_NAME = "nilvrt"
INITSCRIPT_PARAMS = "start 98 4 5 . stop 2 0 1 2 3 6 ."

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
	   file://nilvrt \
	   file://LICENSE \
	  "

SRC_URI[md5sum] = ""
SRC_URI[sha256sum] = ""

# Inhibit QA warnings and errors that can't be avoided because we're using 
# pre-built binaries
# Added file-rdeps because libblas has a sym dep on GLIBC_2.4
INSANE_SKIP_${PN} = "already-stripped dev-so textrel ldflags libdir file-rdeps"

# Inhibit warnings about files being stripped, we can't do anything about it.
INHIBIT_PACKAGE_DEBUG_SPLIT = "1"

# various path constants
#PROC_DIR=armv7-a
LV_LANGUAGE="English"
SRC_ERROR_DIR="/Errors/${LV_LANGUAGE}"
STAGE_LIB_DIR="/usr/local/natinst/lib"
STAGE_LV_DIR="/usr/local/natinst/labview"
STAGE_LV_VAR_DIR="/var/local/natinst/labview"
STAGE_LV_LOG_DIR="/var/local/natinst/log"
STAGE_NATINST_DIR="/etc/natinst"
STAGE_SHARE_DIR="${STAGE_NATINST_DIR}/share"
STAGE_LV_INITD_DIR="/usr/local/natinst/etc/init.d"

FILES_${PN} = "${STAGE_LV_DIR}/* ${STAGE_NATINST_DIR}/* ${STAGE_LIB_DIR}/* ${STAGE_SHARE_DIR}/* ${STAGE_LV_DIR}/errors/${LV_LANGUAGE}/* ${STAGE_LV_INITD_DIR} ${sysconfdir}/init.d/nilvrt ${STAGE_LV_LOG_DIR}"

do_install() {
	install -d ${D}${STAGE_LIB_DIR}
	install -d ${D}${STAGE_LV_DIR}
	install -d ${D}${STAGE_SHARE_DIR}
	install -d ${D}${STAGE_LV_INITD_DIR}
	install -d ${D}${STAGE_LV_DIR}/english
	install -d ${D}${STAGE_LV_LOG_DIR}

	# install LV binary and essential files and libs
	install -m 0755 ${S}/${LV_ARCH}/lvrt ${D}${STAGE_LV_DIR}
	install -m 0755 ${S}/${LV_ARCH}/liblvrt* ${D}${STAGE_LV_DIR}
	ln -s liblvrt.so.14.0.1 ${D}${STAGE_LV_DIR}/liblvrt.so.14.0
	install -m 0755 ${S}/${LV_ARCH}/lvanlys.so ${D}${STAGE_LV_DIR}
	install -m 0755 ${S}/${LV_ARCH}/lvblas.so ${D}${STAGE_LV_DIR}
	install -m 0755 ${S}/rtapp.rsc ${D}${STAGE_LV_DIR}/english
	install -m 0755 ${S}/labview.dir ${D}${STAGE_NATINST_DIR}
	install -m 0755 ${S}/${LV_ARCH}/liblvalarms.so.7.10.0 ${D}${STAGE_LV_DIR}
	ln -s liblvalarms.so.7.10.0 ${D}${STAGE_LV_DIR}/liblvalarms.so.7
	ln -s liblvalarms.so.7 ${D}${STAGE_LV_DIR}/liblvalarms.so
	install -m 0755 ${S}/${LV_ARCH}/libni_emb.so.7.10.0 ${D}${STAGE_LIB_DIR}
	ln -s libni_emb.so.7.10.0 ${D}${STAGE_LIB_DIR}/libni_emb.so.6
	ln -s libni_emb.so.6 ${D}${STAGE_LIB_DIR}/libni_emb.so
	install -m 0755 ${S}/${LV_ARCH}/libni_rtlog.so.2.3.0 ${D}${STAGE_LIB_DIR}
	ln -s libni_rtlog.so.2.3.0 ${D}${STAGE_LIB_DIR}/libni_rtlog.so.2
	install -m 0755 ${S}/${LV_ARCH}/libniCPULib.so.14.0.0 ${D}${STAGE_LV_DIR}
	ln -s libniCPULib.so.14.0.0 ${D}${STAGE_LV_DIR}/libniCPULib.so.14
	ln -s libniCPULib.so.14 ${D}${STAGE_LV_DIR}/libniCPULib.so
	install -m 0755 ${S}/tdtable.tdr ${D}${STAGE_LV_DIR}

	# add some additional libs
	install -m 0755 ${S}/${LV_ARCH}/liblvpidtkt.so.14.0.0 ${D}${STAGE_LIB_DIR}
	ln -s liblvpidtkt.so.14.0.0 ${D}${STAGE_LIB_DIR}/liblvpidtkt.so.14
	ln -s liblvpidtkt.so.14 ${D}${STAGE_LIB_DIR}/liblvpidtkt.so
	install -m 0755 ${S}/${LV_ARCH}/libtdms.so.14.0.0 ${D}${STAGE_LIB_DIR}
	ln -s libtdms.so.14.0.0 ${D}${STAGE_LIB_DIR}/libtdms.so.14
	ln -s libtdms.so.14 ${D}${STAGE_LIB_DIR}/libtdms.so

	# install error files
	install -d ${D}${STAGE_LV_DIR}/errors/${LV_LANGUAGE}
	install -m 0755 ${S}${SRC_ERROR_DIR}/LabVIEW-errors.txt ${D}${STAGE_LV_DIR}/errors/${LV_LANGUAGE}/labview.err
	install -m 0755 ${S}${SRC_ERROR_DIR}/Analysis-errors.txt ${D}${STAGE_LV_DIR}/errors/${LV_LANGUAGE}/analysis.err
	install -m 0755 ${S}${SRC_ERROR_DIR}/Measure-errors.txt ${D}${STAGE_LV_DIR}/errors/${LV_LANGUAGE}/measure.err
	install -m 0755 ${S}${SRC_ERROR_DIR}/NI-Reports-errors.txt ${D}${STAGE_LV_DIR}/errors/${LV_LANGUAGE}/reports.err
	install -m 0755 ${S}${SRC_ERROR_DIR}/OS\ and\ Network\ Services-errors.txt ${D}${STAGE_LV_DIR}/errors/${LV_LANGUAGE}/Services.err

	# copy ini file
	install -m 0755 ${S}/ni-rt.ini ${D}${STAGE_SHARE_DIR}/ni-rt.ini

	# install startup script
	install -m 0755 ${S}/nilvrt ${D}${STAGE_LV_INITD_DIR}/nilvrt
	install -d ${D}${sysconfdir}/init.d
	ln -s ${STAGE_LV_INITD_DIR}/nilvrt ${D}${sysconfdir}/init.d/nilvrt
}

pkg_postinst_${PN} () {
#!/bin/sh -e
# add /usr/local/natinst/lib to ld.cache
grep -q /usr/local/natinst/lib $D/etc/ld.so.conf || printf "/usr/local/natinst/lib\n" >> $D/etc/ld.so.conf
if [ -z "$D" ]; then
  ldconfig
fi
}
