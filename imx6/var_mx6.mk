# This is a FSL Android Reference Design platform based on i.MX6Q ARD board
# It will inherit from FSL core product which in turn inherit from Google generic
-include device/variscite/common/imx_path/ImxPathConfig.mk
$(call inherit-product, device/variscite/imx6/imx6.mk)
$(call inherit-product-if-exists,vendor/google/products/gms.mk)

ifneq ($(wildcard device/variscite/var_mx6/fstab_nand.freescale),)
$(shell touch device/variscite/var_mx6/fstab_nand.freescale)
endif

ifneq ($(wildcard device/variscite/var_mx6/fstab.freescale),)
$(shell touch device/variscite/var_mx6/fstab.freescale)
endif

# Overrides
PRODUCT_NAME := var_mx6
PRODUCT_DEVICE := var_mx6

USE_VAR_HACKED_HIDL := true

PRODUCT_COPY_FILES += \
	device/variscite/var_mx6/init.rc:root/init.var-som-mx6.rc \
	device/variscite/var_mx6/init.imx6q.rc:root/init.var-som-mx6.imx6q.rc \
	device/variscite/var_mx6/init.imx6dl.rc:root/init.var-som-mx6.imx6dl.rc \
	device/variscite/var_mx6/init.imx6qp.rc:root/init.var-som-mx6.imx6qp.rc \
	device/variscite/var_mx6/init.rc:root/init.var-dart-mx6.rc \
	device/variscite/var_mx6/init.imx6q.rc:root/init.var-dart-mx6.imx6q.rc \
	device/variscite/var_mx6/init.imx6dl.rc:root/init.var-dart-mx6.imx6dl.rc \
	device/variscite/var_mx6/init.imx6qp.rc:root/init.var-dart-mx6.imx6qp.rc \

PRODUCT_COPY_FILES += device/variscite/var_mx6/init.freescale.emmc.rc:root/init.var-som-mx6.emmc.rc
PRODUCT_COPY_FILES += device/variscite/var_mx6/init.var-dart-mx6.emmc.rc:root/init.var-dart-mx6.emmc.rc
PRODUCT_COPY_FILES += device/variscite/var_mx6/init.freescale.sd.rc:root/init.var-som-mx6.sd.rc
PRODUCT_COPY_FILES += device/variscite/var_mx6/init.freescale.sd.rc:root/init.var-dart-mx6.sd.rc

#Copy Variscite Boot Animation
PRODUCT_COPY_FILES += device/variscite/common/bootanimation-var0640.zip:/system/media/bootanimation.zip

# Audio
USE_XML_AUDIO_POLICY_CONF := 1
PRODUCT_COPY_FILES += \
	device/variscite/var_mx6//audio_effects.conf:$(TARGET_COPY_OUT_VENDOR)/etc/audio_effects.conf \
	device/variscite/var_mx6//audio_policy_configuration.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio_policy_configuration.xml \
	frameworks/av/services/audiopolicy/config/a2dp_audio_policy_configuration.xml:$(TARGET_COPY_OUT_VENDOR)/etc/a2dp_audio_policy_configuration.xml \
	frameworks/av/services/audiopolicy/config/r_submix_audio_policy_configuration.xml:$(TARGET_COPY_OUT_VENDOR)/etc/r_submix_audio_policy_configuration.xml \
	frameworks/av/services/audiopolicy/config/usb_audio_policy_configuration.xml:$(TARGET_COPY_OUT_VENDOR)/etc/usb_audio_policy_configuration.xml \
	frameworks/av/services/audiopolicy/config/default_volume_tables.xml:$(TARGET_COPY_OUT_VENDOR)/etc/default_volume_tables.xml \
	frameworks/av/services/audiopolicy/config/audio_policy_volumes.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio_policy_volumes.xml \

PRODUCT_COPY_FILES +=	\
	$(LINUX_FIRMWARE_IMX_PATH)/linux-firmware-imx/firmware/vpu/vpu_fw_imx6d.bin:system/lib/firmware/vpu/vpu_fw_imx6d.bin 	\
	$(LINUX_FIRMWARE_IMX_PATH)/linux-firmware-imx/firmware/vpu/vpu_fw_imx6q.bin:system/lib/firmware/vpu/vpu_fw_imx6q.bin
# setup dm-verity configs.
 PRODUCT_SYSTEM_VERITY_PARTITION := /dev/block/by-name/system
 $(call inherit-product, build/target/product/verity.mk)

# wl12xx driver currently broken due to kernel 4.1 patch to
# support wl18xx R8.6_SP1
# revert that patch to use wl12xx
# please note that wl1271-nvs.bin is used also by wl18xx driver
# to reset the MAC
# wl12xx firmware
PRODUCT_COPY_FILES +=	\
	device/variscite/common/wl12xx/wl1271-nvs.bin:$(TARGET_COPY_OUT_VENDOR)/firmware/ti-connectivity/wl1271-nvs.bin \
	device/variscite/common/wl12xx/wl127x-fw-5-mr.bin:$(TARGET_COPY_OUT_VENDOR)/firmware/ti-connectivity/wl127x-fw-5-mr.bin \
	device/variscite/common/wl12xx/wl127x-fw-5-plt.bin:$(TARGET_COPY_OUT_VENDOR)/firmware/ti-connectivity/wl127x-fw-5-plt.bin \
	device/variscite/common/wl12xx/wl127x-fw-5-sr.bin:$(TARGET_COPY_OUT_VENDOR)/firmware/ti-connectivity/wl127x-fw-5-sr.bin \
	device/variscite/common/wl12xx/TIInit_7.6.15.bts:$(TARGET_COPY_OUT_VENDOR)/firmware/ti-connectivity/TIInit_7.6.15.bts

# wl18xx firmware
PRODUCT_COPY_FILES +=	\
	device/variscite/common/wl18xx/wl18xx-conf.bin:$(TARGET_COPY_OUT_VENDOR)/firmware/ti-connectivity/wl18xx-conf.bin \
	device/variscite/common/wl18xx/wl18xx-fw-4.bin:$(TARGET_COPY_OUT_VENDOR)/firmware/ti-connectivity/wl18xx-fw-4.bin \
	device/variscite/common/wl18xx/TIInit_11.8.32.bts:$(TARGET_COPY_OUT_VENDOR)/firmware/ti-connectivity/TIInit_11.8.32.bts

HARDWARE := var-som-mx6
# setup dm-verity configs.
#ifeq ($(BUILD_TARGET_DEVICE),sd)
# PRODUCT_SYSTEM_VERITY_PARTITION := /dev/block/mmcblk1p5
# $(call inherit-product, build/target/product/verity.mk)
#else 
# PRODUCT_SYSTEM_VERITY_PARTITION := /dev/block/mmcblk0p5
## only for DART-MX6 comment above line and uncomment below line
## PRODUCT_SYSTEM_VERITY_PARTITION := /dev/block/mmcblk2p5
# $(call inherit-product, build/target/product/verity.mk)
#endif

# GPU files

DEVICE_PACKAGE_OVERLAYS := device/variscite/var_mx6/overlay

PRODUCT_CHARACTERISTICS := tablet

PRODUCT_AAPT_CONFIG += xlarge large tvdpi hdpi xhdpi

PRODUCT_COPY_FILES += \
	device/variscite/var_mx6/tablet_core_hardware.xml:system/etc/permissions/tablet_core_hardware.xml \
	frameworks/native/data/etc/android.hardware.camera.xml:system/etc/permissions/android.hardware.camera.xml \
	frameworks/native/data/etc/android.hardware.camera.front.xml:system/etc/permissions/android.hardware.camera.front.xml \
	frameworks/native/data/etc/android.hardware.wifi.xml:system/etc/permissions/android.hardware.wifi.xml \
	frameworks/native/data/etc/android.hardware.wifi.direct.xml:system/etc/permissions/android.hardware.wifi.direct.xml \
	frameworks/native/data/etc/android.hardware.sensor.light.xml:system/etc/permissions/android.hardware.sensor.light.xml \
	frameworks/native/data/etc/android.hardware.faketouch.xml:system/etc/permissions/android.hardware.faketouch.xml \
	frameworks/native/data/etc/android.software.sip.voip.xml:system/etc/permissions/android.software.sip.voip.xml \
	frameworks/native/data/etc/android.hardware.usb.host.xml:system/etc/permissions/android.hardware.usb.host.xml \
	frameworks/native/data/etc/android.hardware.usb.accessory.xml:system/etc/permissions/android.hardware.usb.accessory.xml \
	frameworks/native/data/etc/android.hardware.ethernet.xml:system/etc/permissions/android.hardware.ethernet.xml \
	device/variscite/var_mx6/required_hardware.xml:system/etc/permissions/required_hardware.xml

PRODUCT_COPY_FILES += \
	frameworks/native/data/etc/android.hardware.bluetooth.xml:system/etc/permissions/android.hardware.bluetooth.xml \
	frameworks/native/data/etc/android.hardware.bluetooth_le.xml:system/etc/permissions/android.hardware.bluetooth_le.xml


PRODUCT_COPY_FILES += \
    $(FSL_PROPRIETARY_PATH)/fsl-proprietary/gpu-viv/lib/egl/egl.cfg:system/lib/egl/egl.cfg

# wl18xx utils
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
	uim-sysfs \
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

#I2C tools
PRODUCT_PACKAGES += \
	i2c-tools \
	i2cdetect \
	i2cget \
	i2cset \
	i2cdump

# HWC2 HAL
PRODUCT_PACKAGES += \
    android.hardware.graphics.composer@2.1-impl

# Gralloc HAL
PRODUCT_PACKAGES += \
    android.hardware.graphics.mapper@2.0-impl \
    android.hardware.graphics.allocator@2.0-impl \
    android.hardware.graphics.allocator@2.0-service

# RenderScript HAL
PRODUCT_PACKAGES += \
    android.hardware.renderscript@1.0-impl

PRODUCT_PACKAGES += \
    android.hardware.audio@2.0-impl \
    android.hardware.audio@2.0-service \
    android.hardware.audio.effect@2.0-impl \
    android.hardware.power@1.0-impl \
    android.hardware.power@1.0-service \
    android.hardware.light@2.0-impl \
    android.hardware.light@2.0-service

# imx6 sensor HAL libs.
PRODUCT_PACKAGES += \
       sensors.imx6

# Usb HAL
PRODUCT_PACKAGES += \
    android.hardware.usb@1.0-service

# Bluetooth HAL
PRODUCT_PACKAGES += \
    android.hardware.bluetooth@1.0-impl \
    android.hardware.bluetooth@1.0-service

# WiFi HAL
PRODUCT_PACKAGES += \
    android.hardware.wifi@1.0-service \
    wifilogd \
    hostapd \
    wificond \
    libwifi-hal-wl18xx

LIB_WIFI_HAL := libwifi-hal-wl18xx

# Keymaster HAL
PRODUCT_PACKAGES += \
    android.hardware.keymaster@3.0-impl

PRODUCT_PACKAGES += \
    libEGL_VIVANTE \
    libGLESv1_CM_VIVANTE \
    libGLESv2_VIVANTE \
    libGAL \
    libGLSLC \
    libVSC \
    libg2d \
    libgpuhelper

PRODUCT_PACKAGES += \
    Launcher3

PRODUCT_PACKAGES += \
    SoundRecorder

PRODUCT_PROPERTY_OVERRIDES += \
    ro.internel.storage_size=/sys/block/bootdev_size

PRODUCT_PROPERTY_OVERRIDES += ro.frp.pst=/dev/block/by-name/presistdata
