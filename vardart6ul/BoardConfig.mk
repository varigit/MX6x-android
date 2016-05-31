#
# Copyright 2015 The Android Open Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# ARM32 device.
TARGET_ARCH := arm
TARGET_ARCH_VARIANT := armv7-a
TARGET_CPU_VARIANT := generic
TARGET_CPU_ABI := armeabi-v7a
TARGET_CPU_ABI2 := armeabi
TARGET_KERNEL_ARCH := $(TARGET_ARCH)

TARGET_NO_BOOTLOADER := false
TARGET_NO_KERNEL := false
BOARD_KERNEL_BASE := 0x82800000

TARGET_USERIMAGES_USE_EXT4 := true
BOARD_CACHEIMAGE_FILE_SYSTEM_TYPE := ext4
BOARD_FLASH_BLOCK_SIZE := 131072

BOARD_SYSTEMIMAGE_PARTITION_SIZE := 67108864
BOARD_USERDATAIMAGE_PARTITION_SIZE := 134217728
BOARD_CACHEIMAGE_PARTITION_SIZE := 67108864
TARGET_BOOTLOADER_BOARD_NAME := vardart6ul

TARGET_KERNEL_DTB := imx6ul-var-dart-emmc_wifi.dtb
BOARD_KERNEL_CMDLINE := console=ttymxc0,115200 init=/init androidboot.console=ttymxc0 androidboot.hardware=freescale androidboot.slot_suffix=_a cma=96M

BOARD_SEPOLICY_DIRS += device/variscite/vardart6ul/sepolicy

# Set up the local kernel.
TARGET_KERNEL_SRC := hardware/bsp/kernel/variscite/kernel_imx
TARGET_KERNEL_DEFCONFIG := imx6ul-var-dart_android_defconfig
TARGET_KERNEL_CROSS_COMPILE_PREFIX := $(PWD)/prebuilts/gcc/linux-x86/arm/arm-linux-androideabi-4.9/bin/arm-linux-androideabi-

# WIFI
WIFI_DRIVER_HAL_MODULE := wifi_driver.$(soc_name)
WIFI_DRIVER_HAL_PERIPHERAL := bcm4343
