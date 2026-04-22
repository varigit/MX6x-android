# from BoardConfig.mk
TARGET_BOOTLOADER_POSTFIX := bin
UBOOT_POST_PROCESS := true

TARGET_BOOTLOADER_CONFIG := imx95-var-dart:imx95_var_dart_android_defconfig
TARGET_BOOTLOADER_CONFIG += imx95-var-dart-dual:imx95_var_dart_android_dual_defconfig

ifeq ($(PRODUCT_IMX_TRUSTY),true)
	TARGET_BOOTLOADER_CONFIG += imx95-var-dart-trusty-dual:imx95_var_dart_android_trusty_dual_defconfig
	TARGET_BOOTLOADER_CONFIG += imx95-var-dart-trusty-secure-unlock-dual:imx95_var_dart_android_trusty_secure_unlock_dual_defconfig
endif

ifeq ($(PRODUCT_IMX_RPMSG),true)
TARGET_BOOTLOADER_CONFIG += imx95-var-dart-rpmsg-dual:imx95_var_dart_android_rpmsg_defconfig
endif

TARGET_BOOTLOADER_CONFIG += imx95-var-dart-uuu:imx95_var_dart_android_uuu_defconfig

TARGET_KERNEL_DEFCONFIG := gki_defconfig
ifeq ($(LOADABLE_KERNEL_MODULE),true)
TARGET_KERNEL_GKI_DEFCONF:= imx95_gki.fragment
else
TARGET_KERNEL_GKI_DEFCONF:= imx8_var_android_defconfig
endif

# absolute path is used, not the same as relative path used in AOSP make
TARGET_DEVICE_DIR := $(patsubst %/, %, $(dir $(realpath $(lastword $(MAKEFILE_LIST)))))

# define bootloader rollback index
BOOTLOADER_RBINDEX ?= 0

