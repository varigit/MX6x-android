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

# Targets for builing kernels
# The following must be set before including this file.
# TARGET_KERNEL_SRC must be set the base of a kernel tree.
# TARGET_KERNEL_DEFCONFIG must name a base kernel config.
# TARGET_KERNEL_ARCH must be set to match kernel arch.

# The following maybe set.
# TARGET_KERNEL_CROSS_COMPILE_PREFIX to override toolchain
# TARGET_PREBUILT_KERNEL to use a pre-built kernel

# Only build kernel if caller has not defined a prebuild
ifeq ($(TARGET_PREBUILT_KERNEL),)

ifeq ($(TARGET_KERNEL_SRC),)
$(error TARGET_KERNEL_SRC not defined)
endif

ifeq ($(TARGET_KERNEL_DEFCONFIG),)
$(error TARGET_KERNEL_DEFCONFIG not defined)
endif

ifeq ($(TARGET_KERNEL_ARCH),)
$(error TARGET_KERNEL_ARCH not defined)
endif

# Check target arch.
KERNEL_TOOLCHAIN_ABS := $(shell readlink -f $(TARGET_TOOLCHAIN_ROOT)/bin)
TARGET_KERNEL_ARCH := $(strip $(TARGET_KERNEL_ARCH))
KERNEL_ARCH := $(TARGET_KERNEL_ARCH)
HOST_PROCESSOR := $(shell cat /proc/cpuinfo | grep processor | wc -l)

ifeq ($(TARGET_KERNEL_ARCH), arm)
KERNEL_CROSS_COMPILE := $(KERNEL_TOOLCHAIN_ABS)/arm-linux-androideabi-
ifdef TARGET_KERNEL_DTB
KERNEL_NAME := zImage
else
KERNEL_NAME := zImage-dtb
endif
else ifeq ($(TARGET_KERNEL_ARCH), arm64)
KERNEL_CROSS_COMPILE := $(KERNEL_TOOLCHAIN_ABS)/aarch64-linux-android-
KERNEL_NAME := Image
else
$(error kernel arch not supported at present)
endif

# Allow caller to override toolchain.
TARGET_KERNEL_CROSS_COMPILE_PREFIX := $(strip $(TARGET_KERNEL_CROSS_COMPILE_PREFIX))
ifneq ($(TARGET_KERNEL_CROSS_COMPILE_PREFIX),)
KERNEL_CROSS_COMPILE := $(TARGET_KERNEL_CROSS_COMPILE_PREFIX)
endif

KERNEL_GCC_NOANDROID_CHK := $(shell (echo "int main() {return 0;}" | $(KERNEL_CROSS_COMPILE)gcc -E -mno-android - > /dev/null 2>&1 ; echo $$?))
ifeq ($(strip $(KERNEL_GCC_NOANDROID_CHK)),0)
KERNEL_CFLAGS := KCFLAGS=-mno-android
endif

ifeq ($(TARGET_KERNEL_DTB),)
$(error TARGET_KERNEL_DTB not defined)
endif

# Set the output for the kernel build products.
KERNEL_OUT := $(TARGET_OUT_INTERMEDIATES)/KERNEL_OBJ

KERNEL_CONFIG := $(KERNEL_OUT)/.config

KERNEL_BIN := $(KERNEL_OUT)/arch/$(KERNEL_ARCH)/boot/$(KERNEL_NAME)

KERNEL_MERGE_CONFIG := device/generic/brillo/mergeconfig.sh

KERNEL_ZIMAGE := $(TARGET_KERNEL_SRC)/arch/$(KERNEL_ARCH)/boot/zImage
KERNEL_DTB_FILE := $(TARGET_KERNEL_SRC)/arch/$(KERNEL_ARCH)/boot/dts/$(TARGET_KERNEL_DTB)
BOARD_MKBOOTIMG_ARGS += --second $(PRODUCT_OUT)/$(TARGET_KERNEL_DTB)

$(KERNEL_OUT):
	mkdir -p $(KERNEL_OUT)

# Build the kernel config
#$(KERNEL_CONFIG): $(KERNEL_OUT)
#	$(KERNEL_MERGE_CONFIG) $(TARGET_KERNEL_SRC) `readlink -f $(KERNEL_OUT)` $(KERNEL_ARCH) $(KERNEL_CROSS_COMPILE) arch/$(KERNEL_ARCH)/configs/$(TARGET_KERNEL_DEFCONFIG) $(TARGET_KERNEL_CONFIGS)

KERNEL_ENV := ARCH=$(KERNEL_ARCH) CROSS_COMPILE=$(KERNEL_CROSS_COMPILE) $(KERNEL_CFLAGS)

.PHONY: kernelimage
kernelimage:
	$(hide) echo " Building kernel... "
	$(hide) rm -rf $(KERNEL_OUT)/arch/$(KERNEL_ARCH)/boot/dts
	$(MAKE) $(TARGET_KERNEL_DEFCONFIG) -C $(TARGET_KERNEL_SRC) $(KERNEL_ENV)
	$(MAKE) -j$(HOST_PROCESSOR) -C $(TARGET_KERNEL_SRC)  $(KERNEL_ENV)

$(PRODUCT_OUT)/kernel: kernelimage
	install -D $(KERNEL_ZIMAGE)  $(PRODUCT_OUT)/kernel
	install -D $(KERNEL_DTB_FILE) $(PRODUCT_OUT)/$(TARGET_KERNEL_DTB)

endif

