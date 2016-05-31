#
# Copyright 2016 The Android Open Source Project
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

# BCM4343 WIFI Firmware
BCM4343_BT_SRC := device/variscite/vardart6ul/bcm4343/bluetooth
BCM4343_BT_FIRMWARE := device/variscite/vardart6ul/bcm4343/bcm_4343w_fw
BCM4343_BT_FW_DST := system/vendor/firmware/bcm4343

ifeq ($(BCM4343_BT_FIRMWARE), $(wildcard $(BCM4343_BT_FIRMWARE)))
PRODUCT_COPY_FILES += \
    $(BCM4343_BT_FIRMWARE)/bcm43430a1.hcd:$(BCM4343_BT_FW_DST)/bcm43430a1.hcd
else
    $(warning "Not found bcm4343 BT firmware.")
endif

PRODUCT_COPY_FILES += \
    $(BCM4343_BT_SRC)/bt_vendor.conf:system/etc/bluetooth/bt_vendor.conf

# BCM Bluetooth
BOARD_HAVE_BLUETOOTH_BCM := true
BOARD_CUSTOM_BT_CONFIG := $(BCM4343_BT_SRC)/vnd_vardart6ul.txt

DEVICE_PACKAGES += \
    bt_bcm_bcm4343.imx
