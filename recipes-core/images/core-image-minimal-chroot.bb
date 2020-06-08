SUMMARY = "A small image intended to be used as a chroot"

PREFFERED_PROVIDER_virtual/kernel = "linux-dummy"

IMAGE_INSTALL = "packagegroup-core-boot \
		 ${CORE_IMAGE_EXTRA_INSTALL} \
		 bash \
		 labview \
		 lv-web-support \
		 lv-appweb-support \
		 liblinxdevice \
		 librtpi \
		 visa \
		"

IMAGE_LINGUAS = " "

LICENSE = "MIT"

inherit core-image

#IMAGE_ROOTFS_SIZE ?= "8192"

