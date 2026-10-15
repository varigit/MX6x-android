# -------@block_infrastructure-------
#
# Product-specific compile-time definitions.
#

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
BOARD_PREBUILT_DTBOIMAGE := $(OUT_DIR)/target/product/$(PRODUCT_DEVICE)/dtbo-imx8mp.img
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
ifeq ($(POWERSAVE),true)
    DEVICE_MANIFEST_FILE := $(IMX_DEVICE_PATH)/manifest_powersave.xml
else
    DEVICE_MANIFEST_FILE := $(IMX_DEVICE_PATH)/manifest.xml
endif

DEVICE_MATRIX_FILE := $(IMX_DEVICE_PATH)/compatibility_matrix.xml
DEVICE_FRAMEWORK_COMPATIBILITY_MATRIX_FILE := $(IMX_DEVICE_PATH)/device_framework_matrix.xml

# -------@block_wifi-------
# NXP WIFI
BOARD_WLAN_DEVICE            := nxp
WPA_SUPPLICANT_VERSION       := VER_0_8_X
BOARD_WPA_SUPPLICANT_DRIVER  := NL80211
BOARD_HOSTAPD_DRIVER         := NL80211
BOARD_HOSTAPD_PRIVATE_LIB               := lib_driver_cmd_$(BOARD_WLAN_DEVICE)
BOARD_WPA_SUPPLICANT_PRIVATE_LIB        := lib_driver_cmd_$(BOARD_WLAN_DEVICE)

WIFI_HIDL_FEATURE_DUAL_INTERFACE := true
# -------@block_bluetooth-------
# NXP BT
BOARD_HAVE_BLUETOOTH_NXP := true
BOARD_BLUETOOTH_BDROID_BUILDCFG_INCLUDE_DIR := $(IMX_DEVICE_PATH)/bluetooth

# -------@block_kernel_bootimg-------
BOARD_KERNEL_BASE := 0x40400000

CMASIZE=1184M
# NXP default config
BOARD_KERNEL_CMDLINE := init=/init firmware_class.path=/vendor/firmware loop.max_part=7 bootconfig
BOARD_BOOTCONFIG += androidboot.console=ttymxc1 androidboot.hardware=nxp

# memory config
BOARD_KERNEL_CMDLINE += transparent_hugepage=never

# wifi config
BOARD_BOOTCONFIG += androidboot.wificountrycode=CN
BOARD_KERNEL_CMDLINE +=  moal.mod_para=wifi_mod_para.conf pci=nomsi

# low memory device build config
ifeq ($(LOW_MEMORY),true)
BOARD_KERNEL_CMDLINE += cma=320M@0x400M-0xb80M galcore.contiguousSize=33554432
BOARD_BOOTCONFIG += androidboot.displaymode=720p
else
BOARD_KERNEL_CMDLINE += cma=$(CMASIZE)@0x400M-0x1000M
endif

# Add KVM support
BOARD_BOOTCONFIG += androidboot.hypervisor.vm.supported=true

# powersave config
ifeq ($(POWERSAVE),true)
    BOARD_BOOTCONFIG += androidboot.powersave.usb=true androidboot.powersave.uclamp=true androidboot.powersave.lpa=true
endif

ifneq (,$(filter userdebug eng,$(TARGET_BUILD_VARIANT)))
BOARD_BOOTCONFIG += androidboot.vendor.sysrq=1
endif

ifeq ($(TARGET_USE_DYNAMIC_PARTITIONS),true)
  ifeq ($(IMX_NO_PRODUCT_PARTITION),true)
    TARGET_BOARD_DTS_CONFIG := imx8mp:imx8mp-evk-no-product.dtb
  else
    # Default dual os08a20
    TARGET_BOARD_DTS_CONFIG := imx8mp:imx8mp-evk-dual-os08a20.dtb
    # os08a20 + ov5640
    TARGET_BOARD_DTS_CONFIG += imx8mp-os08a20-ov5640:imx8mp-evk-os08a20-ov5640.dtb
    # Only os08a20
    TARGET_BOARD_DTS_CONFIG += imx8mp-os08a20:imx8mp-evk-os08a20.dtb
    # Dual basler
    TARGET_BOARD_DTS_CONFIG += imx8mp-dual-basler:imx8mp-evk-dual-basler.dtb
    # basler + ov5640
    TARGET_BOARD_DTS_CONFIG += imx8mp-basler-ov5640:imx8mp-evk-basler-ov5640.dtb
    # Only basler
    TARGET_BOARD_DTS_CONFIG += imx8mp-basler:imx8mp-evk-basler.dtb
    # Only ov5640
    TARGET_BOARD_DTS_CONFIG += imx8mp-ov5640:imx8mp-evk.dtb
    # Used to support mcu image
    ifeq ($(POWERSAVE),true)
    TARGET_BOARD_DTS_CONFIG += imx8mp-rpmsg:imx8mp-evk-hifiberry-dacpp-m-rpmsg.dtb
    else
    TARGET_BOARD_DTS_CONFIG += imx8mp-rpmsg:imx8mp-evk-rpmsg.dtb
    TARGET_BOARD_DTS_CONFIG += imx8mp-rpmsg-revb4:imx8mp-evk-revb4-rpmsg.dtb
    endif
    # Support LVDS interface
    TARGET_BOARD_DTS_CONFIG += imx8mp-lvds:imx8mp-evk-it6263-lvds-dual-channel.dtb
    # Support LVDS panel
    TARGET_BOARD_DTS_CONFIG += imx8mp-lvds-panel:imx8mp-evk-jdi-wuxga-lvds-panel.dtb
    # Support rm67199 MIPI panel
    TARGET_BOARD_DTS_CONFIG += imx8mp-mipi-panel:imx8mp-evk-rm67199.dtb
    # Support rm67191 MIPI panel
    TARGET_BOARD_DTS_CONFIG += imx8mp-mipi-panel-rm67191:imx8mp-evk-rm67191.dtb
    # Support sof
    TARGET_BOARD_DTS_CONFIG += imx8mp-sof:imx8mp-evk-sof-wm8960.dtb
    # Support sof on revb4
    TARGET_BOARD_DTS_CONFIG += imx8mp-sof-revb4:imx8mp-evk-revb4-sof-wm8962.dtb
    ifeq ($(POWERSAVE),true)
    #Used to support powersave
    TARGET_BOARD_DTS_CONFIG += imx8mp-powersave:imx8mp-evk-powersave.dtb
    TARGET_BOARD_DTS_CONFIG += imx8mp-powersave-revb4:imx8mp-evk-revb4-powersave.dtb
    #Used to support powersave and mcu image
    TARGET_BOARD_DTS_CONFIG += imx8mp-powersave-non-rpmsg:imx8mp-evk-powersave-non-rpmsg.dtb
    TARGET_BOARD_DTS_CONFIG += imx8mp-powersave-non-rpmsg-revb4:imx8mp-evk-revb4-powersave-non-rpmsg.dtb
    endif
    # Default dual os08a20 on revb4
    TARGET_BOARD_DTS_CONFIG += imx8mp-revb4:imx8mp-evk-revb4-dual-os08a20.dtb
    # os08a20 + ov5640 on revb4
    TARGET_BOARD_DTS_CONFIG += imx8mp-os08a20-ov5640-revb4:imx8mp-evk-revb4-os08a20-ov5640.dtb
    # Only os08a20 on revb4
    TARGET_BOARD_DTS_CONFIG += imx8mp-os08a20-revb4:imx8mp-evk-revb4-os08a20.dtb
    # Dual basler on revb4
    TARGET_BOARD_DTS_CONFIG += imx8mp-dual-basler-revb4:imx8mp-evk-revb4-dual-basler.dtb
    # basler + ov5640 on revb4
    TARGET_BOARD_DTS_CONFIG += imx8mp-basler-ov5640-revb4:imx8mp-evk-revb4-basler-ov5640.dtb
    # Only basler on revb4
    TARGET_BOARD_DTS_CONFIG += imx8mp-basler-revb4:imx8mp-evk-revb4-basler.dtb
    # Only ov5640 on revb4
    TARGET_BOARD_DTS_CONFIG += imx8mp-ov5640-revb4:imx8mp-evk-revb4.dtb
    # Support LVDS interface on revb4
    TARGET_BOARD_DTS_CONFIG += imx8mp-lvds-revb4:imx8mp-evk-revb4-it6263-lvds-dual-channel.dtb
    # Support LVDS panel on revb4
    TARGET_BOARD_DTS_CONFIG += imx8mp-lvds-panel-revb4:imx8mp-evk-revb4-jdi-wuxga-lvds-panel.dtb
    # Support rm67199 MIPI panel on revb4
    TARGET_BOARD_DTS_CONFIG += imx8mp-mipi-panel-revb4:imx8mp-evk-revb4-rm67199.dtb
    # Support rm67191 MIPI panel on revb4
    TARGET_BOARD_DTS_CONFIG += imx8mp-mipi-panel-rm67191-revb4:imx8mp-evk-revb4-rm67191.dtb
    # Support HDMI display on FRDM board
    TARGET_BOARD_DTS_CONFIG += imx8mp-frdm:imx8mp-frdm-os08a20-dual.dtb
    # Support LVDS Panel on FRDM board
    TARGET_BOARD_DTS_CONFIG += imx8mp-frdm-boe-panel-lvds0:imx8mp-frdm-boe-wuxga-lvds0-panel.dtb
    # Support waveshare Panel on FRDM board
    TARGET_BOARD_DTS_CONFIG += imx8mp-frdm-waveshare-panel:imx8mp-frdm-waveshare-7inch-c-panel.dtb
  endif
else # no dynamic parition feature
  ifeq ($(IMX_NO_PRODUCT_PARTITION),true)
    TARGET_BOARD_DTS_CONFIG := imx8mp:imx8mp-evk-no-product-no-dynamic_partition.dtb
  else
    TARGET_BOARD_DTS_CONFIG := imx8mp:imx8mp-evk-no-dynamic_partition.dtb
  endif
endif

ALL_DEFAULT_INSTALLED_MODULES += $(BOARD_VENDOR_KERNEL_MODULES)

# -------@block_sepolicy-------
BOARD_SEPOLICY_DIRS := \
       $(CONFIG_REPO_PATH)/imx8m/sepolicy \
       $(IMX_DEVICE_PATH)/sepolicy

HAS_SYSTEM_EXT_SEPOLICY := true

