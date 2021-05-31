# from BoardConfig.mk
TARGET_BOOTLOADER_POSTFIX := bin
UBOOT_POST_PROCESS := true

TARGET_BOOTLOADER_CONFIG := \
	  imx8mn-var-som-uuu:imx8mn_var_som_android_uuu_defconfig \
          imx8mn-var-som:imx8mn_var_som_android_defconfig

# imx8mn kernel defconfig
TARGET_KERNEL_DEFCONFIG := imx8_var_android_defconfig

TARGET_KERNEL_ADDITION_DEFCONF := android_addition_defconfig

# absolute path is used, not the same as relative path used in AOSP make
TARGET_DEVICE_DIR := $(patsubst %/, %, $(dir $(realpath $(lastword $(MAKEFILE_LIST)))))

# define bootloader rollback index
BOOTLOADER_RBINDEX ?= 0

