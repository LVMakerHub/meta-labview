DESCRIPTION = "Provides an I/O abstraction layer for use with LabVIEW"
HOMEPAGE = "http://www.labviewmakerhub.com"
LICENSE = "BSD-2-Clause"
SECTION = "libs"
DEPENDS = ""
LIC_FILES_CHKSUM = "file://../../../../../../../EULA.txt;md5=a3d0f18bd127854c6251ea868053e9a2"

SRC_URI = "git://github.com/MakerHub/LINX.git;branch=${PV}"
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

