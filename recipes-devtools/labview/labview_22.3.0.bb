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

SRC_URI = "file://${NI_ARCH}/* \
           file://LICENSE \
           file://FILES \
"

SRC_URI[md5sum] = ""
SRC_URI[sha256sum] = ""

# Inhibit QA warnings and errors that can't be avoided because we're using pre-built binaries
INSANE_SKIP_${PN} = "already-stripped dev-so textrel ldflags libdir file-rdeps"

# Inhibit warnings about files being stripped, we can't do anything about it.
INHIBIT_PACKAGE_DEBUG_SPLIT = "1"

# Uncomment for debugging:
#INHIBIT_PACKAGE_STRIP = "1"

FILES_${PN} = "/usr /var /etc"

do_install() {
    install -d ${D}
    cp -R ${S}/${NI_ARCH}/* ${D}
    mkdir ${D}/var/local/natinst/log
	echo RTTarget.RTProtocolAllowed=True >> ${D}/etc/natinst/share/lvrt.conf
	echo statusLogPath=/var/local/natinst/log/LVStatus.txt >> ${D}/etc/natinst/share/lvrt.conf
}

pkg_postinst_${PN} () {
#!/bin/sh -e
grep -q /usr/local/natinst/lib $D/etc/ld.so.conf || printf "/usr/local/natinst/lib\n" >> $D/etc/ld.so.conf
if [ -z "$D" ]; then
  ldconfig
fi
}
