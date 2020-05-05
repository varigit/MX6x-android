#
# SoC-specific compile-time definitions.
#

BOARD_SOC_TYPE := IMX8MQ
BOARD_HAVE_VPU := true
BOARD_VPU_TYPE := hantro
HAVE_FSL_IMX_GPU2D := false
HAVE_FSL_IMX_GPU3D := true
HAVE_FSL_IMX_IPU := false
HAVE_FSL_IMX_PXP := false
BOARD_KERNEL_BASE := 0x40400000
TARGET_GRALLOC_VERSION := v3
TARGET_HIGH_PERFORMANCE := true
TARGET_USES_HWC2 := true
TARGET_HWCOMPOSER_VERSION := v2.0
TARGET_HAVE_VIV_HWCOMPOSER = false
USE_OPENGL_RENDERER := true
TARGET_CPU_SMP := true
TARGET_HAVE_VULKAN := true
ENABLE_CFI=false

# enable opencl 2d.
TARGET_OPENCL_2D := true

#
# Product-specific compile-time definitions.
#

IMX_DEVICE_PATH := device/variscite/imx8m/dart_mx8mq

include $(IMX_DEVICE_PATH)/build_id.mk
include device/fsl/imx8m/BoardConfigCommon.mk
ifeq ($(PREBUILT_FSL_IMX_CODEC),true)
-include $(FSL_CODEC_PATH)/fsl-codec/fsl-codec.mk
endif

BUILD_TARGET_FS ?= ext4
TARGET_USERIMAGES_USE_EXT4 := true

TARGET_RECOVERY_FSTAB = $(IMX_DEVICE_PATH)/fstab.freescale

# Support gpt
BOARD_BPT_INPUT_FILES += device/fsl/common/partition/device-partitions-13GB-ab.bpt
ADDITION_BPT_PARTITION = partition-table-7GB:device/fsl/common/partition/device-partitions-7GB-ab.bpt \
                         partition-table-28GB:device/fsl/common/partition/device-partitions-28GB-ab.bpt


# Vendor Interface manifest and compatibility
DEVICE_MANIFEST_FILE := $(IMX_DEVICE_PATH)/manifest.xml
DEVICE_MATRIX_FILE := $(IMX_DEVICE_PATH)/compatibility_matrix.xml

TARGET_BOOTLOADER_BOARD_NAME := EVK

PRODUCT_MODEL := dart_mx8mq

TARGET_BOOTLOADER_POSTFIX := bin

USE_OPENGL_RENDERER := true
TARGET_CPU_SMP := true

BOARD_WLAN_DEVICE            := bcmdhd
WPA_SUPPLICANT_VERSION       := VER_0_8_X
BOARD_WPA_SUPPLICANT_DRIVER  := NL80211
BOARD_HOSTAPD_DRIVER         := NL80211

BOARD_HOSTAPD_PRIVATE_LIB               := lib_driver_cmd_$(BOARD_WLAN_DEVICE)
BOARD_WPA_SUPPLICANT_PRIVATE_LIB        := lib_driver_cmd_$(BOARD_WLAN_DEVICE)

BOARD_VENDOR_KERNEL_MODULES += \
        $(KERNEL_OUT)/drivers/net/ethernet/freescale/fec.ko \
        $(KERNEL_OUT)/drivers/net/wireless/broadcom/brcm80211/brcmutil/brcmutil.ko \
        $(KERNEL_OUT)/drivers/net/wireless/broadcom/brcm80211/brcmfmac/brcmfmac.ko

PRODUCT_COPY_FILES += \
       $(IMX_DEVICE_PATH)/init.brcm.wifibt.sh:vendor/bin/init.brcm.wifibt.sh

#BOARD_USE_SENSOR_FUSION := true

# for recovery service
TARGET_SELECT_KEY := 28
# we don't support sparse image.
TARGET_USERIMAGES_SPARSE_EXT_DISABLED := false

UBOOT_POST_PROCESS := true

# camera hal v3
IMX_CAMERA_HAL_V3 := true

BOARD_HAVE_USB_CAMERA := true

# whether to accelerate camera service with openCL
# it will make camera service load the opencl lib in vendor
# and break the full treble rule
#OPENCL_2D_IN_CAMERA := true

USE_ION_ALLOCATOR := true
USE_GPU_ALLOCATOR := false

BOARD_AVB_ENABLE := true
TARGET_USES_MKE2FS := true

# define frame buffer count
NUM_FRAMEBUFFER_SURFACE_BUFFERS := 3

ifeq ($(PRODUCT_IMX_DRM),true)
CMASIZE=736M
else
CMASIZE=1280M
endif

KERNEL_NAME := Image
#BOARD_KERNEL_CMDLINE := init=/init androidboot.gui_resolution=1080p androidboot.console=ttymxc0 androidboot.hardware=freescale androidboot.fbTileSupport=enable cma=$(CMASIZE) androidboot.primary_display=imx-drm firmware_class.path=/vendor/firmware transparent_hugepage=never

# Default wificountrycode
#BOARD_KERNEL_CMDLINE += androidboot.wificountrycode=US

# Broadcom BT
BOARD_BLUETOOTH_BDROID_BUILDCFG_INCLUDE_DIR := $(IMX_DEVICE_PATH)/bluetooth
BOARD_CUSTOM_BT_CONFIG := $(BOARD_BLUETOOTH_BDROID_BUILDCFG_INCLUDE_DIR)/vnd_config.txt
BOARD_HAVE_BLUETOOTH_BCM := true
PRODUCT_COPY_FILES += \
       $(IMX_DEVICE_PATH)/bluetooth/bt_vendor.conf:system/etc/bluetooth/bt_vendor.conf

ifeq ($(TARGET_USERIMAGES_USE_UBIFS),true)
ifeq ($(TARGET_USERIMAGES_USE_EXT4),true)
$(error "TARGET_USERIMAGES_USE_UBIFS and TARGET_USERIMAGES_USE_EXT4 config open in same time, please only choose one target file system image")
endif
endif

BOARD_PREBUILT_DTBOIMAGE := out/target/product/dart_mx8mq/dtbo-imx8mq-var-dart-sd-lvds.img
TARGET_BOARD_DTS_CONFIG := \
        imx8mq-var-dart-wifi-lvds-cb12:fsl-imx8mq-var-dart-wifi-lvds-cb12.dtb \
        imx8mq-var-dart-wifi-lvds-hdmi-cb12:fsl-imx8mq-var-dart-wifi-lvds-hdmi-cb12.dtb \
        imx8mq-var-dart-wifi-hdmi-cb12:fsl-imx8mq-var-dart-wifi-hdmi-cb12.dtb \
        imx8mq-var-dart-sd-lvds-cb12:fsl-imx8mq-var-dart-sd-lvds-cb12.dtb \
        imx8mq-var-dart-sd-lvds-hdmi-cb12:fsl-imx8mq-var-dart-sd-lvds-hdmi-cb12.dtb \
        imx8mq-var-dart-sd-hdmi-cb12:fsl-imx8mq-var-dart-sd-hdmi-cb12.dtb \
        imx8mq-var-dart-wifi-lvds:fsl-imx8mq-var-dart-wifi-lvds.dtb \
        imx8mq-var-dart-wifi-lvds-hdmi:fsl-imx8mq-var-dart-wifi-lvds-hdmi.dtb \
        imx8mq-var-dart-wifi-lvds-dp:fsl-imx8mq-var-dart-wifi-lvds-dp.dtb \
        imx8mq-var-dart-wifi-hdmi:fsl-imx8mq-var-dart-wifi-hdmi.dtb \
        imx8mq-var-dart-wifi-dp:fsl-imx8mq-var-dart-wifi-dp.dtb \
        imx8mq-var-dart-sd-lvds:fsl-imx8mq-var-dart-sd-lvds.dtb \
        imx8mq-var-dart-sd-lvds-hdmi:fsl-imx8mq-var-dart-sd-lvds-hdmi.dtb \
        imx8mq-var-dart-sd-lvds-dp:fsl-imx8mq-var-dart-sd-lvds-dp.dtb \
        imx8mq-var-dart-sd-hdmi:fsl-imx8mq-var-dart-sd-hdmi.dtb \
        imx8mq-var-dart-sd-dp:fsl-imx8mq-var-dart-sd-dp.dtb

TARGET_BOOTLOADER_CONFIG := \
        imx8mq-var-dart:imx8mq_var_dart_android_defconfig \
        imx8mq-var-dart-uuu:imx8mq_var_dart_android_uuu_defconfig

TARGET_KERNEL_DEFCONFIG := imx8_var_android_defconfig
# TARGET_KERNEL_ADDITION_DEFCONF ?= android_addition_defconfig

BOARD_SEPOLICY_DIRS := \
       device/fsl/imx8m/sepolicy \
       $(IMX_DEVICE_PATH)/sepolicy

ifeq ($(PRODUCT_IMX_DRM),true)
BOARD_SEPOLICY_DIRS += \
       $(IMX_DEVICE_PATH)/sepolicy_drm
endif

TARGET_BOARD_KERNEL_HEADERS := device/fsl/common/kernel-headers