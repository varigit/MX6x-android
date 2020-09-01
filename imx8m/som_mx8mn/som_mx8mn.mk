# This is a FSL Android Reference Design platform based on i.MX8QP ARD board
# It will inherit from FSL core product which in turn inherit from Google generic

IMX_DEVICE_PATH := device/variscite/imx8m/som_mx8mn
BCM_FIRMWARE_PATH := vendor/variscite/bcm_4343w_fw

# configs shared between uboot, kernel and Android rootfs
include $(IMX_DEVICE_PATH)/SharedBoardConfig.mk

-include device/fsl/common/imx_path/ImxPathConfig.mk
-include device/variscite/common/VarPathConfig.mk
include device/fsl/imx8m/ProductConfigCommon.mk

ifneq ($(wildcard $(IMX_DEVICE_PATH)/fstab.freescale),)
$(shell touch $(IMX_DEVICE_PATH)/fstab.freescale)
endif

# Overrides
PRODUCT_NAME := som_mx8mn
PRODUCT_DEVICE := som_mx8mn
PRODUCT_MODEL := SOM_MX8MN

PRODUCT_FULL_TREBLE_OVERRIDE := true

#Enable this to choose 32 bit user space build
#IMX8_BUILD_32BIT_ROOTFS := true

#Enable this to use dynamic partitions for the readonly partitions not touched by bootloader
TARGET_USE_DYNAMIC_PARTITIONS ?=true
#If the device is retrofit to have dynamic partition feature, set this variable to true to build
#the images and OTA package. Here is a demo to update 10.0.0_1.0.0 to 10.0.0_2.0.0 or higher
TARGET_USE_RETROFIT_DYNAMIC_PARTITION ?= false

ifeq ($(TARGET_USE_DYNAMIC_PARTITIONS),true)
  PRODUCT_USE_DYNAMIC_PARTITIONS := true
  BOARD_BUILD_SUPER_IMAGE_BY_DEFAULT := true
  BOARD_SUPER_IMAGE_IN_UPDATE_PACKAGE := true
  ifeq ($(TARGET_USE_RETROFIT_DYNAMIC_PARTITION),true)
    PRODUCT_RETROFIT_DYNAMIC_PARTITIONS := true
    BOARD_SUPER_PARTITION_METADATA_DEVICE := system
    ifeq ($(IMX_NO_PRODUCT_PARTITION),true)
      BOARD_SUPER_PARTITION_BLOCK_DEVICES := system vendor
      BOARD_SUPER_PARTITION_SYSTEM_DEVICE_SIZE := 2952790016
      BOARD_SUPER_PARTITION_VENDOR_DEVICE_SIZE := 536870912
    else
      BOARD_SUPER_PARTITION_BLOCK_DEVICES := system vendor product
      BOARD_SUPER_PARTITION_SYSTEM_DEVICE_SIZE := 1610612736
      BOARD_SUPER_PARTITION_VENDOR_DEVICE_SIZE := 536870912
      BOARD_SUPER_PARTITION_PRODUCT_DEVICE_SIZE := 1879048192
    endif
  endif
endif

# Include keystore attestation keys and certificates.
ifeq ($(PRODUCT_IMX_TRUSTY),true)
-include $(IMX_SECURITY_PATH)/attestation/imx_attestation.mk
endif

# Include Android Go config for low memory device.
ifeq ($(LOW_MEMORY),true)
$(call inherit-product, build/target/product/go_defaults.mk)
endif

# Copy device related config and binary to board
PRODUCT_COPY_FILES += \
    $(FSL_PROPRIETARY_PATH)/fsl-proprietary/mcu-sdk/imx8mn/imx8mn_mcu_demo.img:imx8mn_mcu_demo.img \
    $(IMX_DEVICE_PATH)/app_whitelist.xml:system/etc/sysconfig/app_whitelist.xml \
    $(IMX_DEVICE_PATH)/audio_effects.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio_effects.xml \
    $(IMX_DEVICE_PATH)/audio_policy_configuration.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio_policy_configuration.xml \
    $(IMX_DEVICE_PATH)/usb_audio_policy_configuration-direct-output.xml:$(TARGET_COPY_OUT_VENDOR)/etc/usb_audio_policy_configuration-direct-output.xml \
    $(IMX_DEVICE_PATH)/fstab.freescale:$(TARGET_COPY_OUT_VENDOR)/etc/fstab.freescale \
    $(IMX_DEVICE_PATH)/init.imx8mn.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/hw/init.freescale.imx8mn.rc \
    $(IMX_DEVICE_PATH)/early.init.cfg:$(TARGET_COPY_OUT_VENDOR)/etc/early.init.cfg \
    $(IMX_DEVICE_PATH)/init.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/hw/init.freescale.rc \
    $(IMX_DEVICE_PATH)/init.usb.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/hw/init.freescale.usb.rc \
    $(IMX_DEVICE_PATH)/required_hardware.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/required_hardware.xml \
    $(IMX_DEVICE_PATH)/ueventd.freescale.rc:$(TARGET_COPY_OUT_VENDOR)/ueventd.rc \
    $(LINUX_FIRMWARE_IMX_PATH)/linux-firmware-imx/firmware/sdma/sdma-imx7d.bin:$(TARGET_COPY_OUT_VENDOR)/firmware/imx/sdma/sdma-imx7d.bin \
    device/fsl/common/init/init.insmod.sh:$(TARGET_COPY_OUT_VENDOR)/bin/init.insmod.sh \
    device/fsl/common/wifi/p2p_supplicant_overlay.conf:$(TARGET_COPY_OUT_VENDOR)/etc/wifi/p2p_supplicant_overlay.conf \
    device/fsl/common/wifi/bcm_wpa_supplicant_overlay.conf:$(TARGET_COPY_OUT_VENDOR)/etc/wifi/wpa_supplicant_overlay.conf \
    $(IMX_DEVICE_PATH)/init.brcm.wifibt.sh:vendor/bin/init.brcm.wifibt.sh

ifeq ($(TARGET_USE_DYNAMIC_PARTITIONS),true)
PRODUCT_COPY_FILES += \
    $(FSL_PROPRIETARY_PATH)/fsl-proprietary/dynamic_partiton_tools/lpmake:lpmake \
    $(FSL_PROPRIETARY_PATH)/fsl-proprietary/dynamic_partiton_tools/lpmake.exe:lpmake.exe
endif

# Audio card json
PRODUCT_COPY_FILES += \
    $(IMX_DEVICE_PATH)/wm8904_config.json:$(TARGET_COPY_OUT_VENDOR)/etc/configs/audio/wm8904_config.json \
    device/fsl/common/audio-json/readme.txt:$(TARGET_COPY_OUT_VENDOR)/etc/configs/audio/readme.txt

ifeq ($(PRODUCT_IMX_TRUSTY),true)
PRODUCT_COPY_FILES += \
    device/fsl/common/security/rpmb_key_test.bin:rpmb_key_test.bin \
    device/fsl/common/security/testkey_public_rsa4096.bin:testkey_public_rsa4096.bin
endif

PRODUCT_COPY_FILES += \
    device/fsl/imx8m/evk_8mn/camera_config_imx8mn.json:$(TARGET_COPY_OUT_VENDOR)/etc/configs/camera_config_imx8mn.json

# ONLY devices that meet the CDD's requirements may declare these features
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.audio.output.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.audio.output.xml \
    frameworks/native/data/etc/android.hardware.bluetooth_le.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.bluetooth_le.xml \
    frameworks/native/data/etc/android.hardware.camera.front.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.camera.front.xml \
    frameworks/native/data/etc/android.hardware.camera.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.camera.xml \
    frameworks/native/data/etc/android.hardware.ethernet.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.ethernet.xml \
    frameworks/native/data/etc/android.hardware.screen.landscape.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.screen.landscape.xml \
    frameworks/native/data/etc/android.hardware.screen.portrait.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.screen.portrait.xml \
    frameworks/native/data/etc/android.hardware.touchscreen.multitouch.distinct.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.touchscreen.multitouch.distinct.xml \
    frameworks/native/data/etc/android.hardware.touchscreen.multitouch.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.touchscreen.multitouch.xml \
    frameworks/native/data/etc/android.hardware.touchscreen.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.touchscreen.xml \
    frameworks/native/data/etc/android.hardware.usb.accessory.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.usb.accessory.xml \
    frameworks/native/data/etc/android.hardware.usb.host.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.usb.host.xml \
    frameworks/native/data/etc/android.hardware.vulkan.level-0.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.vulkan.level-0.xml \
    frameworks/native/data/etc/android.hardware.vulkan.version-1_1.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.vulkan.version-1_1.xml \
    frameworks/native/data/etc/android.hardware.wifi.direct.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.wifi.direct.xml \
    frameworks/native/data/etc/android.hardware.wifi.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.wifi.xml \
    frameworks/native/data/etc/android.hardware.wifi.passpoint.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.wifi.passpoint.xml \
    frameworks/native/data/etc/android.software.app_widgets.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.app_widgets.xml \
    frameworks/native/data/etc/android.software.backup.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.backup.xml \
    frameworks/native/data/etc/android.software.device_admin.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.device_admin.xml \
    frameworks/native/data/etc/android.software.managed_users.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.managed_users.xml \
    frameworks/native/data/etc/android.software.print.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.print.xml \
    frameworks/native/data/etc/android.software.sip.voip.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.sip.voip.xml \
    frameworks/native/data/etc/android.software.verified_boot.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.verified_boot.xml \
    frameworks/native/data/etc/android.software.voice_recognizers.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.voice_recognizers.xml \
    frameworks/native/data/etc/android.software.activities_on_secondary_displays.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.activities_on_secondary_displays.xml \
    frameworks/native/data/etc/android.software.picture_in_picture.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.picture_in_picture.xml

# Vendor seccomp policy files for media components:
PRODUCT_COPY_FILES += \
    $(IMX_DEVICE_PATH)/seccomp/mediacodec-seccomp.policy:vendor/etc/seccomp_policy/mediacodec.policy \
    $(IMX_DEVICE_PATH)/seccomp/mediaextractor-seccomp.policy:vendor/etc/seccomp_policy/mediaextractor.policy

PRODUCT_COPY_FILES += \
    device/fsl/imx8m/evk_8mn/powerhint_imx8mn.json:$(TARGET_COPY_OUT_VENDOR)/etc/configs/powerhint_imx8mn.json

# fastboot_imx_flashall scripts, fsl-sdcard-partition script uuu_imx_android_flash scripts
PRODUCT_COPY_FILES += \
    device/fsl/common/tools/fastboot_imx_flashall.bat:fastboot_imx_flashall.bat \
    device/fsl/common/tools/fastboot_imx_flashall.sh:fastboot_imx_flashall.sh \
    device/fsl/common/tools/fsl-sdcard-partition.sh:fsl-sdcard-partition.sh \
    device/fsl/common/tools/uuu_imx_android_flash.bat:uuu_imx_android_flash.bat \
    device/fsl/common/tools/uuu_imx_android_flash.sh:uuu_imx_android_flash.sh

# Copy media_codecs.xml for 1GB evk_imx8mn board
ifeq ($(LOW_MEMORY),true)
PRODUCT_COPY_FILES += \
    $(FSL_PROPRIETARY_PATH)/fsl-proprietary/media-profile/imx8mn/media_codecs_no_vpu.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_codecs.xml
endif

USE_XML_AUDIO_POLICY_CONF := 1

DEVICE_PACKAGE_OVERLAYS := $(IMX_DEVICE_PATH)/overlay

PRODUCT_CHARACTERISTICS := tablet

PRODUCT_AAPT_CONFIG += xlarge large tvdpi hdpi xhdpi xxhdpi

# GPU openCL g2d
PRODUCT_COPY_FILES += \
    $(IMX_PATH)/imx/opencl-2d/cl_g2d.cl:$(TARGET_COPY_OUT_VENDOR)/etc/cl_g2d.cl

# HWC2 HAL
PRODUCT_PACKAGES += \
    android.hardware.graphics.composer@2.3-service

# Gralloc HAL
PRODUCT_PACKAGES += \
    android.hardware.graphics.mapper@2.0-impl-2.1 \
    android.hardware.graphics.allocator@2.0-impl \
    android.hardware.graphics.allocator@2.0-service

# RenderScript HAL
PRODUCT_PACKAGES += \
    android.hardware.renderscript@1.0-impl

PRODUCT_PACKAGES += \
    libEGL_VIVANTE \
    libGLESv1_CM_VIVANTE \
    libGLESv2_VIVANTE \
    gralloc_viv.imx \
    libGAL \
    libGLSLC \
    libVSC \
    libgpuhelper \
    libSPIRV_viv \
    libvulkan_VIVANTE \
    vulkan.imx \
    libCLC \
    libLLVM_viv \
    libOpenCL \
    libg2d-opencl \
    libg2d-viv \
    libOpenVX \
    libOpenVXU \
    libNNVXCBinary-evis \
    libNNVXCBinary-evis2 \
    libNNVXCBinary-lite \
    libOvx12VXCBinary-evis \
    libOvx12VXCBinary-evis2 \
    libOvx12VXCBinary-lite \
    libNNGPUBinary-evis \
    libNNGPUBinary-evis2 \
    libNNGPUBinary-lite \
    libNNGPUBinary-ulite \
    gatekeeper.imx

# Neural Network HAL and Lib
PRODUCT_PACKAGES += \
    libovxlib \
    libnnrt \
    android.hardware.neuralnetworks@1.2-service-vsi-npu-server

PRODUCT_PACKAGES += \
    android.hardware.audio@5.0-impl:32 \
    android.hardware.audio@2.0-service \
    android.hardware.audio.effect@5.0-impl:32 \
    android.hardware.power@1.3-service.imx \
    android.hardware.light@2.0-impl \
    android.hardware.light@2.0-service \
    android.hardware.configstore@1.1-service \
    configstore@1.1.policy

# Thermal HAL
PRODUCT_PACKAGES += \
    android.hardware.thermal@2.0-service.imx
PRODUCT_COPY_FILES += \
    device/fsl/imx8m/evk_8mn/thermal_info_config_imx8mn.json:$(TARGET_COPY_OUT_VENDOR)/etc/configs/thermal_info_config_imx8mn.json

# Usb HAL
PRODUCT_PACKAGES += \
    android.hardware.usb@1.1-service.imx

# Bluetooth HAL
PRODUCT_PACKAGES += \
    android.hardware.bluetooth@1.0-impl \
    android.hardware.bluetooth@1.0-service


# WiFi HAL
PRODUCT_PACKAGES += \
    android.hardware.wifi@1.0-service \
    wifilogd \
    wificond

PRODUCT_COPY_FILES += \
       $(IMX_DEVICE_PATH)/bluetooth/bt_vendor.conf:system/etc/bluetooth/bt_vendor.conf

# Broadcome WiFi Firmware
PRODUCT_COPY_FILES += \
    $(BCM_FIRMWARE_PATH)/bcm4339.hcd:vendor/firmware/bcm/bcm4339.hcd \
    $(BCM_FIRMWARE_PATH)/bcm43430a1.hcd:vendor/firmware/bcm/bcm43430a1.hcd \
    $(BCM_FIRMWARE_PATH)/brcm/brcmfmac4339-sdio.bin:vendor/firmware/brcm/brcmfmac4339-sdio.bin \
    $(BCM_FIRMWARE_PATH)/brcm/brcmfmac4339-sdio.txt:vendor/firmware/brcm/brcmfmac4339-sdio.txt \
    $(BCM_FIRMWARE_PATH)/brcm/brcmfmac43430-sdio.bin:vendor/firmware/brcm/brcmfmac43430-sdio.bin \
    $(BCM_FIRMWARE_PATH)/brcm/brcmfmac43430-sdio.txt:vendor/firmware/brcm/brcmfmac43430-sdio.txt \
    $(BCM_FIRMWARE_PATH)/brcm/brcmfmac43430-sdio.clm_blob:vendor/firmware/brcm/brcmfmac43430-sdio.clm_blob

# Wifi regulatory
PRODUCT_COPY_FILES += \
    external/wireless-regdb/regulatory.db:vendor/firmware/regulatory.db \
    external/wireless-regdb/regulatory.db.p7s:vendor/firmware/regulatory.db.p7s

# Boot Animation
PRODUCT_COPY_FILES += \
    device/variscite/common/bootanimation-var1280.zip:system/media/bootanimation.zip

# Keymaster HAL
ifeq ($(PRODUCT_IMX_TRUSTY),true)
PRODUCT_PACKAGES += \
    android.hardware.keymaster@3.0-service.trusty
endif

PRODUCT_PACKAGES += \
    android.hardware.keymaster@3.0-impl \
    android.hardware.keymaster@3.0-service

# DRM HAL
TARGET_ENABLE_MEDIADRM_64 := true
PRODUCT_PACKAGES += \
    android.hardware.drm@1.0-impl \
    android.hardware.drm@1.0-service

# new gatekeeper HAL
PRODUCT_PACKAGES += \
    android.hardware.gatekeeper@1.0-impl \
    android.hardware.gatekeeper@1.0-service

ifneq ($(BUILD_TARGET_FS),ubifs)
PRODUCT_PROPERTY_OVERRIDES += \
    ro.frp.pst=/dev/block/by-name/presistdata
endif

# ro.product.first_api_level indicates the first api level the device has commercially launched on.
PRODUCT_PROPERTY_OVERRIDES += \
    ro.product.first_api_level=28 \
    vendor.typec.legacy=true

PRODUCT_PACKAGES += \
    DirectAudioPlayer

# Tensorflow lite camera demo
PRODUCT_PACKAGES += \
                    tflitecamerademo

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

# Add oem unlocking option in settings.
PRODUCT_PROPERTY_OVERRIDES += ro.frp.pst=/dev/block/by-name/presistdata
PRODUCT_COMPATIBLE_PROPERTY_OVERRIDE := true

# Add Trusty OS backed gatekeeper and secure storage proxy
ifeq ($(PRODUCT_IMX_TRUSTY),true)
PRODUCT_PACKAGES += \
    gatekeeper.trusty \
    storageproxyd
endif

#Dumpstate HAL 1.0 support
PRODUCT_PACKAGES += \
    android.hardware.dumpstate@1.0-service.imx

ifeq ($(PRODUCT_IMX_TRUSTY),true)
#Oemlock HAL 1.0 support
PRODUCT_PACKAGES += \
    android.hardware.oemlock@1.0-service.imx
endif

# Specify rollback index for bootloader and for AVB
ifneq ($(AVB_RBINDEX),)
BOARD_AVB_ROLLBACK_INDEX := $(AVB_RBINDEX)
else
BOARD_AVB_ROLLBACK_INDEX := 0
endif

ifneq (,$(filter userdebug eng,$(TARGET_BUILD_VARIANT)))
$(call inherit-product, $(SRC_TARGET_DIR)/product/gsi_keys.mk)
PRODUCT_PACKAGES += \
    adb_debug.prop
endif

IMX-DEFAULT-G2D-LIB := libg2d-opencl

ifeq ($(PREBUILT_FSL_IMX_CODEC),true)
ifneq ($(IMX8_BUILD_32BIT_ROOTFS),true)
INSTALL_64BIT_LIBRARY := true
endif
-include $(FSL_CODEC_PATH)/fsl-codec/fsl-codec.mk
endif

# imx c2 codec binary
PRODUCT_PACKAGES += \
    c2_component_register \
    c2_component_register_ms \
    c2_component_register_ra

