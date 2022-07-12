SUMMARY = "Real-Time Priority Inheritance C Library Wrapper"
HOMEPAGE = "https://github.com/gratian/librtpi"
SECTION = "devel/libs"
DEPENDS = ""
LICENSE = "LGPLv2.1"
LIC_FILES_CHKSUM = "file://${WORKDIR}/LICENSE;md5=650b869bd8ff2aed59c62bad2a22a821"

PV = "0.0.1+git${SRCPV}"

SRC_URI = "git://github.com/gratian/librtpi.git;protocol=https;branch=ni/latest;md5sum=85455101ae45d3361bd4c0936ef54d87 \
    https://github.com/gratian/librtpi.git/LICENSE;branch=ni/latest;md5sum=650b869bd8ff2aed59c62bad2a22a821"

SRCREV="${AUTOREV}"

S = "${WORKDIR}/git"

inherit autotools

FILES_${PN}-dev += "${libdir}/*.so ${includedir}/*.h"
FILES_${PN}-staticdev += "${libdir}/*.a"

LDFLAGS += "-lpthread"

