DESCRIPTION = "Provides an I/O abstraction layer for use with LabVIEW"
HOMEPAGE = "http://www.labviewmakerhub.com"
LICENSE = "BSD-2-Clause"
SECTION = "libs"
DEPENDS = ""
LIC_FILES_CHKSUM = "file://${WORKDIR}/EULA.txt;md5=5cdc480f6b6d05b53790a682a9ed9ed9"

PV = "24.1-git${SRCPV}"

SRC_URI = "git://github.com/MakerHub/LINX.git;protocol=https;branch=main \
    https://raw.githubusercontent.com/MakerHub/LINX/20.0/EULA.txt;branch=20.0;md5sum=5cdc480f6b6d05b53790a682a9ed9ed9"

# Example of local git ref:
#SRC_URI = "git:///home/user/dev/LINX;protocol=file;branch=build_fixes \
#    https://raw.githubusercontent.com/MakerHub/LINX/20.0/EULA.txt;branch=20.0;md5sum=5cdc480f6b6d05b53790a682a9ed9ed9"

SRCREV = "${AUTOREV}"
S = "${WORKDIR}/git/LabVIEW/vi.lib/MakerHub/LINX/Firmware/Source/make/"

# Uncomment for debugging:
#TARGET_CFLAGS += "-O0 -g"
#INHIBIT_PACKAGE_STRIP = "1"

# Make the .so files end up in the main pkg rather than -dev
FILES_${PN} += "/usr/lib/*.so"
FILES_${PN}-dev = ""

do_compile(){
        oe_runmake libs allio
}

do_install_append(){
        install -d ${D}/usr/lib
        install -d ${D}/usr/bin

        install -m 0755 ${S}../core/examples/LinxDeviceLib/bin/*.so ${D}/usr/lib
        install -m 0755 ${S}../core/examples/Beagle_Bone_Black_Serial/bin/beagleBoneBlackSerial.out ${D}/usr/bin/linxserialserver-bb

        install -m 0755 ${S}../core/examples/Beagle_Bone_Black_Tcp/bin/beagleBoneBlackTcp.out ${D}/usr/bin/linxtcpserver-bb
        install -m 0755 ${S}../core/examples/Beagle_Bone_Black_Configurable/bin/beagleBoneBlackConfigurable.out ${D}/usr/bin/linxioserver-bb
        install -m 0755 ${S}../core/examples/RaspberryPi_2_B_Serial/bin/raspberryPi2BSerial.out ${D}/usr/bin/linxserialserver-rpi2
        install -m 0755 ${S}../core/examples/RaspberryPi_2_B_Tcp/bin/raspberryPi2BTcp.out ${D}/usr/bin/linxtcpserver-rpi2
        install -m 0755 ${S}../core/examples/RaspberryPi_2_B_Configurable/bin/raspberryPi2BConfigurable.out ${D}/usr/bin/linxioserver-rpi2
        install -m 0755 ${S}../core/examples/RaspberryPi_5_Serial/bin/raspberryPi5Serial.out ${D}/usr/bin/linxserialserver-rpi5
        install -m 0755 ${S}../core/examples/RaspberryPi_5_Tcp/bin/raspberryPi5Tcp.out ${D}/usr/bin/linxtcpserver-rpi5
        install -m 0755 ${S}../core/examples/RaspberryPi_5_Configurable/bin/raspberryPi5Configurable.out ${D}/usr/bin/linxioserver-rpi5
}

