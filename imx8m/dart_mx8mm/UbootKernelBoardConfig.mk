TARGET_BOOTLOADER_POSTFIX := bin
UBOOT_POST_PROCESS := true

# u-boot target for imx8mm_evk with DDR4 on board
TARGET_BOOTLOADER_CONFIG := imx8mm-ddr4:imx8mm_ddr4_evk_android_defconfig
# u-boot target for imx8mm_evk with LPDDR4 on board
ifeq ($(LOW_MEMORY),true)
  TARGET_BOOTLOADER_CONFIG += imx8mm:imx8mm_evk_1g_ddr_android_defconfig
else
  TARGET_BOOTLOADER_CONFIG += imx8mm:imx8mm_evk_android_defconfig
  TARGET_BOOTLOADER_CONFIG += imx8mm-gbl:imx8mm_evk_android_gbl_defconfig
  TARGET_BOOTLOADER_CONFIG += imx8mm-dual:imx8mm_evk_android_dual_defconfig
endif
TARGET_BOOTLOADER_CONFIG += imx8mm-4g:imx8mm_evk_4g_android_defconfig
ifeq ($(PRODUCT_IMX_TRUSTY),true)
  TARGET_BOOTLOADER_CONFIG += imx8mm-trusty-secure-unlock-dual:imx8mm_evk_android_trusty_secure_unlock_dual_defconfig
  TARGET_BOOTLOADER_CONFIG += imx8mm-trusty-dual:imx8mm_evk_android_trusty_dual_defconfig
  TARGET_BOOTLOADER_CONFIG += imx8mm-trusty-gbl-dual:imx8mm_evk_android_trusty_gbl_dual_defconfig
  TARGET_BOOTLOADER_CONFIG += imx8mm-trusty-rbidx-blob-dual:imx8mm_evk_android_trusty_rbidx_blob_dual_defconfig
endif

# u-boot target used by uuu for imx8mm_evk with DDR4 on board
TARGET_BOOTLOADER_CONFIG += imx8mm-ddr4-evk-uuu:imx8mm_ddr4_evk_android_uuu_defconfig
# u-boot target used by uuu for imx8mm_evk with LPDDR4 on board
TARGET_BOOTLOADER_CONFIG += imx8mm-evk-uuu:imx8mm_evk_android_uuu_defconfig
TARGET_BOOTLOADER_CONFIG += imx8mm-4g-evk-uuu:imx8mm_evk_4g_android_uuu_defconfig

# imx8mm kernel defconfig
TARGET_KERNEL_DEFCONFIG := gki_defconfig
ifeq ($(LOADABLE_KERNEL_MODULE),true)
TARGET_KERNEL_GKI_DEFCONF:= imx8mm_gki.fragment
else
TARGET_KERNEL_GKI_DEFCONF := imx_v8_android_defconfig
endif
TARGET_KERNEL_ADDITION_DEFCONF := android_addition_defconfig

# absolute path is used, not the same as relative path used in AOSP make
TARGET_DEVICE_DIR := $(patsubst %/, %, $(dir $(realpath $(lastword $(MAKEFILE_LIST)))))

# define bootloader rollback index
BOOTLOADER_RBINDEX ?= 0

