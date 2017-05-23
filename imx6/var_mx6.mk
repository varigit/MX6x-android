# This is a Variscite Android Reference Design platform for VAR-SOM-SOLO/DUAL/MX6
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
PRODUCT_NAME := var_mx6
PRODUCT_DEVICE := var_mx6

PRODUCT_COPY_FILES += \
	device/variscite/var_mx6/init.rc:root/init.freescale.rc \
        device/variscite/var_mx6/init.i.MX6Q.rc:root/init.freescale.i.MX6Q.rc \
        device/variscite/var_mx6/init.i.MX6DL.rc:root/init.freescale.i.MX6DL.rc \
	device/variscite/var_mx6/init.i.MX6QP.rc:root/init.freescale.i.MX6QP.rc \
	device/variscite/var_mx6/bootanimation-var0640.zip:/system/media/bootanimation.zip

# Audio
USE_XML_AUDIO_POLICY_CONF := 1
PRODUCT_COPY_FILES += \
	device/variscite/var_mx6/audio_effects.conf:system/vendor/etc/audio_effects.conf \
	device/variscite/var_mx6/audio_policy_configuration.xml:system/etc/audio_policy_configuration.xml \
	frameworks/av/services/audiopolicy/config/a2dp_audio_policy_configuration.xml:system/etc/a2dp_audio_policy_configuration.xml \
	frameworks/av/services/audiopolicy/config/r_submix_audio_policy_configuration.xml:system/etc/r_submix_audio_policy_configuration.xml \
	frameworks/av/services/audiopolicy/config/usb_audio_policy_configuration.xml:system/etc/usb_audio_policy_configuration.xml \
	frameworks/av/services/audiopolicy/config/default_volume_tables.xml:system/etc/default_volume_tables.xml \
	frameworks/av/services/audiopolicy/config/audio_policy_volumes.xml:system/etc/audio_policy_volumes.xml \

PRODUCT_COPY_FILES +=	\
	external/linux-firmware-imx/firmware/vpu/vpu_fw_imx6d.bin:system/lib/firmware/vpu/vpu_fw_imx6d.bin 	\
	external/linux-firmware-imx/firmware/vpu/vpu_fw_imx6q.bin:system/lib/firmware/vpu/vpu_fw_imx6q.bin

ifeq ($(TI_WLAN_CHIP),wl12xx)
# wl12xx driver currently broken due to kernel 4.1 patch to
# support wl18xx R8.6_SP1
# revert that patch to use wl12xx
# please note that wl1271-nvs.bin is used also by wl18xx driver
# to reset the MAC: do not copy it to rootfs for wl18xx sanity
# wl12xx firmware
PRODUCT_COPY_FILES +=	\
	device/variscite/common/wl12xx/wl1271-nvs.bin:system/etc/firmware/ti-connectivity/wl1271-nvs.bin \
	device/variscite/common/wl12xx/wl127x-fw-5-mr.bin:system/etc/firmware/ti-connectivity/wl127x-fw-5-mr.bin \
	device/variscite/common/wl12xx/wl127x-fw-5-plt.bin:system/etc/firmware/ti-connectivity/wl127x-fw-5-plt.bin \
	device/variscite/common/wl12xx/wl127x-fw-5-sr.bin:system/etc/firmware/ti-connectivity/wl127x-fw-5-sr.bin \
	device/variscite/common/wl12xx/TIInit_7.6.15.bts:system/etc/firmware/ti-connectivity/TIInit_7.6.15.bts
else
# wl18xx firmware
PRODUCT_COPY_FILES +=	\
	device/variscite/common/wl18xx/wl18xx-conf.bin:system/etc/firmware/ti-connectivity/wl18xx-conf.bin \
	device/variscite/common/wl18xx/wl18xx-fw-4.bin:system/etc/firmware/ti-connectivity/wl18xx-fw-4.bin \
	device/variscite/common/wl18xx/TIInit_11.8.32.bts:system/etc/firmware/ti-connectivity/TIInit_11.8.32.bts
endif #

# setup dm-verity configs.
ifneq ($(BUILD_TARGET_DEVICE),sd)
 PRODUCT_SYSTEM_VERITY_PARTITION := /dev/block/mmcblk1p5
 $(call inherit-product, build/target/product/verity.mk)
else 
 PRODUCT_SYSTEM_VERITY_PARTITION := /dev/block/mmcblk0p5
 $(call inherit-product, build/target/product/verity.mk)

endif

# GPU files

DEVICE_PACKAGE_OVERLAYS := device/variscite/var_mx6/overlay

PRODUCT_CHARACTERISTICS := tablet

PRODUCT_AAPT_CONFIG += xlarge large tvdpi hdpi xhdpi

PRODUCT_COPY_FILES += \
	frameworks/native/data/etc/tablet_core_hardware.xml:system/etc/permissions/tablet_core_hardware.xml \
	frameworks/native/data/etc/android.hardware.camera.xml:system/etc/permissions/android.hardware.camera.xml \
	frameworks/native/data/etc/android.hardware.camera.front.xml:system/etc/permissions/android.hardware.camera.front.xml \
	frameworks/native/data/etc/android.hardware.wifi.xml:system/etc/permissions/android.hardware.wifi.xml \
	frameworks/native/data/etc/android.hardware.wifi.direct.xml:system/etc/permissions/android.hardware.wifi.direct.xml \
	frameworks/native/data/etc/android.hardware.sensor.light.xml:system/etc/permissions/android.hardware.sensor.light.xml \
	frameworks/native/data/etc/android.hardware.faketouch.xml:system/etc/permissions/android.hardware.faketouch.xml \
	frameworks/native/data/etc/android.software.sip.voip.xml:system/etc/permissions/android.software.sip.voip.xml \
	frameworks/native/data/etc/android.hardware.usb.host.xml:system/etc/permissions/android.hardware.usb.host.xml \
	frameworks/native/data/etc/android.hardware.usb.accessory.xml:system/etc/permissions/android.hardware.usb.accessory.xml \
	frameworks/native/data/etc/android.hardware.bluetooth.xml:system/etc/permissions/android.hardware.bluetooth.xml \
	frameworks/native/data/etc/android.hardware.bluetooth_le.xml:system/etc/permissions/android.hardware.bluetooth_le.xml \
	frameworks/native/data/etc/android.hardware.ethernet.xml:system/etc/permissions/android.hardware.ethernet.xml \
	device/variscite/var_mx6/required_hardware.xml:system/etc/permissions/required_hardware.xml

PRODUCT_COPY_FILES += \
    device/fsl-proprietary/gpu-viv/lib/egl/egl.cfg:system/lib/egl/egl.cfg

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
    AudioRoute  \
    libEGL_VIVANTE \
    libGLESv1_CM_VIVANTE \
    libGLESv2_VIVANTE \
    gralloc_viv.imx6 \
    hwcomposer_viv.imx6 \
    hwcomposer_fsl.imx6 \
    libGAL \
    libGLSLC \
    libVSC \
    libg2d \
    libgpuhelper
