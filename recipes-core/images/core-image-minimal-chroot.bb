SUMMARY = "A small image intended to be used as a chroot"

PREFFERED_PROVIDER_virtual/kernel = "linux-dummy"

IMAGE_INSTALL = "packagegroup-core-boot \
		 ${ROOTFS_PKGMANAGE_BOOTSTRAP} \
		 ${CORE_IMAGE_EXTRA_INSTALL} \
		 bash \
		 labview \
		 lv-web-support \
		 liblinxdevice \
		 visa \
		"

IMAGE_LINGUAS = " "

LICENSE = "MIT"

inherit core-image

#IMAGE_ROOTFS_SIZE ?= "8192"

