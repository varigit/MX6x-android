TARGET_BOOTLOADER_POSTFIX := bin
UBOOT_POST_PROCESS := true

# u-boot target for dart & var-som with DDR4 & lpddr4 on board
TARGET_BOOTLOADER_CONFIG := imx8mm-var-dart:imx8mm_var_dart_android_defconfig
TARGET_BOOTLOADER_CONFIG += imx8mm-var-dart-dual:imx8mm_var_dart_android_dual_defconfig

ifeq ($(PRODUCT_IMX_TRUSTY),true)
  TARGET_BOOTLOADER_CONFIG += imx8mm-var-dart-trusty-secure-unlock-dual:imx8mm_var_dart_android_trusty_secure_unlock_dual_defconfig
  TARGET_BOOTLOADER_CONFIG += imx8mm-var-dart-trusty-dual:imx8mm_var_dart_android_trusty_dual_defconfig
endif

# u-boot target used by uuu for dart & var-som
TARGET_BOOTLOADER_CONFIG += imx8mm-var-dart-uuu:imx8mm_var_dart_android_uuu_defconfig

# imx8mm kernel defconfig
ifeq ($(LOADABLE_KERNEL_MODULE),true)
TARGET_KERNEL_DEFCONFIG := gki_defconfig
TARGET_KERNEL_GKI_DEFCONF:= imx8mm_gki.fragment
else
TARGET_KERNEL_DEFCONFIG := imx_v8_android_defconfig
endif
TARGET_KERNEL_ADDITION_DEFCONF := android_addition_defconfig

# absolute path is used, not the same as relative path used in AOSP make
TARGET_DEVICE_DIR := $(patsubst %/, %, $(dir $(realpath $(lastword $(MAKEFILE_LIST)))))

# define bootloader rollback index
BOOTLOADER_RBINDEX ?= 0

