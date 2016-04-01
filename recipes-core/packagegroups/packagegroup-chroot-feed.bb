SUMMARY = "Packages for feed used by LabVIEW chroot"
LICENSE = "MIT"

inherit packagegroup

RDEPENDS_${PN} = "\
	packagegroup-core-buildessential \
	git \
	gdb \
	liblinxdevice \
	libcec \
	labview \
	lv-appweb-support \
	lv-web-support \
	opencv \
	opencv-samples \
	strace \
"
