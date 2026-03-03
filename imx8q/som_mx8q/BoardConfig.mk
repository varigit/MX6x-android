# -------@block_infrastructure-------
#
# Product-specific compile-time definitions.
#if TARGET_IMX_KERNEL is false, the full ota package
#takes the gki boot image from vendor/nxp/. so that
#causes to unknown symbol failure in boot.

TARGET_IMX_KERNEL := true
include $(CONFIG_REPO_PATH)/imx8q/BoardConfigCommon.mk

# -------@block_common_config-------
#
# SoC-specific compile-time definitions.
#

BOARD_SOC_TYPE := IMX8Q
BOARD_HAVE_VPU := true
BOARD_VPU_TYPE := malone
FSL_VPU_OMX_ONLY := true
HAVE_FSL_IMX_GPU2D := true
HAVE_FSL_IMX_GPU3D := true
HAVE_FSL_IMX_PXP := false
TARGET_USES_HWC2 := true
TARGET_HAVE_VULKAN := true

SOONG_CONFIG_IMXPLUGIN += \
                          BOARD_VPU_TYPE

SOONG_CONFIG_IMXPLUGIN_BOARD_SOC_TYPE = IMX8Q
SOONG_CONFIG_IMXPLUGIN_BOARD_HAVE_VPU = true
SOONG_CONFIG_IMXPLUGIN_BOARD_VPU_TYPE = malone
SOONG_CONFIG_IMXPLUGIN_BOARD_VPU_ONLY = false
SOONG_CONFIG_IMXPLUGIN_PREBUILT_FSL_IMX_CODEC = true
SOONG_CONFIG_IMXPLUGIN_POWERSAVE = false

# -------@block_memory-------
USE_ION_ALLOCATOR := true
USE_GPU_ALLOCATOR := false

# -------@block_storage-------
TARGET_USERIMAGES_USE_EXT4 := true

# use sparse image
TARGET_USERIMAGES_SPARSE_EXT_DISABLED := false

# Support gpt
ifeq ($(TARGET_USE_DYNAMIC_PARTITIONS),true)
  BOARD_BPT_INPUT_FILES += $(CONFIG_REPO_PATH)/common/partition/device-partitions-13GB-ab_super.bpt
  ADDITION_BPT_PARTITION = partition-table-28GB:$(CONFIG_REPO_PATH)/common/partition/device-partitions-28GB-ab_super.bpt \
                           partition-table-dual:$(CONFIG_REPO_PATH)/common/partition/device-partitions-13GB-ab-dual-bootloader_super.bpt \
                           partition-table-28GB-dual:$(CONFIG_REPO_PATH)/common/partition/device-partitions-28GB-ab-dual-bootloader_super.bpt
else
  ifeq ($(IMX_NO_PRODUCT_PARTITION),true)
    BOARD_BPT_INPUT_FILES += $(CONFIG_REPO_PATH)/common/partition/device-partitions-13GB-ab-no-product.bpt
    ADDITION_BPT_PARTITION = partition-table-28GB:$(CONFIG_REPO_PATH)/common/partition/device-partitions-28GB-ab-no-product.bpt
  else
    BOARD_BPT_INPUT_FILES += $(CONFIG_REPO_PATH)/common/partition/device-partitions-13GB-ab.bpt
    ADDITION_BPT_PARTITION = partition-table-28GB:$(CONFIG_REPO_PATH)/common/partition/device-partitions-28GB-ab.bpt
  endif
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

# -------@block_treble-------
# Vendor Interface manifest and compatibility
DEVICE_MANIFEST_FILE := $(IMX_DEVICE_PATH)/manifest.xml

DEVICE_MATRIX_FILE := $(NXP_DEVICE_PATH)/compatibility_matrix.xml
DEVICE_FRAMEWORK_COMPATIBILITY_MATRIX_FILE := $(NXP_DEVICE_PATH)/device_framework_matrix.xml

# -------@block_wifi-------

# Sterling LWB / LWB5 WiFi
BOARD_WLAN_DEVICE            := bcmdhd
WPA_SUPPLICANT_VERSION        := VER_0_8_X
BOARD_WPA_SUPPLICANT_DRIVER  := NL80211
BOARD_HOSTAPD_DRIVER         := NL80211
BOARD_HOSTAPD_PRIVATE_LIB                := lib_driver_cmd_$(BOARD_WLAN_DEVICE)
BOARD_WPA_SUPPLICANT_PRIVATE_LIB         := lib_driver_cmd_$(BOARD_WLAN_DEVICE)

WIFI_HIDL_FEATURE_DUAL_INTERFACE := false

# -------@block_bluetooth-------
BOARD_BLUETOOTH_BDROID_BUILDCFG_INCLUDE_DIR := $(IMX_DEVICE_PATH)/bluetooth

# -------@block_kernel_bootimg-------

# NXP default config
BOARD_KERNEL_CMDLINE := init=/init firmware_class.path=/vendor/firmware loop.max_part=7 bootconfig
BOARD_KERNEL_CMDLINE += swiotlb=768
BOARD_KERNEL_CMDLINE += cma=928M@0x960M-0xfc0M transparent_hugepage=never
BOARD_BOOTCONFIG += androidboot.hardware=nxp

# framebuffer config
BOARD_BOOTCONFIG += androidboot.fbTileSupport=enable

# console
ifeq ($(TARGET_PRODUCT),som_mx8qm)
BOARD_BOOTCONFIG += androidboot.console=ttyLP0
else
BOARD_BOOTCONFIG += androidboot.console=ttyLP3
endif

# WiFi SDIO controller address for unbind/rebind sequence
ifeq ($(TARGET_PRODUCT),som_mx8qm)
BOARD_BOOTCONFIG += androidboot.wifisdio=5b030000.mmc
else
BOARD_BOOTCONFIG += androidboot.wifisdio=5b020000.mmc
endif

# BT UART controller address for unbind/rebind sequence
ifeq ($(TARGET_PRODUCT),som_mx8qm)
BOARD_BOOTCONFIG += androidboot.btuart=5a070000.serial
else
BOARD_BOOTCONFIG += androidboot.btuart=5a060000.serial
endif

ifneq (,$(filter userdebug eng,$(TARGET_BUILD_VARIANT)))
BOARD_BOOTCONFIG += androidboot.vendor.sysrq=1
endif

ALL_DEFAULT_INSTALLED_MODULES += $(BOARD_VENDOR_KERNEL_MODULES)

# -------@block_sepolicy-------
BOARD_VENDOR_SEPOLICY_DIRS := \
       $(CONFIG_REPO_PATH)/imx8q/sepolicy \
       $(NXP_DEVICE_PATH)/sepolicy \
       $(IMX_DEVICE_PATH)/sepolicy

HAS_SYSTEM_EXT_SEPOLICY := true

BOARD_BOOTCONFIG += \
       androidboot.vendor.apex.com.google.android.widevine=com.google.android.widevine
