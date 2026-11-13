# from BoardConfig.mk
TARGET_BOOTLOADER_POSTFIX := bin
UBOOT_POST_PROCESS := true

# u-boot target
TARGET_BOOTLOADER_CONFIG := imx95-var-dart:imx95_var_dart_android_defconfig
TARGET_BOOTLOADER_CONFIG += imx95-var-dart-dual:imx95_var_dart_android_dual_defconfig
TARGET_BOOTLOADER_CONFIG += imx95-var-dart-rpmsg-dual:imx95_var_dart_android_rpmsg_defconfig
TARGET_BOOTLOADER_CONFIG += imx95-var-dart-uuu:imx95_var_dart_android_uuu_defconfig

ifeq ($(PRODUCT_IMX_TRUSTY),true)
TARGET_BOOTLOADER_CONFIG += imx95-var-dart-trusty-dual:imx95_var_dart_android_trusty_dual_defconfig
TARGET_BOOTLOADER_CONFIG += imx95-var-dart-trusty-secure-unlock-dual:imx95_var_dart_android_trusty_secure_unlock_dual_defconfig
endif

# DART-MX95 LPDDR5 size in GB: 2, 4, 8 or 16. It selects the OEI DDR timing
# built by AndroidUboot.sh. TARGET_DDR_CONFIG overrides it, e.g.
# lpddr5_8gb_4266mbps_train_timing for DART-MX95 V2 with 8 GB at 4266 MT/s.
TARGET_DRAM_SIZE_GB ?= 8
TARGET_DDR_CONFIG ?= lpddr5_$(TARGET_DRAM_SIZE_GB)gb_6400mbps_train_timing
export TARGET_DDR_CONFIG

TARGET_KERNEL_DEFCONFIG := gki_defconfig
ifeq ($(LOADABLE_KERNEL_MODULE),true)
TARGET_KERNEL_GKI_DEFCONF:= imx95_gki.fragment
else
TARGET_KERNEL_GKI_DEFCONF:= imx_v8_android_defconfig
endif

# absolute path is used, not the same as relative path used in AOSP make
TARGET_DEVICE_DIR := $(patsubst %/, %, $(dir $(realpath $(lastword $(MAKEFILE_LIST)))))

# define bootloader rollback index
BOOTLOADER_RBINDEX ?= 0
