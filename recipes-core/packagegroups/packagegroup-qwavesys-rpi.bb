SUMMARY = "Packages required for use of QWaveSys VIs"
LICENSE = "MIT"

inherit packagegroup

RDEPENDS_${PN} = "\
	libqwavesys \
	opencv \
	python \
	rpi-gpio \
	rpio \
	userland \
	wiringpi \
	wiringpi-dev \
"
