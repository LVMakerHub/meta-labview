DESCRIPTION = "QwaveSys Helper Libs"
SECTION = "base"
LICENSE = "CLOSED"
#LIC_FILES_CHKSUM = "file://LICENSE;md5=07c4f6dea3845b02a18dc00c8c87699c"

DEPENDS = "opencv"
RDEPENDS_${PN} = "opencv"

S = "${WORKDIR}/git"

PV = "1.0-git${SRCPV}"
SRCREV = "${AUTOREV}"
SRC_URI = "git://github.com/QWaveSystems/QwaveSys-Raspberry-Pi-Package.git;protocol=https;branch=master"

#CFLAGS_append =" -DCONFIG_LIBNL32 -I${STAGING_INCDIR}/libnl3"
#LDFLAGS_append =" -lnl-3 -lnl-genl-3 -lm"

# Make the .so's end up in the main package instead of the dev package
FILES_${PN} += "${libdir}/libqwavesys.so ${libdir}/libcamera.so"
FILES_${PN}-dev = ""

#do_compile() {
#        ${CPP} ${CFLAGS} -shared -fPIC ${S}/QwaveSysOpenCV/libqwavesys.cpp \
#	  -o libqwavesys.so ${LDFLAGS}
#}

do_install() {
	install -m 0755 -d ${D}${libdir}
#        install -m 0755 ${S}/libqwavesys.so ${D}${libdir}

	# copy the libcamera.so since we don't have source for it
	install -m 0755 ${S}/QwaveSysOpenCV/libcamera.so ${D}${libdir}
	install -m 0755 ${S}/QwaveSysOpenCV/libqwavesys.so ${D}${libdir}
}
