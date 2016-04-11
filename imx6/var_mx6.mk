# This is a FSL Android Reference Design platform based on i.MX6Q ARD board
# It will inherit from FSL core product which in turn inherit from Google generic

$(call inherit-product, device/variscite/imx6/imx6.mk)
$(call inherit-product-if-exists,vendor/google/products/gms.mk)

ifneq ($(wildcard device/variscite/var_mx6/fstab_nand.freescale),)
$(shell touch device/variscite/var_mx6/fstab_nand.freescale)
endif

ifneq ($(wildcard device/variscite/var_mx6/fstab.freescale),)
$(shell touch device/variscite/var_mx6/fstab.freescale)
endif

# Overrides
PRODUCT_NAME 	:= var_mx6
PRODUCT_DEVICE 	:= var_mx6
PRODUCT_BRAND 	:= variscite
PRODUCT_MANUFACTURER := variscite

PRODUCT_COPY_FILES += \
	device/variscite/var_mx6/init.rc:root/init.freescale.rc \
	device/variscite/var_mx6/audio_policy.conf:system/etc/audio_policy.conf \
	device/variscite/var_mx6/audio_effects.conf:system/vendor/etc/audio_effects.conf

PRODUCT_COPY_FILES +=	\
	external/linux-firmware-imx/firmware/vpu/vpu_fw_imx6d.bin:system/lib/firmware/vpu/vpu_fw_imx6d.bin 	\
	external/linux-firmware-imx/firmware/vpu/vpu_fw_imx6q.bin:system/lib/firmware/vpu/vpu_fw_imx6q.bin

PRODUCT_COPY_FILES +=	\
	device/fsl-proprietary/media-profile/media_profiles_1080p.xml:system/etc/media_profiles.xml \
	device/fsl-proprietary/media-profile/media_profiles_1080p.xml:system/etc/media_profiles_1080p.xml \
	device/fsl-proprietary/media-profile/media_profiles_720p.xml:system/etc/media_profiles_720p.xml

# setup dm-verity configs.
ifneq ($(BUILD_TARGET_DEVICE),sd)
 PRODUCT_SYSTEM_VERITY_PARTITION := /dev/block/mmcblk0p5
 $(call inherit-product, build/target/product/verity.mk)
else 
 PRODUCT_SYSTEM_VERITY_PARTITION := /dev/block/mmcblk1p5
 $(call inherit-product, build/target/product/verity.mk)

endif

# BT/WIFI Firmware
$(call inherit-product-if-exists, hardware/ti/wpan/ti-wpan-products.mk)
$(call inherit-product-if-exists, device/ti/proprietary-open/wl12xx/wlan/wl12xx-wlan-fw-products.mk)
$(call inherit-product-if-exists, device/ti/proprietary-open/wl12xx/wpan/wl12xx-wpan-fw-products.mk)

# PRODUCT_COPY_FILES += \
# 	external/wlconf/configure-device.sh:system/etc/wifi/wlconf/configure-device.sh \
# 	external/wpa_supplicant_8_ti/hostapd/hostapd.conf:system/etc/hostapd.conf

PRODUCT_PACKAGES += \
        bt_sco_app \
        BluetoothSCOApp

PRODUCT_PACKAGES += \
	libwpa_client \
	wifical.sh \
	crda \
	regulatory.bin \
	wlconf \
	struct.bin \
	dictionary.txt \
	wl18xx-conf-default.bin \
	example.conf \
	example.ini \
	iw

# CANbus tools
PRODUCT_PACKAGES += \
	candump \
	cansend \
	cangen \
	canfdtest \
	cangw \
	canplayer \
	cansniffer \
	isotprecv \
	isotpsend \
	isotpserver

# I2C tools
PRODUCT_PACKAGES += \
	i2c-tools \
	i2cdetect \
	i2cget \
	i2cset \
	i2cdump

PRODUCT_PACKAGES += \
	wl1271-fw-2.bin \
	wl1271-nvs.bin

PRODUCT_PACKAGES += \
	AudioRoute

# GPU files

DEVICE_PACKAGE_OVERLAYS := device/variscite/var_mx6/overlay

PRODUCT_CHARACTERISTICS := tablet

PRODUCT_AAPT_CONFIG += xlarge large tvdpi hdpi

PRODUCT_COPY_FILES += \
	frameworks/native/data/etc/tablet_core_hardware.xml:system/etc/permissions/tablet_core_hardware.xml \
	frameworks/native/data/etc/android.hardware.camera.xml:system/etc/permissions/android.hardware.camera.xml \
	frameworks/native/data/etc/android.hardware.camera.front.xml:system/etc/permissions/android.hardware.camera.front.xml \
	frameworks/native/data/etc/android.hardware.camera.autofocus.xml:system/etc/permissions/android.hardware.camera.autofocus.xml \
	frameworks/native/data/etc/android.hardware.camera.full.xml:system/etc/permissions/android.hardware.camera.full.xml \
	frameworks/native/data/etc/android.hardware.camera.raw.xml:system/etc/permissions/android.hardware.camera.raw.xml \
	frameworks/native/data/etc/android.hardware.camera.flash-autofocus.xml:system/etc/permissions/android.hardware.camera.flash-autofocus.xml \
	frameworks/native/data/etc/android.hardware.wifi.xml:system/etc/permissions/android.hardware.wifi.xml \
	frameworks/native/data/etc/android.hardware.wifi.direct.xml:system/etc/permissions/android.hardware.wifi.direct.xml \
	frameworks/native/data/etc/android.hardware.sensor.light.xml:system/etc/permissions/android.hardware.sensor.light.xml \
	frameworks/native/data/etc/android.hardware.faketouch.xml:system/etc/permissions/android.hardware.faketouch.xml \
	frameworks/native/data/etc/android.software.sip.voip.xml:system/etc/permissions/android.software.sip.voip.xml \
	frameworks/native/data/etc/android.hardware.usb.host.xml:system/etc/permissions/android.hardware.usb.host.xml \
	frameworks/native/data/etc/android.hardware.usb.accessory.xml:system/etc/permissions/android.hardware.usb.accessory.xml \
	frameworks/native/data/etc/android.hardware.bluetooth_le.xml:system/etc/permissions/android.hardware.bluetooth_le.xml \
	frameworks/native/data/etc/android.hardware.consumerir.xml:system/etc/permissions/android.hardware.consumerir.xml \
	frameworks/native/data/etc/android.hardware.ethernet.xml:system/etc/permissions/android.hardware.ethernet.xml \
	device/variscite/var_mx6/required_hardware.xml:system/etc/permissions/required_hardware.xml
