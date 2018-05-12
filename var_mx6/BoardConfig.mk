#
# Product-specific compile-time definitions.
#
include device/variscite/imx6/soc/imx6dq.mk
include device/variscite/var_mx6/build_id.mk
include device/variscite/imx6/BoardConfigCommon.mk
ifeq ($(PREBUILT_FSL_IMX_CODEC),true)
-include $(FSL_CODEC_PATH)/fsl-codec/fsl-codec.mk
endif

# var_mx6 default target for EXT4
BUILD_TARGET_FS ?= ext4
include device/variscite/imx6/imx6_target_fs.mk

ifneq ($(BUILD_TARGET_FS),f2fs)
# build for ext4
ifeq ($(PRODUCT_IMX_CAR),true)
TARGET_RECOVERY_FSTAB = device/variscite/var_mx6/fstab.freescale.car
PRODUCT_COPY_FILES +=	\
	device/variscite/var_mx6/fstab.freescale.car:root/fstab.freescale
else
TARGET_RECOVERY_FSTAB = device/variscite/var_mx6/fstab.freescale
PRODUCT_COPY_FILES +=	\
	device/variscite/var_mx6/fstab.freescale:root/fstab.freescale \
	device/variscite/var_mx6/fstab.freescale:root/fstab.var-som-mx6 \
	device/variscite/var_mx6/fstab.freescale:root/fstab.var-dart-mx6
endif # PRODUCT_IMX_CAR
else
TARGET_RECOVERY_FSTAB = device/variscite/var_mx6/fstab-f2fs.freescale
# build for f2fs
PRODUCT_COPY_FILES +=	\
	device/variscite/var_mx6/fstab-f2fs.freescale:root/fstab.freescale \
	device/variscite/var_mx6/fstab-f2fs.freescale:root/fstab.var-som-mx6
endif # BUILD_TARGET_FS

# Vendor Interface Manifest
ifeq ($(PRODUCT_IMX_CAR),true)
PRODUCT_COPY_FILES += \
    device/variscite/var_mx6/manifest_car.xml:vendor/manifest.xml
else
PRODUCT_COPY_FILES += \
    device/variscite/var_mx6/manifest.xml:vendor/manifest.xml
endif

TARGET_BOOTLOADER_BOARD_NAME := VAR_MX6
PRODUCT_MODEL := VAR_SOM_MX6

TARGET_BOOTLOADER_POSTFIX := img

#TARGET_DTB_POSTFIX := -dtb

TARGET_RELEASETOOLS_EXTENSIONS := device/variscite/imx6

# TI WILINK WIFI
USES_TI_MAC80211 := true
ifeq ($(USES_TI_MAC80211),true)
WPA_SUPPLICANT_VERSION       := VER_0_8_X

BOARD_WLAN_DEVICE            := wl12xx_mac80211
BOARD_WPA_SUPPLICANT_DRIVER  := NL80211
BOARD_WPA_SUPPLICANT_PRIVATE_LIB        := lib_driver_cmd_wl12xx

BOARD_SOFTAP_DEVICE          := wl12xx_mac80211
BOARD_HOSTAPD_DRIVER         := NL80211
BOARD_HOSTAPD_PRIVATE_LIB    := lib_driver_cmd_wl12xx
endif

#for accelerator sensor, need to define sensor type here
BOARD_HAS_SENSOR := false

# for recovery service (KEY_BACK)
TARGET_SELECT_KEY := 158

# we don't support sparse image.
TARGET_USERIMAGES_SPARSE_EXT_DISABLED := false
# uncomment below lins if use NAND
#TARGET_USERIMAGES_USE_UBIFS = true


ifeq ($(TARGET_USERIMAGES_USE_UBIFS),true)
UBI_ROOT_INI := device/variscite/var_mx6/ubi/ubinize.ini
TARGET_MKUBIFS_ARGS := -m 4096 -e 516096 -c 4096 -x none
TARGET_UBIRAW_ARGS := -m 4096 -p 512KiB $(UBI_ROOT_INI)
endif

ifeq ($(TARGET_USERIMAGES_USE_UBIFS),true)
ifeq ($(TARGET_USERIMAGES_USE_EXT4),true)
$(error "TARGET_USERIMAGES_USE_UBIFS and TARGET_USERIMAGES_USE_EXT4 config open in same time, please only choose one target file system image")
endif
endif

BOARD_KERNEL_CMDLINE := console=ttymxc0,115200 init=/init video=mxcfb0:dev=ldb,fbpix=RGB32,bpp=32 video=mxcfb1:off video=mxcfb2:off video=mxcfb3:off vmalloc=128M androidboot.console=ttymxc0 consoleblank=0 androidboot.hardware=freescale cma=448M galcore.contiguousSize=33554432

ifeq ($(TARGET_USERIMAGES_USE_UBIFS),true)
#UBI boot command line.
# Note: this NAND partition table must align with MFGTool's config.
BOARD_KERNEL_CMDLINE +=  mtdparts=gpmi-nand:16m(bootloader),16m(bootimg),128m(recovery),-(root) gpmi_debug_init ubi.mtd=3
endif


# WL12xx/WL18xx BT
BOARD_HAVE_BLUETOOTH_TI := true
BOARD_BLUETOOTH_BDROID_BUILDCFG_INCLUDE_DIR := device/variscite/var_mx6/bluetooth

USE_ION_ALLOCATOR := true
USE_GPU_ALLOCATOR := false

# define frame buffer count
NUM_FRAMEBUFFER_SURFACE_BUFFERS := 3

PHONE_MODULE_INCLUDE := true
# camera hal v3
IMX_CAMERA_HAL_V3 := true


#define consumer IR HAL support
IMX6_CONSUMER_IR_HAL := false

TARGET_KERNEL_DEFCONF := imx_v7_var_android_defconfig

TARGET_BOOTLOADER_CONFIG := var-imx6-sd:mx6var_som_sd_android_config var-imx6-nand:mx6var_som_nand_android_config
TARGET_BOARD_DTS_CONFIG := som-mx6q-r:imx6q-var-som-res.dtb som-mx6q-vsc:imx6q-var-som-vsc.dtb som-mx6dl-r:imx6dl-var-som-res.dtb som-solo-r:imx6dl-var-som-solo-res.dtb som-solo-vsc:imx6dl-var-som-solo-vsc.dtb imx6q-var-dart:imx6q-var-dart.dtb som-mx6q-c:imx6q-var-som-cap.dtb som-mx6dl-c:imx6dl-var-som-cap.dtb som-solo-c:imx6dl-var-som-solo-cap.dtb som-mx6qp-c:imx6qp-var-som-cap.dtb som-mx6qp-r:imx6qp-var-som-res.dtb som-mx6qp-vsc:imx6qp-var-som-vsc.dtb

BOARD_SEPOLICY_DIRS := \
       device/variscite/imx6/sepolicy \
       device/variscite/var_mx6/sepolicy

ifeq ($(PRODUCT_IMX_CAR),true)
BOARD_SEPOLICY_DIRS += \
     packages/services/Car/car_product/sepolicy \
     device/generic/car/common/sepolicy
endif

PRODUCT_COPY_FILES +=	\
       device/variscite/var_mx6/ueventd.freescale.rc:root/ueventd.freescale.rc \
       device/variscite/var_mx6/ueventd.freescale.rc:root/ueventd.var-som-mx6.rc \
       device/variscite/var_mx6/ueventd.freescale.rc:root/ueventd.var-dart-mx6.rc \


# Vendor seccomp policy files for media components:
PRODUCT_COPY_FILES += \
       device/variscite/var_mx6/seccomp/mediacodec-seccomp.policy:vendor/etc/seccomp_policy/mediacodec.policy \
       device/variscite/var_mx6/seccomp/mediaextractor-seccomp.policy:vendor/etc/seccomp_policy/mediaextractor.policy

PRODUCT_COPY_FILES += \
       device/variscite/var_mx6/app_whitelist.xml:system/etc/sysconfig/app_whitelist.xml

TARGET_BOARD_KERNEL_HEADERS := device/variscite/common/kernel-headers
