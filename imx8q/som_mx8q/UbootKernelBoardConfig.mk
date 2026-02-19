TARGET_BOOTLOADER_POSTFIX := bin
UBOOT_POST_PROCESS := true

# u-boot target for imx8qxp VAR-SOM-MX8X
TARGET_BOOTLOADER_CONFIG := \
	imx8qxp-var-som:imx8qxp_var_som_android_defconfig \
	imx8qxp-b0-var-som:imx8qxp_var_som_android_defconfig \
	imx8qxp-var-som-dual:imx8qxp_var_som_android_dual_defconfig \
	imx8qxp-b0-var-som-dual:imx8qxp_var_som_android_dual_defconfig \
	imx8qxp-var-som-uuu:imx8qxp_var_som_android_uuu_defconfig \
	imx8qxp-b0-var-som-uuu:imx8qxp_var_som_android_uuu_defconfig

ifeq ($(PRODUCT_IMX_TRUSTY),true)
TARGET_BOOTLOADER_CONFIG += \
	imx8qxp-var-som-trusty:imx8qxp_var_som_android_trusty_defconfig \
	imx8qxp-var-som-trusty-dual:imx8qxp_var_som_android_trusty_dual_defconfig
endif
# imx8qxp kernel defconfig
ifeq ($(LOADABLE_KERNEL_MODULE),true)
TARGET_KERNEL_DEFCONFIG := gki_defconfig
TARGET_KERNEL_GKI_DEFCONF:= imx8q_gki.fragment
else
TARGET_KERNEL_DEFCONFIG := imx8_var_android_defconfig
endif
TARGET_KERNEL_ADDITION_DEFCONF := android_addition_defconfig

# absolute path is used, not the same as relative path used in AOSP make
TARGET_DEVICE_DIR := $(patsubst %/, %, $(dir $(realpath $(lastword $(MAKEFILE_LIST)))))

# define bootloader rollback index
BOOTLOADER_RBINDEX ?= 0
