SUMMARY = "NI-LabVIEW web support libraries"
HOMEPAGE = "http://ni.com/labview"
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

SRC_URI = "file://${NI_ARCH}/*"

SRC_URI[md5sum] = ""
SRC_URI[sha256sum] = ""

# Inhibit QA warnings and errors that can't be avoided because we're using 
# pre-built binaries
INSANE_SKIP_${PN} = "already-stripped dev-so textrel ldflags libdir"

# Inhibit warnings about files being stripped, we can't do anything about it.
INHIBIT_PACKAGE_DEBUG_SPLIT = "1"

# various path constants
STAGE_LV_DIR="/usr/local/natinst/labview"
STAGE_LIB_DIR="/usr/local/natinst/lib"
STAGE_SHARE_DIR="/usr/local/natinst/share"
STAGE_ETC_DIR="/etc/natinst"
STAGE_TRACELOG_DIR="/var/log/natinst/tracelogs"

FILES_${PN} = "${STAGE_LV_DIR}/*"

do_install() {
	install -d ${D}${STAGE_LV_DIR}
	install -d ${D}${STAGE_LIB_DIR}
	install -d ${D}${STAGE_SHARE_DIR}
	install -d ${D}${STAGE_ETC_DIR}

	# http, smtp, and webdav client libs
	install -m 0755 ${S}/${NI_ARCH}/libni_httpclient.so.14.0.0 ${D}${STAGE_LV_DIR}
	ln -s libni_httpclient.so.14.0.0 ${D}${STAGE_LV_DIR}/libni_httpclient.so
	install -m 0755 ${S}/${NI_ARCH}/libniSmtpClient.so.14.5.0 ${D}${STAGE_LV_DIR}
	ln -s libniSmtpClient.so.14.5.0 ${D}${STAGE_LV_DIR}/libniSmtpClient.so
	install -m 0755 ${S}/${NI_ARCH}/libni_webdavLVClient.so.14.0.0 ${D}${STAGE_LV_DIR}
	ln -s libni_webdavLVClient.so.14.0.0 ${D}${STAGE_LV_DIR}/libni_webdavLVClient.so

	# NI trusted CA certificates
	install -d ${D}${STAGE_ETC_DIR}/nissl
	install -m 0755 ${S}/ca-bundle.crt ${D}${STAGE_ETC_DIR}/nissl/ca-bundle.crt
	
	# NI curl lib
	install -d ${D}${STAGE_SHARE_DIR}/nicurl
	install -m 0755 ${S}/${NI_ARCH}/libcurlimpl.so.14.0.0 ${D}${STAGE_LIB_DIR}
	ln -s ${STAGE_LIB_DIR}/libcurlimpl.so.15.0.0 ${D}${STAGE_SHARE_DIR}/nicurl/libcurlimpl.so.15.0.0
	ln -s libcurlimpl.so.15.0.0 ${D}${STAGE_SHARE_DIR}/nicurl/libcurlimpl.so
	ln -s ${STAGE_ETC_DIR}/nissl/ca-bundle.crt ${D}${STAGE_SHARE_DIR}/nicurl/ca-bundle.crt

	# NI SSL lib
	install -m 0755 ${S}/${NI_ARCH}/libnisslinit.so.14.0.0 ${D}${STAGE_LIB_DIR}/libnisslinit.so.14.0.0
	ln -s ${STAGE_LIB_DIR}/libnisslinit.so.14.0.0 ${D}${STAGE_SHARE_DIR}/nissl/libnisslinit.so.14.0.0
	ln -s libnisslinit.so.14.0.0 ${D}${STAGE_SHARE_DIR}/nissl/libnisslinit.so
	install -m 0755 ${S}/${NI_ARCH}/libssleay32.so.1.0.1 ${D}${STAGE_LIB_DIR}/libssleay32.so.1.0.1
	ln -s libssleay32.so.1.0.1 ${D}${STAGE_LIB_DIR}/libssleay32.so
	ln -s ${STAGE_LIB_DIR}/libssleay32.so.1.0.1 ${D}${STAGE_SHARE_DIR}/nissl/libssleay32.so.1.0.1
	ln -s libssleay32.so.1.0.1 ${D}${STAGE_SHARE_DIR}/nissl/libssleay32.so
	install -m 0755 ${S}/${NI_ARCH}/libeay32.so.1.0.1 ${D}${STAGE_LIB_DIR}/libeay32.so.1.0.1
	ln -s libeay32.so.1.0.1 ${D}${STAGE_LIB_DIR}/libeay32.so
	ln -s ${STAGE_LIB_DIR}/libeay32.so.1.0.1 ${D}${STAGE_SHARE_DIR}/nissl/libeay32.so.1.0.1
	ln -s libeay32.so.1.0.1 ${D}${STAGE_SHARE_DIR}/nissl/libeay32.so

	# NI traceengine
	install -d ${D}${STAGE_TRACELOG_DIR}
	install -m 0755 ${S}/traceengine.ini ${D}${STAGE_TRACELOG_DIR}/traceengine.ini
	install -m 0755 ${S}/{NI_ARCH}/libni_traceengine.so.15.0.0 ${D}${STAGE_SHARE_DIR}/traceengine/libni_traceengine.so.15.0.0
	ln -s libni_traceengine.so.15.0.0 ${D}${STAGE_SHARE_DIR}/traceengine/libni_traceengine.so
}
