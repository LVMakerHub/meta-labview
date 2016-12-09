SUMMARY = "Packages for feed used by LabVIEW chroot"
LICENSE = "MIT"

inherit packagegroup

RDEPENDS_${PN} = "\
	packagegroup-core-buildessential \
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
	opencv-samples \
	openssh \
	portaudio-v19 \
	portaudio-examples \
	strace \
"
