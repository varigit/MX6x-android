TARGET_BOOTLOADER_POSTFIX := bin
UBOOT_POST_PROCESS := true

TARGET_BOOTLOADER_CONFIG := \
         imx8mq-var-dart:imx8mq_var_dart_android_defconfig \
         imx8mq-var-dart-uuu:imx8mq_var_dart_android_uuu_defconfig

ifeq ($(IMX8MQ_USES_GKI),true)
TARGET_KERNEL_DEFCONFIG := gki_defconfig
TARGET_KERNEL_GKI_DEFCONF:= imx8mq_gki.fragment
else
TARGET_KERNEL_DEFCONFIG := imx_v8_android_defconfig
endif
# TARGET_KERNEL_ADDITION_DEFCONF ?= android_addition_defconfig


# absolute path is used, not the same as relative path used in AOSP make
TARGET_DEVICE_DIR := $(patsubst %/, %, $(dir $(realpath $(lastword $(MAKEFILE_LIST)))))

# define bootloader rollback index
BOOTLOADER_RBINDEX ?= 0

