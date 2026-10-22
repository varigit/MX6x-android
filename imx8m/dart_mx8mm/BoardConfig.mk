# -------@block_infrastructure-------
#
# Product-specific compile-time definitions.
#

include $(CONFIG_REPO_PATH)/imx8m/BoardConfigCommon.mk

# -------@block_common_config-------
#
# SoC-specific compile-time definitions.
#

# value assigned in this part should be fixed for an SoC, right?

BOARD_SOC_TYPE := IMX8MM
BOARD_HAVE_VPU := true
BOARD_VPU_TYPE := hantro
FSL_VPU_OMX_ONLY := true
HAVE_FSL_IMX_GPU2D := true
HAVE_FSL_IMX_GPU3D := true
HAVE_FSL_IMX_PXP := false
TARGET_USES_HWC2 := true
TARGET_HAVE_VULKAN := false

SOONG_CONFIG_IMXPLUGIN += \
                          BOARD_VPU_TYPE

SOONG_CONFIG_IMXPLUGIN_BOARD_SOC_TYPE = IMX8MM
SOONG_CONFIG_IMXPLUGIN_BOARD_HAVE_VPU = true
SOONG_CONFIG_IMXPLUGIN_BOARD_VPU_TYPE = hantro
SOONG_CONFIG_IMXPLUGIN_BOARD_VPU_ONLY = false
SOONG_CONFIG_IMXPLUGIN_PREBUILT_FSL_IMX_CODEC = true
SOONG_CONFIG_IMXPLUGIN_POWERSAVE = false

# -------@block_storage-------
TARGET_USERIMAGES_USE_EXT4 := true

# use sparse image
TARGET_USERIMAGES_SPARSE_EXT_DISABLED := false

ifneq ($(TARGET_INCLUDE_DTB_TO_VENDOR_BOOT),true)
BOARD_PREBUILT_DTBOIMAGE := $(OUT_DIR)/target/product/$(PRODUCT_DEVICE)/dtbo-imx8mm.img
endif

BOARD_USES_METADATA_PARTITION := true
BOARD_ROOT_EXTRA_FOLDERS += metadata

ifneq ($(BUILD_ENCRYPTED_BOOT),true)
  AB_OTA_PARTITIONS += bootloader
endif

# -------@block_security-------
ENABLE_CFI=true

BOARD_AVB_ENABLE := true
BOARD_AVB_ALGORITHM := SHA256_RSA4096
# The testkey_rsa4096.pem is copied from external/avb/test/data/testkey_rsa4096.pem
BOARD_AVB_KEY_PATH := $(CONFIG_REPO_PATH)/common/security/testkey_rsa4096.pem

BOARD_AVB_BOOT_KEY_PATH := external/avb/test/data/testkey_rsa4096.pem
BOARD_AVB_BOOT_ALGORITHM := SHA256_RSA4096
BOARD_AVB_BOOT_ROLLBACK_INDEX_LOCATION := 2

# Enable chained vbmeta for init_boot images
BOARD_AVB_INIT_BOOT_KEY_PATH := external/avb/test/data/testkey_rsa4096.pem
BOARD_AVB_INIT_BOOT_ALGORITHM := SHA256_RSA4096
BOARD_AVB_INIT_BOOT_ROLLBACK_INDEX_LOCATION := 3

# Use sha256 hashtree
BOARD_AVB_SYSTEM_ADD_HASHTREE_FOOTER_ARGS += --hash_algorithm sha256
BOARD_AVB_SYSTEM_EXT_ADD_HASHTREE_FOOTER_ARGS += --hash_algorithm sha256
BOARD_AVB_PRODUCT_ADD_HASHTREE_FOOTER_ARGS += --hash_algorithm sha256
BOARD_AVB_VENDOR_ADD_HASHTREE_FOOTER_ARGS += --hash_algorithm sha256
BOARD_AVB_VENDOR_DLKM_ADD_HASHTREE_FOOTER_ARGS += --hash_algorithm sha256
BOARD_AVB_SYSTEM_DLKM_ADD_HASHTREE_FOOTER_ARGS += --hash_algorithm sha256

# Build GBL image
BOARD_GBL_PARTITION_SIZE := 67108864
BOARD_GBL_KEY_PATH := device/nxp/common/security/testkey_gbl_rsa4096.pem
BOARD_GBL_ROLLBACK_INDEX_LOCATION := 15

# -------@block_treble-------
# Vendor Interface manifest and compatibility
DEVICE_MANIFEST_FILE := $(IMX_DEVICE_PATH)/manifest.xml

DEVICE_MATRIX_FILE := $(IMX_DEVICE_PATH)/compatibility_matrix.xml
DEVICE_FRAMEWORK_COMPATIBILITY_MATRIX_FILE := $(IMX_DEVICE_PATH)/device_framework_matrix.xml


# -------@block_wifi-------
# 8mm LPDDR4 board use NXP 8987 wifi
BOARD_WLAN_DEVICE            := nxp
WPA_SUPPLICANT_VERSION       := VER_0_8_X
BOARD_WPA_SUPPLICANT_DRIVER  := NL80211
BOARD_HOSTAPD_DRIVER         := NL80211
BOARD_HOSTAPD_PRIVATE_LIB               := lib_driver_cmd_$(BOARD_WLAN_DEVICE)
BOARD_WPA_SUPPLICANT_PRIVATE_LIB        := lib_driver_cmd_$(BOARD_WLAN_DEVICE)

# NXP 8987 wifi support dual interface
WIFI_HIDL_FEATURE_DUAL_INTERFACE := true

# NXP 8987 wifi driver module
ifeq ($(BAZEL_BUILD_VENDOR_MODULES),false)
BOARD_VENDOR_KERNEL_MODULES += \
    $(TARGET_OUT_INTERMEDIATES)/MXMWIFI_OBJ/mlan.ko \
    $(TARGET_OUT_INTERMEDIATES)/MXMWIFI_OBJ/moal.ko
endif

# -------@block_bluetooth-------
# NXP 8987 bluetooth
BOARD_HAVE_BLUETOOTH_NXP := true
BOARD_BLUETOOTH_BDROID_BUILDCFG_INCLUDE_DIR := $(IMX_DEVICE_PATH)/bluetooth

# -------@block_kernel_bootimg-------
BOARD_KERNEL_BASE := 0x40400000

CMASIZE=800M

# NXP default config
BOARD_KERNEL_CMDLINE := init=/init firmware_class.path=/vendor/firmware loop.max_part=7 bootconfig
BOARD_BOOTCONFIG += androidboot.console=ttymxc1 androidboot.hardware=nxp

# memory config
BOARD_KERNEL_CMDLINE += transparent_hugepage=never
BOARD_KERNEL_CMDLINE += swiotlb=512

# wifi config
BOARD_BOOTCONFIG += androidboot.wificountrycode=CN
BOARD_KERNEL_CMDLINE += moal.mod_para=wifi_mod_para_sd8987.conf

# low memory device build config
ifeq ($(LOW_MEMORY),true)
BOARD_KERNEL_CMDLINE += cma=320M@0x400M-0xb80M galcore.contiguousSize=33554432
BOARD_BOOTCONFIG += androidboot.displaymode=720p
else
BOARD_KERNEL_CMDLINE += cma=$(CMASIZE)@0x400M-0xb80M
endif

# Disable fw_devlink.strict
BOARD_KERNEL_CMDLINE += fw_devlink.strict=0

# Add KVM support
BOARD_BOOTCONFIG += androidboot.hypervisor.vm.supported=true

ifeq ($(BAZEL_BUILD_VENDOR_MODULES),true)
BOARD_VENDOR_RAMDISK_FRAGMENTS := dlkm_gki
BOARD_VENDOR_RAMDISK_FRAGMENT.dlkm_gki.PREBUILT := vendor/nxp-opensource/imx-gki/ramdisk.lz4
endif

ifneq (,$(filter userdebug eng,$(TARGET_BUILD_VARIANT)))
BOARD_BOOTCONFIG += androidboot.vendor.sysrq=1
endif

ifeq ($(TARGET_USE_DYNAMIC_PARTITIONS),true)
  # dts target for imx8mm_evk with DDR4 on board
  ifeq ($(IMX_NO_PRODUCT_PARTITION),true)
    # dts without product partition
    TARGET_BOARD_DTS_CONFIG ?= imx8mm:imx8mm-evk-no-product.dtb
    TARGET_BOARD_DTS_CONFIG += imx8mm-ddr4:imx8mm-ddr4-evk-no-product.dtb
  else
    TARGET_BOARD_DTS_CONFIG ?= imx8mm-ddr4:imx8mm-ddr4-evk.dtb
    # imx8mm with MIPI-HDMI display and NXP wifi
    TARGET_BOARD_DTS_CONFIG += imx8mm:imx8mm-evk.dtb
    # imx8mm with rm67199 MIPI panel display and NXP wifi
    TARGET_BOARD_DTS_CONFIG += imx8mm-mipi-panel:imx8mm-evk-rm67199.dtb
    # imx8mm with rm67191 MIPI panel display and NXP wifi
    TARGET_BOARD_DTS_CONFIG += imx8mm-mipi-panel-rm67191:imx8mm-evk-rm67191.dtb
    # imx8mm with MIPI-HDMI display, NXP wifi and m4 image to support LPA
    TARGET_BOARD_DTS_CONFIG += imx8mm-m4:imx8mm-evk-rpmsg.dtb
    # imx8mm with IW612 module
    TARGET_BOARD_DTS_CONFIG += imx8mm-iw612:imx8mm-evk-iw612.dtb
  endif
else
  ifeq ($(IMX_NO_PRODUCT_PARTITION),true)
    TARGET_BOARD_DTS_CONFIG ?= imx8mm:imx8mm-evk-no-product-no-dynamic_partition.dtb
    TARGET_BOARD_DTS_CONFIG += imx8mm-ddr4:imx8mm-ddr4-evk-no-product-no-dynamic_partition.dtb
  else
    TARGET_BOARD_DTS_CONFIG ?= imx8mm:imx8mm-evk-no-dynamic_partition.dtb
    TARGET_BOARD_DTS_CONFIG += imx8mm-ddr4:imx8mm-ddr4-evk-no-dynamic_partition.dtb
  endif
endif

ALL_DEFAULT_INSTALLED_MODULES += $(BOARD_VENDOR_KERNEL_MODULES)

# -------@block_sepolicy-------
BOARD_SEPOLICY_DIRS := \
       $(CONFIG_REPO_PATH)/imx8m/sepolicy \
       $(IMX_DEVICE_PATH)/sepolicy

HAS_SYSTEM_EXT_SEPOLICY := true

