DESCRIPTION = "Provides an I/O abstraction layer for use with LabVIEW"
HOMEPAGE = "http://www.labviewmakerhub.com"
LICENSE = "BSD-2-Clause"
SECTION = "libs"
DEPENDS = ""
LIC_FILES_CHKSUM = "file://../../../../../../../EULA.txt;md5=5cdc480f6b6d05b53790a682a9ed9ed9"

PV = "2.1-git${SRCPV}"
SRC_URI = "git://github.com/MakerHub/LINX.git;branch=2.1"
SRCREV = "${AUTOREV}"
S = "${WORKDIR}/git/LabVIEW/vi.lib/MakerHub/LINX/Firmware/Source/make/"

# Make the .so files end up in the main pkg rather than -dev
FILES_${PN} += "/usr/lib/*.so"
FILES_${PN}-dev = ""

do_compile(){
        oe_runmake libs
}

do_install_append(){
        install -d ${D}/usr/lib
        install -m 0755 ${S}../core/examples/LinxDeviceLib/bin/*.so ${D}/usr/lib
}

