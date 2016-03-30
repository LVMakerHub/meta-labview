SUMMARY = "NI-LabVIEW appweb support libraries"
HOMEPAGE = "http://ni.com/labview"
LICENSE = "CLOSED"
DESCRIPTION = "Appweb support enables usage of LabVIEW-based web services and Data Dashboard app"

LIC_FILES_CHKSUM = ""

FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}_${PV}:"

S = "${WORKDIR}"

RDEPENDS_${PN} += "libcap"

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
STAGE_SHARE_DIR="/usr/local/natinst/share/NIWebServer"
STAGE_ETC_DIR="/etc/natinst"
STAGE_TRACELOG_DIR="/var/local/natinst/tracelogs"
STAGE_WS_DIR="/var/local/natinst/webservices/NI"
STAGE_LV_WS_DIR="${STAGE_LV_DIR}/webserver/services"

FILES_${PN} = "${STAGE_LV_DIR}/* ${STAGE_LIB_DIR}/* ${STAGE_SHARE_DIR}/* ${STAGE_ETC_DIR}/* ${STAGE_TRACELOG_DIR}/* ${STAGE_WS_DIR}/* ${STAGE_LV_WS_DIR}/*"

do_install() {
	install -d ${D}${STAGE_LV_DIR}
	install -d ${D}${STAGE_LIB_DIR}
	install -d ${D}${STAGE_SHARE_DIR}
	install -d ${D}${STAGE_ETC_DIR}
	install -d ${D}${STAGE_TRACELOG_DIR}
	install -d ${D}${STAGE_WS_DIR}
	install -d ${D}${STAGE_LV_WS_DIR}

	# core appweb libraries
	install -m 0755 ${S}/${NI_ARCH}/libpcre.so.4.1.0 ${D}${STAGE_SHARE_DIR}
	ln -s libpcre.so.4.1.0 ${D}${STAGE_SHARE_DIR}/libpcre.so
	ln -s ${STAGE_SHARE_DIR}/libpcre.so.4.1.0 ${D}${STAGE_LIB_DIR}/libpcre.so.4.1.0
	install -m 0755 ${S}/${NI_ARCH}/libmpr.so.4.1.0 ${D}${STAGE_SHARE_DIR}
	ln -s libmpr.so.4.1.0 ${D}${STAGE_SHARE_DIR}/libmpr.so
	ln -s ${STAGE_SHARE_DIR}/libmpr.so.4.1.0 ${D}${STAGE_LIB_DIR}/libmpr.so.4.1.0
	install -m 0755 ${S}/${NI_ARCH}/libmprssl.so.4.1.0 ${D}${STAGE_SHARE_DIR}
	ln -s libmprssl.so.4.1.0 ${D}${STAGE_SHARE_DIR}/libmprssl.so
	ln -s ${STAGE_SHARE_DIR}/libmprssl.so.4.1.0 ${D}${STAGE_LIB_DIR}/libmprssl.so.4.1.0
	install -m 0755 ${S}/${NI_ARCH}/libhttp.so.4.1.0 ${D}${STAGE_SHARE_DIR}
	ln -s libhttp.so.4.1.0 ${D}${STAGE_SHARE_DIR}/libhttp.so
	ln -s ${STAGE_SHARE_DIR}/libhttp.so.4.1.0 ${D}${STAGE_LIB_DIR}/libhttp.so.4.1.0
	install -m 0755 ${S}/${NI_ARCH}/libappwebcore.so.4.1.0 ${D}${STAGE_SHARE_DIR}
	ln -s libappwebcore.so.4.1.0 ${D}${STAGE_SHARE_DIR}/libappwebcore.so
	ln -s ${STAGE_SHARE_DIR}/libappwebcore.so.4.1.0 ${D}${STAGE_LIB_DIR}/libappwebcore.so.4.1.0
	install -m 0755 ${S}/${NI_ARCH}/mod_niesp.so.14.0.0 ${D}${STAGE_SHARE_DIR}
	ln -s mod_niesp.so.14.0.0 ${D}${STAGE_SHARE_DIR}/mod_niesp.so
	ln -s ${STAGE_SHARE_DIR}/mod_niesp.so.14.0.0 ${D}${STAGE_LIB_DIR}/libmod_niesp.so.14.0.0
	install -m 0755 ${S}/${NI_ARCH}/mod_nisessmgr.so.14.0.0 ${D}${STAGE_SHARE_DIR}
	ln -s mod_nisessmgr.so.14.0.0 ${D}${STAGE_SHARE_DIR}/mod_nisessmgr.so
	ln -s ${STAGE_SHARE_DIR}/mod_nisessmgr.so.14.0.0 ${D}${STAGE_LIB_DIR}/libmod_nisessmgr.so.14.0.0
	install -m 0755 ${S}/${NI_ARCH}/libappweb.so.14.5.0 ${D}${STAGE_SHARE_DIR}
	ln -s libappweb.so.14.5.0 ${D}${STAGE_SHARE_DIR}/libappweb.so

	# mime.types
	install -m 0444 ${S}/mime.types ${D}${STAGE_ETC_DIR}

	# web services run-time
	install -m 0755 ${S}/${NI_ARCH}/libws_runtime.so.14.5.0 ${D}${STAGE_SHARE_DIR}
	ln -s libws_runtime.so.14.5.0 ${D}${STAGE_SHARE_DIR}/libws_runtime.so
	ln -s libws_runtime.so ${D}${STAGE_SHARE_DIR}/ws_runtime.so
	ln -s ${STAGE_SHARE_DIR}/libws_runtime.so.14.5.0 ${D}${STAGE_LIB_DIR}/libws_runtime.so
	ln -s ${STAGE_SHARE_DIR}/libws_runtime.so.14.5.0 ${D}${STAGE_LIB_DIR}/libws_runtime.so.14.5.0	
	ln -s libws_runtime.so.14.5.0 ${D}${STAGE_LIB_DIR}/ws_runtime.so
	install -m 0755 ${S}/${NI_ARCH}/mod_niws.so.14.5.0 ${D}${STAGE_SHARE_DIR}
	ln -s mod_niws.so.14.5.0 ${D}${STAGE_SHARE_DIR}/mod_niws.so
	ln -s ${STAGE_SHARE_DIR}/mod_niws.so.14.5.0 ${D}${STAGE_LIB_DIR}/libmod_niws.so.14.5.0	

	# sys admin webservice - for Data Dashboard support
	install -d ${D}${STAGE_WS_DIR}/LVWSSysAdmin
	install -m 0644 ${S}/sysadminsvc/WebService.ini ${D}${STAGE_WS_DIR}/LVWSSysAdmin
	install -m 0755 ${S}/${NI_ARCH}/libsysadminsvc.so.14.5.0 ${D}${STAGE_WS_DIR}/LVWSSysAdmin
	ln -s libsysadminsvc.so.14.5.0 ${D}${STAGE_WS_DIR}/LVWSSysAdmin/libsysadminsvc.so

	# debug webservice
	install -d ${D}${STAGE_LV_WS_DIR}/LVWSDebugSvc
	install -m 0644 ${S}/debugsvc/WebService.ini ${D}${STAGE_LV_WS_DIR}/LVWSDebugSvc
	install -m 0755 ${S}/${NI_ARCH}/libdebugsvc.so.14.0.0 ${D}${STAGE_LV_WS_DIR}/LVWSDebugSvc
	ln -s libdebugsvc.so.14.0.0 ${D}${STAGE_LV_WS_DIR}/LVWSDebugSvc/libdebugsvc.so

	# misc config files
	touch ${D}${STAGE_LV_DIR}/webserver/niwsdebugserver.conf
	install -m 0444 ${S}/niwsdebugserver.conf.template ${D}${STAGE_LV_DIR}/webserver
	install -d ${D}${STAGE_ETC_DIR}/webservices
	install -m 0644 ${S}/webservices.ini ${D}${STAGE_ETC_DIR}/webservices
	
	# www root
	install -d ${D}${STAGE_LV_DIR}/webserver/ws_www
	install -m 0440 ${S}/login.html ${D}${STAGE_LV_DIR}/webserver/ws_www

	# tracelog config files
	install -m 0644 ${S}/ws_shared.cfg ${D}${STAGE_TRACELOG_DIR}
	install -m 0644 ${S}/ws_runtime.cfg ${D}${STAGE_TRACELOG_DIR}
	install -m 0644 ${S}/mod_niws.cfg ${D}${STAGE_TRACELOG_DIR}
	install -m 0644 ${S}/ws_service_container.cfg ${D}${STAGE_TRACELOG_DIR}

	# mod_niauth, mod_niconf, mod_nissl, and mod_ssl
	install -m 0755 ${S}/${NI_ARCH}/mod_niauth.so.14.0.0 ${D}${STAGE_SHARE_DIR}
	ln -s mod_niauth.so.14.0.0 ${D}${STAGE_SHARE_DIR}/mod_niauth.so
	install -m 0755 ${S}/${NI_ARCH}/mod_niconf.so.14.0.0 ${D}${STAGE_SHARE_DIR}
	ln -s mod_niconf.so.14.0.0 ${D}${STAGE_SHARE_DIR}/mod_niconf.so
	install -m 0755 ${S}/${NI_ARCH}/mod_nissl.so.14.0.0 ${D}${STAGE_SHARE_DIR}
	ln -s mod_nissl.so.14.0.0 ${D}${STAGE_SHARE_DIR}/mod_nissl.so
	install -m 0755 ${S}/${NI_ARCH}/mod_ssl.so.4.1.0 ${D}${STAGE_SHARE_DIR}
	ln -s mod_ssl.so.4.1.0 ${D}${STAGE_SHARE_DIR}/mod_ssl.so
}
