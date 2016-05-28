#
# Product-specific compile-time definitions.
# Variscite VAR-MX6
#

TARGET_BOARD_PLATFORM := imx6
TARGET_CPU_ABI := armeabi-v7a
TARGET_CPU_ABI2 := armeabi
TARGET_ARCH := arm
TARGET_ARCH_VARIANT := armv7-a-neon
TARGET_CPU_VARIANT := cortex-a9
ARCH_ARM_HAVE_TLS_REGISTER := true

TARGET_NO_BOOTLOADER := true
TARGET_NO_KERNEL := false
TARGET_NO_RECOVERY := false
TARGET_NO_RADIOIMAGE := true

TARGET_PROVIDES_INIT_RC := true

BOARD_SOC_CLASS := IMX6

#BOARD_USES_GENERIC_AUDIO := true
BOARD_USES_ALSA_AUDIO := true
BUILD_WITH_ALSA_UTILS := true
BOARD_HAVE_BLUETOOTH := true
BOARD_HAVE_BLUETOOTH_TI := true
USE_CAMERA_STUB := false
BOARD_CAMERA_LIBRARIES := libcamera

BOARD_HAVE_WIFI := true

BOARD_NOT_HAVE_MODEM := true

BOARD_HAVE_IMX_CAMERA := true
BOARD_HAVE_USB_CAMERA := false

BUILD_WITHOUT_FSL_DIRECTRENDER := false
BUILD_WITHOUT_FSL_XEC := true

TARGET_USERIMAGES_BLOCKS := 204800

BUILD_WITH_GST := false

# Enable dex-preoptimization to speed up first boot sequence
ifeq ($(HOST_OS),linux)
   ifeq ($(TARGET_BUILD_VARIANT),user)
	ifeq ($(WITH_DEXPREOPT),)
	    WITH_DEXPREOPT := true
	endif
   endif
endif
# for ums config, only export one partion instead of the whole disk
UMS_ONEPARTITION_PER_DISK := true

PREBUILT_FSL_IMX_CODEC := true
PREBUILT_FSL_IMX_GPU := true
PREBUILT_FSL_WFDSINK := true
PREBUILT_FSL_HWCOMPOSER := true

# override some prebuilt setting if DISABLE_FSL_PREBUILT is define
ifeq ($(DISABLE_FSL_PREBUILT),GPU)
PREBUILT_FSL_IMX_GPU := false
else ifeq ($(DISABLE_FSL_PREBUILT),WFD)
PREBUILT_FSL_WFDSINK := false
else ifeq ($(DISABLE_FSL_PREBUILT),HWC)
PREBUILT_FSL_HWCOMPOSER := false
else ifeq ($(DISABLE_FSL_PREBUILT),ALL)
PREBUILT_FSL_IMX_GPU := false
PREBUILT_FSL_WFDSINK := false
PREBUILT_FSL_HWCOMPOSER := false
endif

# use non-neon memory copy on mx6x to get better performance
ARCH_ARM_USE_NON_NEON_MEMCPY := true

# for kernel/user space split
# comment out for 1g/3g space split
# TARGET_KERNEL_2G := true

BOARD_BOOTIMAGE_PARTITION_SIZE := 16777216
BOARD_RECOVERYIMAGE_PARTITION_SIZE := 16777216

# 400M
BOARD_SYSTEMIMAGE_PARTITION_SIZE := 419430400
BOARD_CACHEIMAGE_PARTITION_SIZE := 444596224
BOARD_FLASH_BLOCK_SIZE := 4096
TARGET_RECOVERY_UI_LIB := librecovery_ui_imx_v

# Freescale multimedia parser related prop setting
# Define fsl avi/aac/asf/mkv/flv/flac format support
ADDITIONAL_BUILD_PROPERTIES += \
    ro.FSL_AVI_PARSER=1 \
    ro.FSL_AAC_PARSER=1 \
    ro.FSL_ASF_PARSER=0 \
    ro.FSL_FLV_PARSER=1 \
    ro.FSL_MKV_PARSER=1 \
    ro.FSL_FLAC_PARSER=1 \
    ro.FSL_MPG2_PARSER=1 \
    ro.FSL_REAL_PARSER=0 \

-include device/google/gapps/gapps_config.mk
