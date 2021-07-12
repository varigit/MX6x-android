include device/variscite/imx8q/som_mx8q/$(TARGET_PRODUCT).mk

TARGET_BOOTLOADER_POSTFIX := bin
UBOOT_POST_PROCESS := true

# absolute path is used, not the same as relative path used in AOSP make
TARGET_DEVICE_DIR := $(patsubst %/, %, $(dir $(realpath $(lastword $(MAKEFILE_LIST)))))

TARGET_KERNEL_DEFCONFIG := imx8_var_android_defconfig

# define rollback index in container
ifeq ($(PRODUCT_IMX_CAR),true)
  BOOTLOADER_RBINDEX ?= 0
endif

