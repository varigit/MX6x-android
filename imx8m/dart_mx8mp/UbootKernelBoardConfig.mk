# from BoardConfig.mk
TARGET_BOOTLOADER_POSTFIX := bin
UBOOT_POST_PROCESS := true

TARGET_BOOTLOADER_CONFIG := \
	imx8mp-var-dart:imx8mp_var_dart_android_defconfig \
	imx8mp-var-dart-dual:imx8mp_var_dart_android_dual_defconfig

ifeq ($(PRODUCT_IMX_TRUSTY),true)
TARGET_BOOTLOADER_CONFIG += \
	imx8mp-var-dart-trusty-secure-unlock-dual:imx8mp_var_dart_android_trusty_secure_unlock_dual_defconfig \
	imx8mp-var-dart-trusty-dual:imx8mp_var_dart_android_trusty_dual_defconfig \
        imx8mp-var-dart-trusty-rbidx-blob-dual:imx8mp_var_dart_android_trusty_rbidx_blob_dual_defconfig
endif

# Bootloader target used by UUU
TARGET_BOOTLOADER_CONFIG += imx8mp-var-dart-uuu:imx8mp_var_dart_android_uuu_defconfig

ifeq ($(LOADABLE_KERNEL_MODULE),true)
TARGET_KERNEL_DEFCONFIG := gki_defconfig
TARGET_KERNEL_GKI_DEFCONF:= imx8mp_gki.fragment
else
TARGET_KERNEL_DEFCONFIG := imx8_var_android_defconfig
endif

ifeq ($(POWERSAVE),true)
TARGET_KERNEL_ADDITION_DEFCONF := android_addition_defconfig
endif

# absolute path is used, not the same as relative path used in AOSP make
TARGET_DEVICE_DIR := $(patsubst %/, %, $(dir $(realpath $(lastword $(MAKEFILE_LIST)))))

# define bootloader rollback index
BOOTLOADER_RBINDEX ?= 0

