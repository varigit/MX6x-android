# -------@block_infrastructure-------
#
# Product-specific compile-time definitions.
#

TARGET_IMX_KERNEL := true
include $(CONFIG_REPO_PATH)/imx8m/BoardConfigCommon.mk

# -------@block_common_config-------
#
# SoC-specific compile-time definitions.
#

BOARD_SOC_TYPE := IMX8MP
BOARD_HAVE_VPU := true
BOARD_VPU_TYPE := hantro
HAVE_FSL_IMX_GPU2D := true
HAVE_FSL_IMX_GPU3D := true
HAVE_FSL_IMX_PXP := false
TARGET_USES_HWC2 := true
TARGET_HAVE_VULKAN := true
CFG_SECURE_IOCTRL_REGS := true
ENABLE_SEC_DMABUF_HEAP := true

SOONG_CONFIG_IMXPLUGIN += \
                        BOARD_VPU_TYPE \
                        CFG_SECURE_IOCTRL_REGS \
                        ENABLE_SEC_DMABUF_HEAP

SOONG_CONFIG_IMXPLUGIN_BOARD_SOC_TYPE = IMX8MP
SOONG_CONFIG_IMXPLUGIN_BOARD_HAVE_VPU = true
SOONG_CONFIG_IMXPLUGIN_BOARD_VPU_TYPE = hantro
SOONG_CONFIG_IMXPLUGIN_BOARD_VPU_ONLY = false
SOONG_CONFIG_IMXPLUGIN_PREBUILT_FSL_IMX_CODEC = true
SOONG_CONFIG_IMXPLUGIN_POWERSAVE = $(POWERSAVE)
SOONG_CONFIG_IMXPLUGIN_CFG_SECURE_IOCTRL_REGS = true
SOONG_CONFIG_IMXPLUGIN_ENABLE_SEC_DMABUF_HEAP = true

# -------@block_storage-------

TARGET_USERIMAGES_USE_EXT4 := true

# use sparse image.
TARGET_USERIMAGES_SPARSE_EXT_DISABLED := false

ifneq ($(TARGET_INCLUDE_DTB_TO_VENDOR_BOOT),true)
BOARD_PREBUILT_DTBOIMAGE := $(OUT_DIR)/target/product/$(PRODUCT_DEVICE)/dtbo-imx8mp-var-dart-sonata.img
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
ifeq ($(POWERSAVE),true)
    DEVICE_MANIFEST_FILE := $(IMX_DEVICE_PATH)/manifest_powersave.xml
else
    DEVICE_MANIFEST_FILE := $(IMX_DEVICE_PATH)/manifest.xml
endif

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
BOARD_BLUETOOTH_BDROID_BUILDCFG_INCLUDE_DIR := $(IMX_DEVICE_PATH)/bluetooth

# -------@block_kernel_bootimg-------
BOARD_KERNEL_BASE := 0x40400000

# NXP default config
BOARD_KERNEL_CMDLINE := init=/init firmware_class.path=/vendor/firmware loop.max_part=7 bootconfig
BOARD_KERNEL_CMDLINE += clk-imx8mp.mcore_booted=1
BOARD_BOOTCONFIG += androidboot.hardware=nxp androidboot.primary_display=imx-drm
# console=, earlycon= and androidboot.console are added by U-Boot from the
# detected board (ttymxc0 on DART, ttymxc1 on VAR-SOM and VAR-SMARC).

# memory config
BOARD_KERNEL_CMDLINE += transparent_hugepage=never

# wifi config
BOARD_BOOTCONFIG += androidboot.wificountrycode=US
BOARD_KERNEL_CMDLINE += moal.mod_para=wifi_mod_para_sd8987.conf

# Variscite U-Boot selects CMA from the EEPROM-detected RAM size.

# Add KVM support
BOARD_BOOTCONFIG += androidboot.hypervisor.vm.supported=true

# powersave config
ifeq ($(POWERSAVE),true)
    BOARD_BOOTCONFIG += androidboot.powersave.usb=true androidboot.powersave.uclamp=true androidboot.powersave.lpa=true
endif

ifneq (,$(filter userdebug eng,$(TARGET_BUILD_VARIANT)))
BOARD_BOOTCONFIG += androidboot.vendor.sysrq=1
endif

# DART-MX8M-PLUS on Sonata is the default DT and OTA target. Other variants are explicit outputs.
TARGET_BOARD_DTS_CONFIG := \
    imx8mp-var-dart-sonata:imx8mp-var-dart-sonata.dtb \
    imx8mp-var-dart-1.x-sonata-basler-isi0-m7:imx8mp-var-dart-1.x-sonata-basler-isi0-m7.dtb \
    imx8mp-var-dart-1.x-sonata-basler-isi0:imx8mp-var-dart-1.x-sonata-basler-isi0.dtb \
    imx8mp-var-dart-1.x-sonata-basler-isp0-m7:imx8mp-var-dart-1.x-sonata-basler-isp0-m7.dtb \
    imx8mp-var-dart-1.x-sonata-basler-isp0:imx8mp-var-dart-1.x-sonata-basler-isp0.dtb \
    imx8mp-var-dart-1.x-sonata-m7:imx8mp-var-dart-1.x-sonata-m7.dtb \
    imx8mp-var-dart-1.x-sonata:imx8mp-var-dart-1.x-sonata.dtb \
    imx8mp-var-dart-sonata-basler-isi0-m7:imx8mp-var-dart-sonata-basler-isi0-m7.dtb \
    imx8mp-var-dart-sonata-basler-isi0:imx8mp-var-dart-sonata-basler-isi0.dtb \
    imx8mp-var-dart-sonata-basler-isp0-m7:imx8mp-var-dart-sonata-basler-isp0-m7.dtb \
    imx8mp-var-dart-sonata-basler-isp0:imx8mp-var-dart-sonata-basler-isp0.dtb \
    imx8mp-var-dart-sonata-m7:imx8mp-var-dart-sonata-m7.dtb \
    imx8mp-var-dart-wbe-sonata-basler-isi0-m7:imx8mp-var-dart-wbe-sonata-basler-isi0-m7.dtb \
    imx8mp-var-dart-wbe-sonata-basler-isi0:imx8mp-var-dart-wbe-sonata-basler-isi0.dtb \
    imx8mp-var-dart-wbe-sonata-basler-isp0-m7:imx8mp-var-dart-wbe-sonata-basler-isp0-m7.dtb \
    imx8mp-var-dart-wbe-sonata-basler-isp0:imx8mp-var-dart-wbe-sonata-basler-isp0.dtb \
    imx8mp-var-dart-wbe-sonata-m7:imx8mp-var-dart-wbe-sonata-m7.dtb \
    imx8mp-var-dart-wbe-sonata:imx8mp-var-dart-wbe-sonata.dtb \
    imx8mp-var-smarc-echo-basler-isp0:imx8mp-var-smarc-echo-basler-isp0.dtb \
    imx8mp-var-smarc-echo-m7:imx8mp-var-smarc-echo-m7.dtb \
    imx8mp-var-smarc-echo:imx8mp-var-smarc-echo.dtb \
    imx8mp-var-smarc-wbe-echo-m7:imx8mp-var-smarc-wbe-echo-m7.dtb \
    imx8mp-var-smarc-wbe-echo:imx8mp-var-smarc-wbe-echo.dtb \
    imx8mp-var-som-1.x-symphony-2nd-ov5640-m7:imx8mp-var-som-1.x-symphony-2nd-ov5640-m7.dtb \
    imx8mp-var-som-1.x-symphony-2nd-ov5640:imx8mp-var-som-1.x-symphony-2nd-ov5640.dtb \
    imx8mp-var-som-1.x-symphony-basler-isi0-m7:imx8mp-var-som-1.x-symphony-basler-isi0-m7.dtb \
    imx8mp-var-som-1.x-symphony-basler-isi0:imx8mp-var-som-1.x-symphony-basler-isi0.dtb \
    imx8mp-var-som-1.x-symphony-basler-isp0-m7:imx8mp-var-som-1.x-symphony-basler-isp0-m7.dtb \
    imx8mp-var-som-1.x-symphony-basler-isp0:imx8mp-var-som-1.x-symphony-basler-isp0.dtb \
    imx8mp-var-som-1.x-symphony-m7:imx8mp-var-som-1.x-symphony-m7.dtb \
    imx8mp-var-som-1.x-symphony:imx8mp-var-som-1.x-symphony.dtb \
    imx8mp-var-som-symphony:imx8mp-var-som-symphony.dtb \
    imx8mp-var-som-symphony-2nd-ov5640-m7:imx8mp-var-som-symphony-2nd-ov5640-m7.dtb \
    imx8mp-var-som-symphony-2nd-ov5640:imx8mp-var-som-symphony-2nd-ov5640.dtb \
    imx8mp-var-som-symphony-basler-isi0-m7:imx8mp-var-som-symphony-basler-isi0-m7.dtb \
    imx8mp-var-som-symphony-basler-isi0:imx8mp-var-som-symphony-basler-isi0.dtb \
    imx8mp-var-som-symphony-basler-isp0-m7:imx8mp-var-som-symphony-basler-isp0-m7.dtb \
    imx8mp-var-som-symphony-basler-isp0:imx8mp-var-som-symphony-basler-isp0.dtb \
    imx8mp-var-som-symphony-m7:imx8mp-var-som-symphony-m7.dtb \
    imx8mp-var-som-wbe-symphony-2nd-ov5640-m7:imx8mp-var-som-wbe-symphony-2nd-ov5640-m7.dtb \
    imx8mp-var-som-wbe-symphony-2nd-ov5640:imx8mp-var-som-wbe-symphony-2nd-ov5640.dtb \
    imx8mp-var-som-wbe-symphony-basler-isi0-m7:imx8mp-var-som-wbe-symphony-basler-isi0-m7.dtb \
    imx8mp-var-som-wbe-symphony-basler-isi0:imx8mp-var-som-wbe-symphony-basler-isi0.dtb \
    imx8mp-var-som-wbe-symphony-basler-isp0-m7:imx8mp-var-som-wbe-symphony-basler-isp0-m7.dtb \
    imx8mp-var-som-wbe-symphony-basler-isp0:imx8mp-var-som-wbe-symphony-basler-isp0.dtb \
    imx8mp-var-som-wbe-symphony-m7:imx8mp-var-som-wbe-symphony-m7.dtb \
    imx8mp-var-som-wbe-symphony:imx8mp-var-som-wbe-symphony.dtb

ALL_DEFAULT_INSTALLED_MODULES += $(BOARD_VENDOR_KERNEL_MODULES)

# -------@block_sepolicy-------
BOARD_VENDOR_SEPOLICY_DIRS := \
       $(CONFIG_REPO_PATH)/imx8m/sepolicy \
       $(NXP_DEVICE_PATH)/sepolicy \
       $(IMX_DEVICE_PATH)/sepolicy

HAS_SYSTEM_EXT_SEPOLICY := true

