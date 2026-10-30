# -------@block_infrastructure-------
#
# Product-specific compile-time definitions.
#if TARGET_IMX_KERNEL is false, the full ota package
#takes the gki boot image from vendor/nxp/. so that
#causes to unknown symbol failure in boot.

TARGET_IMX_KERNEL := true
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
TARGET_HAVE_VULKAN := true
TARGET_USES_BCM_WIFI ?= false

SOONG_CONFIG_IMXPLUGIN += \
                          BOARD_VPU_TYPE

SOONG_CONFIG_IMXPLUGIN_BOARD_SOC_TYPE = IMX8MM
SOONG_CONFIG_IMXPLUGIN_BOARD_HAVE_VPU = true
SOONG_CONFIG_IMXPLUGIN_BOARD_VPU_TYPE = hantro
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

ifneq ($(TARGET_INCLUDE_DTB_TO_VENDOR_BOOT),true)
BOARD_PREBUILT_DTBOIMAGE := $(OUT_DIR)/target/product/$(PRODUCT_DEVICE)/dtbo-imx8mm-var-dart-2.x-sonata.img
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
BOARD_AVB_KEY_PATH := external/avb/test/data/testkey_rsa4096.pem

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

DEVICE_MATRIX_FILE := $(NXP_DEVICE_PATH)/compatibility_matrix.xml
DEVICE_FRAMEWORK_COMPATIBILITY_MATRIX_FILE := $(NXP_DEVICE_PATH)/device_framework_matrix.xml

# -------@block_wifi-------
ifeq ($(TARGET_USES_BCM_WIFI),true)
# Sterling LWB / LWB5 WiFi (1.x SOM revisions)
BOARD_WLAN_DEVICE            := bcmdhd
else
# NXP 88W8987 / IW612 WIFI
BOARD_WLAN_DEVICE            := nxp
endif
WPA_SUPPLICANT_VERSION       := VER_0_8_X
BOARD_WPA_SUPPLICANT_DRIVER  := NL80211
BOARD_HOSTAPD_DRIVER         := NL80211
BOARD_HOSTAPD_PRIVATE_LIB               := lib_driver_cmd_$(BOARD_WLAN_DEVICE)
BOARD_WPA_SUPPLICANT_PRIVATE_LIB        := lib_driver_cmd_$(BOARD_WLAN_DEVICE)

WIFI_HIDL_FEATURE_DUAL_INTERFACE := true
# -------@block_bluetooth-------
# NXP BT
BOARD_HAVE_BLUETOOTH_NXP := false

# -------@block_kernel_bootimg-------
BOARD_KERNEL_BASE := 0x40400000

CMASIZE=800M

# NXP default config
BOARD_KERNEL_CMDLINE := init=/init firmware_class.path=/vendor/firmware loop.max_part=7 bootconfig
BOARD_BOOTCONFIG += androidboot.hardware=nxp

# memory config
BOARD_KERNEL_CMDLINE += transparent_hugepage=never
BOARD_KERNEL_CMDLINE += swiotlb=512

# wifi config
BOARD_BOOTCONFIG += androidboot.wificountrycode=US
BOARD_KERNEL_CMDLINE += moal.mod_para=wifi_mod_para.conf

BOARD_KERNEL_CMDLINE += cma=$(CMASIZE)@0x400M-0xb80M

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

TARGET_BOARD_DTS_CONFIG := \
    imx8mm-var-dart-2.x-sonata:imx8mm-var-dart-2.x-sonata.dtb \
    imx8mm-var-dart-2.x-sonata-m4:imx8mm-var-dart-2.x-sonata-m4.dtb \
    imx8mm-var-som-symphony-2.0-m4:imx8mm-var-som-symphony-2.0-m4.dtb \
    imx8mm-var-dart-1.x-sonata:imx8mm-var-dart-1.x-sonata.dtb \
    imx8mm-var-dart-1.x-sonata-m4:imx8mm-var-dart-1.x-sonata-m4.dtb \
    imx8mm-var-som-1.x-symphony-2.0:imx8mm-var-som-1.x-symphony-2.0.dtb \
    imx8mm-var-som-1.x-symphony-2.0-m4:imx8mm-var-som-1.x-symphony-2.0-m4.dtb \
    imx8mm-var-dart-2.x-wbe-sonata:imx8mm-var-dart-2.x-wbe-sonata.dtb \
    imx8mm-var-dart-2.x-wbe-sonata-m4:imx8mm-var-dart-2.x-wbe-sonata-m4.dtb \
    imx8mm-var-som-wbe-symphony-2.0:imx8mm-var-som-wbe-symphony-2.0.dtb \
    imx8mm-var-som-wbe-symphony-2.0-m4:imx8mm-var-som-wbe-symphony-2.0-m4.dtb \
    imx8mm-var-som-symphony-2.0:imx8mm-var-som-symphony-2.0.dtb \
    imx8mm-var-som-symphony-legacy:imx8mm-var-som-symphony-legacy.dtb \
    imx8mm-var-dart-3.x-sonata:imx8mm-var-dart-3.x-sonata.dtb \
    imx8mm-var-dart-3.x-sonata-m4:imx8mm-var-dart-3.x-sonata-m4.dtb \
    imx8mm-var-dart-3.x-wbe-sonata:imx8mm-var-dart-3.x-wbe-sonata.dtb \
    imx8mm-var-dart-3.x-wbe-sonata-m4:imx8mm-var-dart-3.x-wbe-sonata-m4.dtb \
    imx8mm-var-som-symphony:imx8mm-var-som-symphony.dtb \
    imx8mm-var-som-symphony-m4:imx8mm-var-som-symphony-m4.dtb \
    imx8mm-var-som-1.x-symphony:imx8mm-var-som-1.x-symphony.dtb \
    imx8mm-var-som-1.x-symphony-m4:imx8mm-var-som-1.x-symphony-m4.dtb \
    imx8mm-var-som-wbe-symphony:imx8mm-var-som-wbe-symphony.dtb \
    imx8mm-var-som-wbe-symphony-m4:imx8mm-var-som-wbe-symphony-m4.dtb

ALL_DEFAULT_INSTALLED_MODULES += $(BOARD_VENDOR_KERNEL_MODULES)

# -------@block_sepolicy-------
BOARD_VENDOR_SEPOLICY_DIRS := \
       $(CONFIG_REPO_PATH)/imx8m/sepolicy \
       $(NXP_DEVICE_PATH)/sepolicy \
       $(IMX_DEVICE_PATH)/sepolicy

HAS_SYSTEM_EXT_SEPOLICY := true

BOARD_BOOTCONFIG += \
       androidboot.vendor.apex.com.google.android.widevine=com.google.android.widevine
