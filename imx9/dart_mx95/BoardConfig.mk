# -------@block_infrastructure-------
#
# Product-specific compile-time definitions.
#

include $(CONFIG_REPO_PATH)/imx9/BoardConfigCommon.mk

# -------@block_common_config-------
#
# SoC-specific compile-time definitions.
#

BOARD_SOC_TYPE := IMX95
BOARD_HAVE_VPU := true
BOARD_VPU_TYPE := wave6
HAVE_FSL_IMX_GPU2D := false
HAVE_FSL_IMX_GPU3D := true
HAVE_FSL_IMX_PXP := false
TARGET_USES_HWC2 := true
TARGET_HAVE_VULKAN := true
CFG_SECURE_IOCTRL_REGS := true
ENABLE_SEC_DMABUF_HEAP := true
MEDIA_PIPELINE := NEOISP

SOONG_CONFIG_IMXPLUGIN += \
                        BOARD_VPU_TYPE \
                        CFG_SECURE_IOCTRL_REGS \
                        ENABLE_SEC_DMABUF_HEAP \
                        MEDIA_PIPELINE

SOONG_CONFIG_IMXPLUGIN_BOARD_SOC_TYPE = IMX95
SOONG_CONFIG_IMXPLUGIN_HAVE_FSL_IMX_GPU3D = true
SOONG_CONFIG_IMXPLUGIN_BOARD_HAVE_VPU = true
SOONG_CONFIG_IMXPLUGIN_BOARD_VPU_TYPE = wave6
SOONG_CONFIG_IMXPLUGIN_BOARD_VPU_ONLY = false
SOONG_CONFIG_IMXPLUGIN_PREBUILT_FSL_IMX_CODEC = true
SOONG_CONFIG_IMXPLUGIN_CFG_SECURE_IOCTRL_REGS = true
SOONG_CONFIG_IMXPLUGIN_ENABLE_SEC_DMABUF_HEAP = true
SOONG_CONFIG_IMXPLUGIN_MEDIA_PIPELINE = NEOISP

BOARD_GPU_DRIVERS := mali

# -------@block_storage-------

TARGET_USERIMAGES_USE_EXT4 := true

# use sparse image.
TARGET_USERIMAGES_SPARSE_EXT_DISABLED := false

# Support gpt
ifeq ($(TARGET_USE_DYNAMIC_PARTITIONS),true)
  BOARD_BPT_INPUT_FILES += $(CONFIG_REPO_PATH)/common/partition/device-partitions-28GB-ab_super.bpt
  ADDITION_BPT_PARTITION = partition-table-13GB:$(CONFIG_REPO_PATH)/common/partition/device-partitions-13GB-ab_super.bpt \
                           partition-table-dual:$(CONFIG_REPO_PATH)/common/partition/device-partitions-28GB-ab-dual-bootloader_super.bpt \
                           partition-table-13GB-dual:$(CONFIG_REPO_PATH)/common/partition/device-partitions-13GB-ab-dual-bootloader_super.bpt
else
  ifeq ($(IMX_NO_PRODUCT_PARTITION),true)
    BOARD_BPT_INPUT_FILES += $(CONFIG_REPO_PATH)/common/partition/device-partitions-13GB-ab-no-product.bpt
    ADDITION_BPT_PARTITION = partition-table-28GB:$(CONFIG_REPO_PATH)/common/partition/device-partitions-28GB-ab-no-product.bpt \
                             partition-table-dual:$(CONFIG_REPO_PATH)/common/partition/device-partitions-13GB-ab-dual-bootloader-no-product.bpt \
                             partition-table-28GB-dual:$(CONFIG_REPO_PATH)/common/partition/device-partitions-28GB-ab-dual-bootloader-no-product.bpt
  else
    BOARD_BPT_INPUT_FILES += $(CONFIG_REPO_PATH)/common/partition/device-partitions-13GB-ab.bpt
    ADDITION_BPT_PARTITION = partition-table-28GB:$(CONFIG_REPO_PATH)/common/partition/device-partitions-28GB-ab.bpt \
                             partition-table-dual:$(CONFIG_REPO_PATH)/common/partition/device-partitions-13GB-ab-dual-bootloader.bpt \
                             partition-table-28GB-dual:$(CONFIG_REPO_PATH)/common/partition/device-partitions-28GB-ab-dual-bootloader.bpt
  endif
endif

BOARD_PREBUILT_DTBOIMAGE := $(OUT_DIR)/target/product/$(PRODUCT_DEVICE)/dtbo-imx95.img

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

DEVICE_MATRIX_FILE := $(IMX_DEVICE_PATH)/compatibility_matrix.xml
DEVICE_FRAMEWORK_COMPATIBILITY_MATRIX_FILE := $(IMX_DEVICE_PATH)/device_framework_matrix.xml

# -------@block_wifi-------
# NXP 8997 WIFI
BOARD_WLAN_DEVICE            := nxp
WPA_SUPPLICANT_VERSION       := VER_0_8_X
BOARD_WPA_SUPPLICANT_DRIVER  := NL80211
BOARD_HOSTAPD_DRIVER         := NL80211
BOARD_HOSTAPD_PRIVATE_LIB               := lib_driver_cmd_$(BOARD_WLAN_DEVICE)
BOARD_WPA_SUPPLICANT_PRIVATE_LIB        := lib_driver_cmd_$(BOARD_WLAN_DEVICE)

WIFI_HIDL_FEATURE_DUAL_INTERFACE := true
# -------@block_bluetooth-------
# NXP 8997 BT
BOARD_HAVE_BLUETOOTH_NXP := true
BOARD_BLUETOOTH_BDROID_BUILDCFG_INCLUDE_DIR := $(IMX_DEVICE_PATH)/bluetooth

# -------@block_kernel_bootimg-------
BOARD_KERNEL_BASE := 0x90400000

CMASIZE=992M
# NXP default config
BOARD_KERNEL_CMDLINE := init=/init firmware_class.path=/vendor/firmware loop.max_part=7 bootconfig
BOARD_BOOTCONFIG += androidboot.console=ttyLP0 androidboot.hardware=nxp

# memory config
BOARD_KERNEL_CMDLINE += transparent_hugepage=never
BOARD_KERNEL_CMDLINE += cma=$(CMASIZE)@0xBF0M-0xFF0M

# display config
BOARD_BOOTCONFIG += androidboot.lcd_density=240 androidboot.dpu_composition=1

# wifi config
BOARD_BOOTCONFIG += androidboot.wificountrycode=CN
BOARD_KERNEL_CMDLINE +=  moal.mod_para=wifi_mod_para.conf

# Add KVM support
BOARD_BOOTCONFIG += androidboot.hypervisor.vm.supported=true

ifneq (,$(filter userdebug eng,$(TARGET_BUILD_VARIANT)))
BOARD_BOOTCONFIG += androidboot.vendor.sysrq=1
endif

TARGET_BOARD_DTS_CONFIG := imx95:imx95-19x19-evk-os08a20-isp-adv7535.dtb
TARGET_BOARD_DTS_CONFIG += imx95-ap1302:imx95-19x19-evk-adv7535-ap1302.dtb
TARGET_BOARD_DTS_CONFIG += imx95-mipi-lvds1:imx95-19x19-evk-adv7535-it6263-lvds1-ap1302.dtb
TARGET_BOARD_DTS_CONFIG += imx95-mipi-panel:imx95-19x19-evk-rm692c9.dtb
TARGET_BOARD_DTS_CONFIG += imx95-lvds0:imx95-19x19-evk-os08a20-isp-it6263-lvds0.dtb
TARGET_BOARD_DTS_CONFIG += imx95-lvds-dualdisp:imx95-19x19-evk-it6263-lvds-two-disp.dtb
TARGET_BOARD_DTS_CONFIG += imx95-lvds-panel:imx95-19x19-evk-jdi-wuxga-lvds-panel.dtb
TARGET_BOARD_DTS_CONFIG += imx95-cs42888:imx95-19x19-evk-os08a20-isp-adv7535-cs42888.dtb
TARGET_BOARD_DTS_CONFIG += imx95-rpmsg:imx95-19x19-evk-adv7535-rpmsg.dtb
TARGET_BOARD_DTS_CONFIG += imx95-mipi4k:imx95-19x19-evk-lt9611uxc-ap1302.dtb
TARGET_BOARD_DTS_CONFIG += imx95-dsi-serdes:imx95-19x19-evk-dsi-serdes.dtb
TARGET_BOARD_DTS_CONFIG += imx95-verdin:imx95-19x19-verdin-os08a20-isp-adv7535.dtb
TARGET_BOARD_DTS_CONFIG += imx95-verdin-ap1302:imx95-19x19-verdin-adv7535-ap1302.dtb
TARGET_BOARD_DTS_CONFIG += imx95-verdin-lt8912:imx95-19x19-verdin-lt8912-ap1302.dtb
TARGET_BOARD_DTS_CONFIG += imx95-verdin-10inch-panel-lvds:imx95-19x19-verdin-panel-cap-touch-10inch-lvds.dtb
TARGET_BOARD_DTS_CONFIG += imx95-verdin-10inch-panel-dsi:imx95-19x19-verdin-panel-cap-touch-10inch-dsi.dtb
TARGET_BOARD_DTS_CONFIG += imx95-verdin-mipi-panel:imx95-19x19-verdin-rm692c9.dtb
TARGET_BOARD_DTS_CONFIG += imx95-verdin-mipi4k:imx95-19x19-verdin-lt9611uxc-ap1302.dtb
TARGET_BOARD_DTS_CONFIG += imx95-15x15:imx95-15x15-evk-os08a20-isp-adv7535.dtb
TARGET_BOARD_DTS_CONFIG += imx95-15x15-ap1302:imx95-15x15-evk-adv7535-ap1302.dtb
TARGET_BOARD_DTS_CONFIG += imx95-15x15-mipi-panel:imx95-15x15-evk-rm692c9.dtb
TARGET_BOARD_DTS_CONFIG += imx95-15x15-aud-hat:imx95-15x15-evk-adv7535-aud-hat.dtb
TARGET_BOARD_DTS_CONFIG += imx95-15x15-mqs:imx95-15x15-evk-adv7535-mqs.dtb
TARGET_BOARD_DTS_CONFIG += imx95-15x15-mipi4k:imx95-15x15-evk-lt9611uxc-ap1302.dtb
TARGET_BOARD_DTS_CONFIG += imx95-15x15-boe-panel-lvds1:imx95-15x15-evk-boe-wxga-lvds1-panel.dtb

ALL_DEFAULT_INSTALLED_MODULES += $(BOARD_VENDOR_KERNEL_MODULES)

# -------@block_sepolicy-------
BOARD_SEPOLICY_DIRS := \
       $(CONFIG_REPO_PATH)/imx9/sepolicy \
       $(IMX_DEVICE_PATH)/sepolicy

HAS_SYSTEM_EXT_SEPOLICY := true

