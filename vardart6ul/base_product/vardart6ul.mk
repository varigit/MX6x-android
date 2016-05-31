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

$(call inherit-product, device/generic/brillo/brillo_base.mk)

# Set soc_name
soc_name := imx6ul

# Add wifi controlller
#$(call add_peripheral, variscite, wifi/bcm4343)

PRODUCT_NAME := vardart6ul
PRODUCT_BRAND := Brillo
PRODUCT_DEVICE := vardart6ul

# Call vendor's peripheral mk.
include device/variscite/vardart6ul/bcm4343/wifi/peripheral.mk
include device/variscite/vardart6ul/bcm4343/bluetooth/peripheral.mk

PRODUCT_PACKAGES += keystore.default
PRODUCT_PACKAGES += bootctrl.imx6ul
PRODUCT_PACKAGES += audio.primary.imx6ul
PRODUCT_PACKAGES += lights.imx6ul
PRODUCT_PACKAGES += bt_bcm_bcm4343.imx

# audio effect lib
PRODUCT_PACKAGES += libbundlewrapper
PRODUCT_PACKAGES += libdownmix
PRODUCT_PACKAGES += libeffectproxy
PRODUCT_PACKAGES += libldnhncr
PRODUCT_PACKAGES += libreverbwrapper
PRODUCT_PACKAGES += libvisualizer

# Install SabreSD-specific config file for weaved.
PRODUCT_COPY_FILES += \
  device/variscite/vardart6ul/base_product/weaved.conf:system/etc/weaved/weaved.conf

PRODUCT_COPY_FILES += \
  device/variscite/vardart6ul/fstab.device:root/fstab.device \
  device/variscite/vardart6ul/provision-device:provision-device \
  device/variscite/vardart6ul/base_product/media_codecs.xml:system/etc/media_codecs.xml \
  device/variscite/vardart6ul/base_product/media_codecs_google_audio.xml:system/etc/media_codecs_google_audio.xml \
  device/variscite/vardart6ul/base_product/media_codecs_google_video.xml:system/etc/media_codecs_google_video.xml \
  device/variscite/vardart6ul/base_product/audio_effects.conf:system/etc/audio_effects.conf

PRODUCT_COPY_FILES += \
  system/core/rootdir/init.usb.rc:root/init.usb.rc \
  system/core/rootdir/ueventd.rc:root/ueventd.rc \
  device/variscite/vardart6ul/init.freescale.rc:root/init.freescale.rc \
  device/variscite/vardart6ul/init.freescale.usb.rc:root/init.freescale.usb.rc \
  device/variscite/vardart6ul/ueventd.freescale.rc:root/ueventd.freescale.rc \

# Lights HAL package.
DEVICE_PACKAGES += \
  lights.$(soc_name)

# WiFi HAL package.
DEVICE_PACKAGES += \
  wifi_driver.$(soc_name)
