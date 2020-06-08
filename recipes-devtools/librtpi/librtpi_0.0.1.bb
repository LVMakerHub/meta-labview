SUMMARY = "Real-Time Priority Inheritance C Library Wrapper"
HOMEPAGE = "https://github.com/gratian/librtpi"
SECTION = "devel/libs"
DEPENDS = ""
LICENSE = "LGPLv2.1"
LIC_FILES_CHKSUM = "file://LICENSE;md5=1803fa9c2c3ce8cb06b4861d75310742"

PV = "0.0.1+git${SRCPV}"

SRC_URI = "git://github.com/gratian/librtpi.git;branch=ni/latest"

SRCREV="${AUTOREV}"

S = "${WORKDIR}/git"

inherit autotools

FILES_${PN}-dev += "${libdir}/*.so ${includedir}/*.h"
FILES_${PN}-staticdev += "${libdir}/*.a"

LDFLAGS += "-lpthread"

