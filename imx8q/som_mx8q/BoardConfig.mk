#
# Product-specific compile-time definitions.
#

IMX_DEVICE_PATH := device/variscite/imx8q/som_mx8q

include device/fsl/imx8q/BoardConfigCommon.mk

BUILD_TARGET_FS ?= ext4
TARGET_USERIMAGES_USE_EXT4 := true

TARGET_RECOVERY_FSTAB = $(IMX_DEVICE_PATH)/fstab.freescale

# Support gpt
ifeq ($(TARGET_USE_DYNAMIC_PARTITIONS),true)
    BOARD_BPT_INPUT_FILES += device/fsl/common/partition/device-partitions-13GB-ab_super.bpt
    ADDITION_BPT_PARTITION = partition-table-28GB:device/fsl/common/partition/device-partitions-28GB-ab_super.bpt
  else
    ifeq ($(IMX_NO_PRODUCT_PARTITION),true)
      BOARD_BPT_INPUT_FILES += device/fsl/common/partition/device-partitions-13GB-ab-no-product.bpt
      ADDITION_BPT_PARTITION = partition-table-28GB:device/fsl/common/partition/device-partitions-28GB-ab-no-product.bpt
    else
      BOARD_BPT_INPUT_FILES += device/fsl/common/partition/device-partitions-13GB-ab.bpt
      ADDITION_BPT_PARTITION = partition-table-28GB:device/fsl/common/partition/device-partitions-28GB-ab.bpt
    endif
endif

# sensor configs
#BOARD_USE_SENSOR_FUSION := true
#BOARD_USE_SENSOR_PEDOMETER := false
#ifeq ($(PRODUCT_IMX_CAR),true)
#    BOARD_USE_LEGACY_SENSOR := false
#else
#    BOARD_USE_LEGACY_SENSOR :=true
#endif

# Vendor Interface manifest and compatibility
DEVICE_MANIFEST_FILE := $(IMX_DEVICE_PATH)/manifest.xml
DEVICE_MATRIX_FILE := $(IMX_DEVICE_PATH)/compatibility_matrix.xml

TARGET_BOOTLOADER_BOARD_NAME := MEK

USE_OPENGL_RENDERER := true
TARGET_CPU_SMP := true

BOARD_WLAN_DEVICE            := bcmdhd
WPA_SUPPLICANT_VERSION       := VER_0_8_X
BOARD_WPA_SUPPLICANT_DRIVER  := NL80211
BOARD_HOSTAPD_DRIVER         := NL80211

BOARD_HOSTAPD_PRIVATE_LIB               := lib_driver_cmd_$(BOARD_WLAN_DEVICE)
BOARD_WPA_SUPPLICANT_PRIVATE_LIB        := lib_driver_cmd_$(BOARD_WLAN_DEVICE)


# we don't support sparse image.
TARGET_USERIMAGES_SPARSE_EXT_DISABLED := false

BOARD_HAVE_USB_CAMERA := true
BOARD_HAVE_USB_MJPEG_CAMERA := false

USE_ION_ALLOCATOR := true
USE_GPU_ALLOCATOR := false

# define frame buffer count
NUM_FRAMEBUFFER_SURFACE_BUFFERS := 3

ifeq ($(TARGET_USERIMAGES_USE_UBIFS),true)
ifeq ($(TARGET_USERIMAGES_USE_EXT4),true)
$(error "TARGET_USERIMAGES_USE_UBIFS and TARGET_USERIMAGES_USE_EXT4 config open in same time, please only choose one target file system image")
endif
endif

BOARD_SEPOLICY_DIRS := \
       device/fsl/imx8q/sepolicy \
       $(IMX_DEVICE_PATH)/sepolicy

BOARD_AVB_ENABLE := true

BOARD_AVB_ALGORITHM := SHA256_RSA4096
# The testkey_rsa4096.pem is copied from external/avb/test/data/testkey_rsa4096.pem
BOARD_AVB_KEY_PATH := device/fsl/common/security/testkey_rsa4096.pem

TARGET_USES_MKE2FS := true

TARGET_BOARD_KERNEL_HEADERS := device/fsl/common/kernel-headers

# define board type
BOARD_TYPE := MEK

ALL_DEFAULT_INSTALLED_MODULES += $(BOARD_VENDOR_KERNEL_MODULES)

BOARD_USES_METADATA_PARTITION := true
BOARD_ROOT_EXTRA_FOLDERS += metadata
