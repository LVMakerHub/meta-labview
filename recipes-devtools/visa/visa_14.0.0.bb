SUMMARY = "NI-VISA driver"
HOMEPAGE = "http://ni.com/visa"
LICENSE = "CLOSED"

LIC_FILES_CHKSUM = ""

FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}_${PV}:"

S = "${WORKDIR}"

# Automatically choose directory based on target architecture
def get_ni_arch(d):
       TA = d.getVar('TARGET_ARCH', True)
       if TA == "arm":
               niArch = "armv7-a"
       elif TA == "x86_64":
               niArch = "x64"
       else:
               raise bb.parse.SkipPackage("Target architecture '%s' is not supported by the meta-labview layer" %TA)
       return niArch

NI_ARCH = "${@get_ni_arch(d)}"

SRC_URI = "file://*.ini \
	   file://*.err \
	   file://${NI_ARCH}/* \
	  "

SRC_URI[md5sum] = ""
SRC_URI[sha256sum] = ""

# Inhibit QA warnings and errors that can't be avoided because we're using 
# pre-built binaries
INSANE_SKIP_${PN} = "already-stripped dev-so textrel ldflags libdir"

# Inhibit warnings about files being stripped, we can't do anything about it.
INHIBIT_PACKAGE_DEBUG_SPLIT = "1"

# various path constants
LV_LANGUAGE="English"
STAGE_VISA_DIR="/usr/local/vxipnp/linux"
STAGE_LIB_DIR="${STAGE_VISA_DIR}/lib"
STAGE_PASSPORT_DIR="${STAGE_VISA_DIR}/NIvisa/Passport"
STAGE_SHARE_DIR="/usr/local/natinst/share"
STAGE_ERR_DIR="${STAGE_SHARE_DIR}/errors"

FILES_${PN} = "${STAGE_LIB_DIR}/* ${STAGE_PASSPORT_DIR}/* ${STAGE_ERR_DIR}/*"

do_install() {
	install -d ${D}${STAGE_LIB_DIR}
	install -d ${D}${STAGE_PASSPORT_DIR}
	install -d ${D}${STAGE_ERR_DIR}/English
	install -d ${D}${STAGE_ERR_DIR}/Japanese
	install -d ${D}${STAGE_ERR_DIR}/Korean
	install -d ${D}/usr/local/lib

	install -m 0755 ${S}/${NI_ARCH}/*.so ${D}${STAGE_LIB_DIR}
	ln -s ${STAGE_LIB_DIR}/libvisa.so ${D}/usr/local/lib/libvisa.so
	install -m 0755 ${S}/VISA-Eng.err ${D}${STAGE_ERR_DIR}/English/VISA.err
	install -m 0755 ${S}/VISA-Jpn.err ${D}${STAGE_ERR_DIR}/Japanese/VISA.err
	install -m 0755 ${S}/VISA-Kor.err ${D}${STAGE_ERR_DIR}/Korean/VISA.err

	# copy ini files
	install -m 0664 ${S}/visaconf.ini ${D}${STAGE_VISA_DIR}/NIvisa/visaconf.ini
	install -m 0755 ${S}/NiViAsrl.ini ${D}${STAGE_PASSPORT_DIR}/NiViAsrl.ini
	install -m 0755 ${S}/nisysapi.ini ${D}${STAGE_SHARE_DIR}/nisysapi.ini
}
