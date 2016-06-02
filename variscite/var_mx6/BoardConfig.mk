#
# Product-specific compile-time definitions.
# Variscite VAR-SOM-MX6
#

include device/variscite/imx6/soc/imx6dq.mk
include device/variscite/var_mx6/build_id.mk
include device/variscite/imx6/BoardConfigCommon.mk
include device/fsl-proprietary/gpu-viv/fsl-gpu.mk

# var-som-mx6 default target for EXT4
BUILD_TARGET_FS ?= ext4
include device/variscite/imx6/imx6_target_fs.mk

ifeq ($(BUILD_TARGET_DEVICE),sd)
ADDITIONAL_BUILD_PROPERTIES += \
                        ro.boot.storage_type=sd
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
	device/variscite/var_mx6/fstab_sd-f2fs.freescale:root/fstab.freescale
endif # BUILD_TARGET_FS

else

ADDITIONAL_BUILD_PROPERTIES += \
                        ro.boot.storage_type=emmc
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
	device/variscite/var_mx6/fstab_emmc-f2fs.freescale:root/fstab.freescale

endif # BUILD_TARGET_FS
endif # BUILD_TARGET_DEVICE


BOOTLOADER_USES_SPL := true
TARGET_BOOTLOADER_BOARD_NAME := VAR_MX6
PRODUCT_MODEL := VAR_SOM_MX6

TARGET_RELEASETOOLS_EXTENSIONS := device/variscite/imx6

TARGET_KERNEL_MODULES := \
    hardware/ti/wlan/mac80211/compat_wl18xx/compat/compat.ko:system/lib/modules/compat.ko \
    hardware/ti/wlan/mac80211/compat_wl18xx/net/wireless/cfg80211.ko:system/lib/modules/cfg80211.ko \
    hardware/ti/wlan/mac80211/compat_wl18xx/net/mac80211/mac80211.ko:system/lib/modules/mac80211.ko \
    hardware/ti/wlan/mac80211/compat_wl18xx/drivers/net/wireless/ti/wl12xx/wl12xx.ko:system/lib/modules/wl12xx.ko \
    hardware/ti/wlan/mac80211/compat_wl18xx/drivers/net/wireless/ti/wl18xx/wl18xx.ko:system/lib/modules/wl18xx.ko \
    hardware/ti/wlan/mac80211/compat_wl18xx/drivers/net/wireless/ti/wlcore/wlcore.ko:system/lib/modules/wlcore.ko \
    hardware/ti/wlan/mac80211/compat_wl18xx/drivers/net/wireless/ti/wlcore/wlcore_sdio.ko:system/lib/modules/wlcore_sdio.ko

# TI WILINK WIFI
USES_TI_MAC80211 := true
ifeq ($(USES_TI_MAC80211),true)
WPA_SUPPLICANT_VERSION           := VER_0_8_X
BOARD_WPA_SUPPLICANT_DRIVER      := NL80211
BOARD_HOSTAPD_DRIVER             := NL80211
BOARD_WPA_SUPPLICANT_PRIVATE_LIB := lib_driver_cmd_wl12xx
BOARD_HOSTAPD_PRIVATE_LIB        := lib_driver_cmd_wl12xx
BOARD_WLAN_DEVICE                := wl12xx_mac80211
#BOARD_WLAN_DEVICE                := UNITE

BOARD_SOFTAP_DEVICE              := wl12xx_mac80211
COMMON_GLOBAL_CFLAGS             += -DUSES_TI_MAC80211
COMMON_GLOBAL_CFLAGS             += -DANDROID_P2P_STUB
WIFI_FIRMWARE_LOADER             := ""
endif

BOARD_MODEM_VENDOR :=

USE_ATHR_GPS_HARDWARE := false
USE_QEMU_GPS_HARDWARE := false

#for accelerator sensor, need to define sensor type here
BOARD_HAS_SENSOR := false
SENSOR_MMA8451 := false

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

BOARD_KERNEL_CMDLINE := console=ttymxc0,115200 init=/init video=mxcfb0:dev=ldb,bpp=32 video=mxcfb1:off video=mxcfb2:off video=mxcfb3:off vmalloc=256M androidboot.console=ttymxc0 consoleblank=0 androidboot.hardware=freescale cma=384M androidboot.selinux=disabled
#BOARD_KERNEL_CMDLINE := console=ttymxc0,115200 init=/init video=mxcfb0:dev=hdmi,1920x1080M@60,if=RGB24,bpp=32 video=mxcfb1:off video=mxcfb2:off video=mxcfb3:off vmalloc=256M androidboot.console=ttymxc0 consoleblank=0 androidboot.hardware=freescale cma=384M androidboot.selinux=disabled

ifeq ($(TARGET_USERIMAGES_USE_UBIFS),true)
#UBI boot command line.
# Note: this NAND partition table must align with MFGTool's config.
BOARD_KERNEL_CMDLINE +=  mtdparts=gpmi-nand:16m(bootloader),16m(bootimg),128m(recovery),-(root) gpmi_debug_init ubi.mtd=3
endif

# atheros 3k BT
BOARD_USE_AR3K_BLUETOOTH :=
# BOARD_BLUETOOTH_BDROID_BUILDCFG_INCLUDE_DIR := device/variscite/var_mx6/bluetooth

USE_ION_ALLOCATOR := false
USE_GPU_ALLOCATOR := true

# camera hal v3
IMX_CAMERA_HAL_V3 := true

#define consumer IR HAL support
IMX6_CONSUMER_IR_HAL := false

TARGET_BOOTLOADER_CONFIG := var-imx6-sd:mx6var_som_sd_android_config var-imx6-nand:mx6var_som_nand_android_config
TARGET_BOARD_DTS_CONFIG := som-mx6q-r:imx6q-var-som.dtb som-mx6q-vsc:imx6q-var-som-vsc.dtb som-mx6dl-r:imx6dl-var-som.dtb som-solo-r:imx6dl-var-som-solo.dtb som-solo-vsc:imx6dl-var-som-solo-vsc.dtb imx6q-var-dart:imx6q-var-dart.dtb som-mx6q-c:imx6q-var-som-cap.dtb som-mx6dl-c:imx6dl-var-som-cap.dtb som-solo-c:imx6dl-var-som-solo-cap.dtb

BOARD_SEPOLICY_DIRS := \
       device/variscite/imx6/sepolicy \
       device/variscite/var_mx6/sepolicy

