SUMMARY = "Packages for feed used by LabVIEW chroot"
LICENSE = "MIT"

inherit packagegroup

RDEPENDS_${PN} = "\
	packagegroup-core-buildessential \
	packagegroup-qwavesys-bbb \
	packagegroup-qwavesys-rpi \
	dropbear \
	git \
	gdb \
	liblinxdevice \
	libcec \
	libssh \
	libssh2 \
	lirc \
	labview \
	lv-appweb-support \
	lv-web-support \
	opencv \
	openssh \
	portaudio-v19 \
	portaudio-examples \
	strace \
"
