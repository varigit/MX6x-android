#
# Product-specific compile-time definitions.
#

include device/fsl/imx8/soc/imx8mq.mk
ifeq ($(PRODUCT_IMX_DRM),true)
include device/variscite/dart_mx8m/build_id_drm.mk
else
include device/variscite/dart_mx8m/build_id.mk
endif # PRODUCT_IMX_DRM
include device/fsl/imx8/BoardConfigCommon.mk
ifeq ($(PREBUILT_FSL_IMX_CODEC),true)
-include $(FSL_CODEC_PATH)/fsl-codec/fsl-codec.mk
endif
# sabreauto_6dq default target for EXT4
BUILD_TARGET_FS ?= ext4
include device/fsl/imx8/imx8_target_fs.mk

ifneq ($(BUILD_TARGET_FS),f2fs)
TARGET_RECOVERY_FSTAB = device/variscite/dart_mx8m/fstab.freescale
# build for ext4
PRODUCT_COPY_FILES +=	\
	device/variscite/dart_mx8m/fstab.freescale:root/fstab.freescale
else
TARGET_RECOVERY_FSTAB = device/variscite/dart_mx8m/fstab-f2fs.freescale
# build for f2fs
PRODUCT_COPY_FILES +=	\
	device/variscite/dart_mx8m/fstab-f2fs.freescale:root/fstab.freescale
endif # BUILD_TARGET_FS

# Support gpt
BOARD_BPT_INPUT_FILES += device/fsl/common/partition/device-partitions-13GB-ab.bpt
ADDITION_BPT_PARTITION = partition-table-7GB:device/fsl/common/partition/device-partitions-7GB-ab.bpt \
                         partition-table-28GB:device/fsl/common/partition/device-partitions-28GB-ab.bpt


# Vendor Interface manifest and compatibility
DEVICE_MANIFEST_FILE := device/variscite/dart_mx8m/manifest.xml
DEVICE_MATRIX_FILE := device/variscite/dart_mx8m/compatibility_matrix.xml

TARGET_BOOTLOADER_BOARD_NAME := EVK

PRODUCT_MODEL := dart_mx8m

TARGET_BOOTLOADER_POSTFIX := bin

USE_OPENGL_RENDERER := true
TARGET_CPU_SMP := true

TARGET_RELEASETOOLS_EXTENSIONS := device/fsl/imx8

BOARD_WLAN_DEVICE            := bcmdhd
WPA_SUPPLICANT_VERSION       := VER_0_8_X
BOARD_WPA_SUPPLICANT_DRIVER  := NL80211
BOARD_HOSTAPD_DRIVER         := NL80211

BOARD_HOSTAPD_PRIVATE_LIB               := lib_driver_cmd_$(BOARD_WLAN_DEVICE)
BOARD_WPA_SUPPLICANT_PRIVATE_LIB        := lib_driver_cmd_$(BOARD_WLAN_DEVICE)

# Broadcom BT
BOARD_BLUETOOTH_BDROID_BUILDCFG_INCLUDE_DIR := device/variscite/dart_mx8m/bluetooth
BOARD_CUSTOM_BT_CONFIG := $(BOARD_BLUETOOTH_BDROID_BUILDCFG_INCLUDE_DIR)/vnd_config.txt
BOARD_HAVE_BLUETOOTH_BCM := true
PRODUCT_COPY_FILES += \
       device/variscite/dart_mx8m/bluetooth/bt_vendor.conf:system/etc/bluetooth/bt_vendor.conf

BOARD_VENDOR_KERNEL_MODULES += \
                            $(KERNEL_OUT)/drivers/net/ethernet/freescale/fec.ko \
                            $(KERNEL_OUT)/drivers/net/wireless/broadcom/brcm80211/brcmutil/brcmutil.ko \
                            $(KERNEL_OUT)/drivers/net/wireless/broadcom/brcm80211/brcmfmac/brcmfmac.ko

PRODUCT_COPY_FILES += \
       device/variscite/dart_mx8m/init.brcm.wifibt.sh:vendor/bin/init.brcm.wifibt.sh

# parameters for frameworks/opt/net/wifi/libwifi_hal/wifi_hal_common.cpp
#WIFI_DRIVER_MODULE_NAME := brcmfmac
#WIFI_DRIVER_MODULE_PATH := /vendor/lib/modules/brcmfmac.ko

#BOARD_USE_SENSOR_FUSION := true

# for recovery service
TARGET_SELECT_KEY := 28
# we don't support sparse image.
TARGET_USERIMAGES_SPARSE_EXT_DISABLED := false

UBOOT_POST_PROCESS := true

# camera hal v3
IMX_CAMERA_HAL_V3 := true

BOARD_HAVE_USB_CAMERA := true

USE_ION_ALLOCATOR := true
USE_GPU_ALLOCATOR := false

# define frame buffer count
NUM_FRAMEBUFFER_SURFACE_BUFFERS := 5

ifeq ($(PRODUCT_IMX_DRM),true)
CMASIZE=736M
else
CMASIZE=1536M
endif

BOARD_KERNEL_CMDLINE := console=ttymxc0,115200 earlycon=imxuart,0x30860000,115200 init=/init video=HDMI-A-1:1920x1080-32@60 androidboot.console=ttymxc0 consoleblank=0 androidboot.hardware=freescale androidboot.fbTileSupport=enable cma=$(CMASIZE) androidboot.primary_display=imx-drm firmware_class.path=/vendor/firmware

ifeq ($(TARGET_USERIMAGES_USE_UBIFS),true)
ifeq ($(TARGET_USERIMAGES_USE_EXT4),true)
$(error "TARGET_USERIMAGES_USE_UBIFS and TARGET_USERIMAGES_USE_EXT4 config open in same time, please only choose one target file system image")
endif
endif

TARGET_BOARD_DTS_CONFIG := \
		imx8m-var-dart-emmc-wifi-dcss-lvds:imx8m-var-dart-emmc-wifi-dcss-lvds.dtb \
		imx8m-var-dart-emmc-wifi-hdmi:imx8m-var-dart-emmc-wifi-hdmi.dtb \
		imx8m-var-dart-sd-emmc-dcss-lvds:imx8m-var-dart-sd-emmc-dcss-lvds.dtb \
		imx8m-var-dart-sd-emmc-hdmi:imx8m-var-dart-sd-emmc-hdmi.dtb

TARGET_BOOTLOADER_CONFIG := imx8m-var-dart:imx8m_var_dart_android_defconfig

BOARD_SEPOLICY_DIRS := \
       device/fsl/imx8/sepolicy \
       device/variscite/dart_mx8m/sepolicy

ifeq ($(PRODUCT_IMX_DRM),true)
BOARD_SEPOLICY_DIRS += \
       device/fsl/imx8/sepolicy_drm \
       device/variscite/dart_mx8m/sepolicy_drm
endif

PRODUCT_COPY_FILES +=	\
       device/variscite/dart_mx8m/ueventd.freescale.rc:root/ueventd.freescale.rc

BOARD_AVB_ENABLE := true

# Vendor seccomp policy files for media components:
PRODUCT_COPY_FILES += \
       device/variscite/dart_mx8m/seccomp/mediacodec-seccomp.policy:vendor/etc/seccomp_policy/mediacodec.policy \
       device/variscite/dart_mx8m/seccomp/mediaextractor-seccomp.policy:vendor/etc/seccomp_policy/mediaextractor.policy

PRODUCT_COPY_FILES += \
       device/variscite/dart_mx8m/app_whitelist.xml:system/etc/sysconfig/app_whitelist.xml

TARGET_BOARD_KERNEL_HEADERS := device/fsl/common/kernel-headers
