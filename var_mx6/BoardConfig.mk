#
# Product-specific compile-time definitions.
#

include device/fsl/imx6/soc/imx6dq.mk
include device/variscite/var_mx6/build_id.mk
include device/fsl/imx6/BoardConfigCommon.mk
# var_mx6 default target for EXT4
BUILD_TARGET_FS ?= ext4
include device/fsl/imx6/imx6_target_fs.mk

ifeq ($(BUILD_TARGET_DEVICE),sd)
ADDITIONAL_BUILD_PROPERTIES += \
                        ro.internel.storage_size=/sys/block/mmcblk1/size \
                        ro.boot.storage_type=sd \
                        ro.frp.pst=/dev/block/mmcblk1p12
ifneq ($(BUILD_TARGET_FS),f2fs)
TARGET_RECOVERY_FSTAB = device/variscite/var_mx6/fstab_sd.freescale
# build for ext4
PRODUCT_COPY_FILES +=	\
	device/variscite/var_mx6/fstab_sd.freescale:root/fstab.freescale \
	device/variscite/var_mx6/fstab_sd_dart.freescale:root/fstab_dart.freescale
else
TARGET_RECOVERY_FSTAB = device/variscite/var_mx6/fstab_sd-f2fs.freescale
# build for f2fs
PRODUCT_COPY_FILES +=	\
	device/variscite/var_mx6/fstab_sd-f2fs.freescale:root/fstab.freescale \
	device/variscite/var_mx6/fstab_sd_dart-f2fs.freescale:root/fstab_dart.freescale
endif # BUILD_TARGET_FS
else
ADDITIONAL_BUILD_PROPERTIES += \
                        ro.internel.storage_size=/sys/block/mmcblk0/size \
                        ro.boot.storage_type=emmc \
                        ro.frp.pst=/dev/block/mmcblk0p12
ifneq ($(BUILD_TARGET_FS),f2fs)
TARGET_RECOVERY_FSTAB = device/variscite/var_mx6/fstab_emmc.freescale
# build for ext4
PRODUCT_COPY_FILES +=	\
	device/variscite/var_mx6/fstab_emmc.freescale:root/fstab.freescale \
	device/variscite/var_mx6/fstab_emmc_dart.freescale:root/fstab_dart.freescale
else
TARGET_RECOVERY_FSTAB = device/variscite/var_mx6/fstab_emmc-f2fs.freescale
# build for f2fs
PRODUCT_COPY_FILES +=	\
	device/variscite/var_mx6/fstab_emmc-f2fs.freescale:root/fstab.freescale \
	device/variscite/var_mx6/fstab_emmc_dart-f2fs.freescale:root/fstab_dart.freescale
endif # BUILD_TARGET_FS
endif # BUILD_TARGET_DEVICE


TARGET_BOOTLOADER_BOARD_NAME := VAR_MX6
PRODUCT_MODEL := VAR_SOM_MX6

TARGET_BOOTLOADER_POSTFIX := img

TARGET_RELEASETOOLS_EXTENSIONS := device/fsl/imx6

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
DM_VERITY_RUNTIME_CONFIG := true
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

BOARD_KERNEL_CMDLINE := console=ttymxc0,115200 init=/init video=mxcfb0:dev=ldb,bpp=32 video=mxcfb1:off video=mxcfb2:off video=mxcfb3:off vmalloc=128M androidboot.console=ttymxc0 consoleblank=0 androidboot.hardware=freescale cma=448M

ifeq ($(TARGET_USERIMAGES_USE_UBIFS),true)
#UBI boot command line.
# Note: this NAND partition table must align with MFGTool's config.
BOARD_KERNEL_CMDLINE +=  mtdparts=gpmi-nand:16m(bootloader),16m(bootimg),128m(recovery),-(root) gpmi_debug_init ubi.mtd=3
endif


# WL12xx/WL18xx BT
BOARD_HAVE_BLUETOOTH_TI := true
BOARD_BLUETOOTH_BDROID_BUILDCFG_INCLUDE_DIR := device/variscite/var_mx6/bluetooth

USE_ION_ALLOCATOR := false
USE_GPU_ALLOCATOR := true

PHONE_MODULE_INCLUDE := true
# camera hal v3
IMX_CAMERA_HAL_V3 := true

#define consumer IR HAL support
IMX6_CONSUMER_IR_HAL := false

TARGET_KERNEL_DEFCONF := imx_v7_var_android_defconfig

TARGET_BOOTLOADER_CONFIG := var-imx6-sd:mx6var_som_sd_android_config var-imx6-nand:mx6var_som_nand_android_config
TARGET_BOARD_DTS_CONFIG := som-mx6q-r:imx6q-var-som-res.dtb som-mx6q-vsc:imx6q-var-som-vsc.dtb som-mx6dl-r:imx6dl-var-som-res.dtb som-solo-r:imx6dl-var-som-solo-res.dtb som-solo-vsc:imx6dl-var-som-solo-vsc.dtb imx6q-var-dart:imx6q-var-dart.dtb som-mx6q-c:imx6q-var-som-cap.dtb som-mx6dl-c:imx6dl-var-som-cap.dtb som-solo-c:imx6dl-var-som-solo-cap.dtb som-mx6qp-c:imx6qp-var-som-cap.dtb som-mx6qp-r:imx6qp-var-som-res.dtb som-mx6qp-vsc:imx6qp-var-som-vsc.dtb

BOARD_SEPOLICY_DIRS := \
       device/fsl/imx6/sepolicy \
       device/variscite/imx6/sepolicy

BOARD_SECCOMP_POLICY += device/variscite/var_mx6/seccomp

TARGET_BOARD_KERNEL_HEADERS := device/fsl/common/kernel-headers
