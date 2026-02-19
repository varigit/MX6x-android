# This is a Variscite Android Reference Design platform based on VAR-SOM-MX8X
# It will inherit from NXP core product which in turn inherits from Google generic

CONFIG_REPO_PATH := device/nxp
CURRENT_FILE_PATH :=  $(lastword $(MAKEFILE_LIST))
IMX_DEVICE_PATH := $(strip $(patsubst %/, %, $(dir $(CURRENT_FILE_PATH))))
IMX_DEVICE_PATH := device/variscite/imx8q/som_mx8q
# NXP_DEVICE_PATH refers to the NXP MEK folder
NXP_DEVICE_PATH := $(CONFIG_REPO_PATH)/imx8q/mek_8q
PRODUCT_ENFORCE_ARTIFACT_PATH_REQUIREMENTS := true

#Enable this to choose 32 bit user space build
IMX_BUILD_32BIT_ROOTFS ?= false

# configs shared between uboot, kernel and Android rootfs
include $(IMX_DEVICE_PATH)/SharedBoardConfig.mk

-include $(CONFIG_REPO_PATH)/common/imx_path/ImxPathConfig.mk
-include device/variscite/common/imx_path/ImxPathConfig.mk
-include device/variscite/common/bootanimation/variscite_bootanimation_logo.mk

include $(CONFIG_REPO_PATH)/imx8q/ProductConfigCommon.mk

# -------@block_common_config-------
# Overrides

DEVICE_PACKAGE_OVERLAYS := $(IMX_DEVICE_PATH)/overlay

PRODUCT_CHARACTERISTICS := tablet

PRODUCT_VENDOR_PROPERTIES += ro.soc.manufacturer=Variscite
PRODUCT_VENDOR_PROPERTIES += ro.soc.model=IMX8Q
PRODUCT_VENDOR_PROPERTIES += ro.crypto.metadata_init_delete_all_keys.enabled=true
# -------@block_treble-------
PRODUCT_FULL_TREBLE_OVERRIDE := true

# -------@block_power-------
PRODUCT_SOONG_NAMESPACES += vendor/nxp-opensource/imx/power
PRODUCT_SOONG_NAMESPACES += hardware/google/pixel

PRODUCT_COPY_FILES += \
     $(IMX_DEVICE_PATH)/powerhint_imx8qxp.json:$(TARGET_COPY_OUT_VENDOR)/etc/configs/powerhint_imx8qxp.json

# Do not skip charger_not_need trigger by default
PRODUCT_DEFAULT_PROPERTY_OVERRIDES += \
    vendor.skip.charger_not_need=0

PRODUCT_PACKAGES += \
    android.hardware.power-service.imx

PRODUCT_PACKAGES += \
    var-mii

TARGET_VENDOR_PROP := $(NXP_DEVICE_PATH)/product.prop

# Thermal HAL
PRODUCT_PACKAGES += \
    android.hardware.thermal-service.imx

PRODUCT_COPY_FILES += \
    $(IMX_DEVICE_PATH)/thermal_info_config_imx8qxp.json:$(TARGET_COPY_OUT_VENDOR)/etc/configs/thermal_info_config_imx8qxp.json

# -------@block_app-------
# Set permission for GMS packages
PRODUCT_COPY_FILES += \
	  $(CONFIG_REPO_PATH)/imx8q/permissions/privapp-permissions-imx.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/permissions/privapp.permissions-imx.xml

PRODUCT_COPY_FILES += \
    $(NXP_DEVICE_PATH)/app_whitelist.xml:system/etc/sysconfig/app_whitelist.xml

# -------@block_kernel_bootimg-------
# Enable this to support vendor boot and boot header v3, this would be a MUST for GKI
TARGET_USE_VENDOR_BOOT ?= true

BOARD_RAMDISK_USE_LZ4 := true

PRODUCT_PROPERTY_OVERRIDES += \
    vendor.gki.enable=true
BOARD_USES_GENERIC_KERNEL_IMAGE := true
$(call inherit-product, $(SRC_TARGET_DIR)/product/generic_ramdisk.mk)

# Overrides
PRODUCT_MANUFACTURER := Variscite
PRODUCT_MODEL := Variscite

# We load the fstab from device tree so this is not needed, but since no kernel modules are installed to vendor
# boot ramdisk so far, we need this step to generate the vendor-ramdisk folder or build process would fail. This
# can be deleted once we figure out what kernel modules should be put into the vendor boot ramdisk.
ifeq ($(TARGET_USE_VENDOR_BOOT),true)
PRODUCT_COPY_FILES += \
    $(IMX_DEVICE_PATH)/fstab.nxp:$(TARGET_COPY_OUT_VENDOR_RAMDISK)/first_stage_ramdisk/fstab.nxp
endif

PRODUCT_COPY_FILES += \
    $(NXP_DEVICE_PATH)/early.init.cfg:$(TARGET_COPY_OUT_VENDOR)/etc/early.init.cfg \
    $(CONFIG_REPO_PATH)/common/init/init.insmod.sh:$(TARGET_COPY_OUT_VENDOR)/bin/init.insmod.sh

# -------@block_storage-------
# support metadata checksum during first stage mount
ifeq ($(TARGET_USE_VENDOR_BOOT),true)
PRODUCT_PACKAGES += \
    linker.vendor_ramdisk \
    resizefs.vendor_ramdisk \
    tune2fs.vendor_ramdisk
endif

#Enable this to use dynamic partitions for the readonly partitions not touched by bootloader
TARGET_USE_DYNAMIC_PARTITIONS ?= true

ifeq ($(TARGET_USE_DYNAMIC_PARTITIONS),true)
  ifeq ($(TARGET_USE_VENDOR_BOOT),true)
    $(call inherit-product, $(SRC_TARGET_DIR)/product/virtual_ab_ota/compression_with_xor.mk)
  else
    $(call inherit-product, $(SRC_TARGET_DIR)/product/virtual_ab_ota.mk)
  endif
  PRODUCT_USE_DYNAMIC_PARTITIONS := true
  BOARD_BUILD_SUPER_IMAGE_BY_DEFAULT := true
  BOARD_SUPER_IMAGE_IN_UPDATE_PACKAGE := true
endif

#Enable this to disable product partition build.
IMX_NO_PRODUCT_PARTITION := false

$(call inherit-product, $(SRC_TARGET_DIR)/product/emulated_storage.mk)

PRODUCT_COPY_FILES += \
    $(IMX_DEVICE_PATH)/fstab.nxp:$(TARGET_COPY_OUT_VENDOR)/etc/fstab.nxp

TARGET_RECOVERY_FSTAB = $(IMX_DEVICE_PATH)/fstab.nxp

# fastboot_imx_flashall scripts, imx-sdcard-partition script uuu_imx_android_flash scripts
PRODUCT_COPY_FILES += \
    $(CONFIG_REPO_PATH)/common/tools/fastboot_imx_flashall.bat:fastboot_imx_flashall.bat \
    $(CONFIG_REPO_PATH)/common/tools/fastboot_imx_flashall.sh:fastboot_imx_flashall.sh \
    $(CONFIG_REPO_PATH)/common/tools/imx-sdcard-partition.sh:imx-sdcard-partition.sh \
    $(CONFIG_REPO_PATH)/common/tools/uuu_imx_android_flash.bat:uuu_imx_android_flash.bat \
    $(CONFIG_REPO_PATH)/common/tools/uuu_imx_android_flash.sh:uuu_imx_android_flash.sh

# Variscite UUU eMMC burning scripts
PRODUCT_COPY_FILES += \
    device/variscite/scripts/uuu_scripts/emmc_burn_android_var_som_mx8x_c0.lst:emmc_burn_android_var_som_mx8x_c0.lst \
    device/variscite/scripts/uuu_scripts/emmc_burn_android_var_som_mx8x_b0.lst:emmc_burn_android_var_som_mx8x_b0.lst

# -------@block_security-------
# Include keystore attestation keys and certificates.
ifeq ($(PRODUCT_IMX_TRUSTY),true)
-include $(IMX_SECURITY_PATH)/attestation/imx_attestation.mk
endif

# Copy rpmb test key and AVB test public key
ifeq ($(PRODUCT_IMX_TRUSTY),true)
PRODUCT_COPY_FILES += \
    $(CONFIG_REPO_PATH)/common/security/rpmb_key_test.bin:rpmb_key_test.bin \
    $(CONFIG_REPO_PATH)/common/security/testkey_public_rsa4096.bin:testkey_public_rsa4096.bin
endif

# hardware backed keymaster service
ifeq ($(PRODUCT_IMX_TRUSTY),true)
PRODUCT_PACKAGES += \
    android.hardware.security.keymint-service.rust.trusty
endif
# Keymaster HAL
PRODUCT_PACKAGES += \
    android.hardware.security.keymint-service-imx

# new gatekeeper HAL
PRODUCT_PACKAGES += \
    android.hardware.gatekeeper-service-imx

# Add Trusty OS backed gatekeeper and secure storage proxy
ifeq ($(PRODUCT_IMX_TRUSTY),true)
PRODUCT_PACKAGES += \
    android.hardware.gatekeeper-service.trusty \
    storageproxyd \
    imx_dek_extractor \
    imx_dek_inserter
endif

# Add oem unlocking option in settings.
PRODUCT_PROPERTY_OVERRIDES += ro.frp.pst=/dev/block/by-name/presistdata

ifeq ($(PRODUCT_IMX_TRUSTY),true)
#Oemlock HAL support
PRODUCT_PACKAGES += \
    android.hardware.oemlock-service.imx
endif

PRODUCT_PACKAGES += \
    android.hardware.oemlock-service-software.imx

# Specify rollback index for boot and vbmeta partition
ifneq ($(AVB_RBINDEX),)
BOARD_AVB_ROLLBACK_INDEX := $(AVB_RBINDEX)
else
BOARD_AVB_ROLLBACK_INDEX := 0
endif

ifneq ($(AVB_BOOT_RBINDEX),)
BOARD_AVB_BOOT_ROLLBACK_INDEX := $(AVB_BOOT_RBINDEX)
else
BOARD_AVB_BOOT_ROLLBACK_INDEX := 0
endif

# ONLY devices that meet the CDD's requirements may declare these features
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.audio.output.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.audio.output.xml \
    frameworks/native/data/etc/android.hardware.bluetooth_le.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.bluetooth_le.xml \
    frameworks/native/data/etc/android.hardware.ethernet.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.ethernet.xml \
    frameworks/native/data/etc/android.hardware.screen.landscape.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.screen.landscape.xml \
    frameworks/native/data/etc/android.hardware.touchscreen.multitouch.distinct.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.touchscreen.multitouch.distinct.xml \
    frameworks/native/data/etc/android.hardware.touchscreen.multitouch.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.touchscreen.multitouch.xml \
    frameworks/native/data/etc/android.hardware.touchscreen.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.touchscreen.xml \
    frameworks/native/data/etc/android.hardware.usb.accessory.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.usb.accessory.xml \
    frameworks/native/data/etc/android.hardware.usb.host.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.usb.host.xml \
    frameworks/native/data/etc/android.hardware.vulkan.level-0.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.vulkan.level-0.xml \
    frameworks/native/data/etc/android.hardware.vulkan.version-1_3.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.vulkan.version-1_3.xml \
    frameworks/native/data/etc/android.software.vulkan.deqp.level-2024-03-01.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.vulkan.deqp.level.xml \
    frameworks/native/data/etc/android.software.opengles.deqp.level-2024-03-01.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.opengles.deqp.level.xml \
    frameworks/native/data/etc/android.hardware.wifi.direct.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.wifi.direct.xml \
    frameworks/native/data/etc/android.hardware.wifi.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.wifi.xml \
    frameworks/native/data/etc/android.hardware.wifi.passpoint.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.wifi.passpoint.xml \
    frameworks/native/data/etc/android.software.backup.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.backup.xml \
    frameworks/native/data/etc/android.software.midi.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.midi.xml \
    frameworks/native/data/etc/android.software.sip.voip.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.sip.voip.xml \
    frameworks/native/data/etc/android.software.verified_boot.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.verified_boot.xml \
    frameworks/native/data/etc/android.software.voice_recognizers.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.voice_recognizers.xml \
    frameworks/native/data/etc/android.software.activities_on_secondary_displays.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.activities_on_secondary_displays.xml \
    frameworks/native/data/etc/android.software.picture_in_picture.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.picture_in_picture.xml \
    frameworks/native/data/etc/android.software.credentials.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.credentials.xml

ifneq ($(AVB_INIT_BOOT_RBINDEX),)
BOARD_AVB_INIT_BOOT_ROLLBACK_INDEX := $(AVB_INIT_BOOT_RBINDEX)
else
BOARD_AVB_INIT_BOOT_ROLLBACK_INDEX := 0
endif

$(call  inherit-product-if-exists, vendor/nxp-private/security/nxp_security.mk)

# Resume on Reboot support
PRODUCT_PACKAGES += \
    android.hardware.rebootescrow-service.default

PRODUCT_PROPERTY_OVERRIDES += \
    ro.rebootescrow.device=/dev/block/pmem0

#DRM Widevine 1.4 L3 support
PRODUCT_PACKAGES += \
    android.hardware.drm-service.clearkey \
    libwvdrmcryptoplugin \
    libwvaidl

TARGET_BUILD_WIDEVINE :=
TARGET_BUILD_WIDEVINE_USE_PREBUILT := true

$(call inherit-product-if-exists, vendor/nxp-private/widevine/apex/device.mk)

# -------@block_audio-------

# Audio card json
PRODUCT_COPY_FILES += \
    $(IMX_DEVICE_PATH)/wm8904_config.json:$(TARGET_COPY_OUT_VENDOR)/etc/configs/audio/wm8904_config.json \
    $(CONFIG_REPO_PATH)/common/audio-json/cdnhdmi_config.json:$(TARGET_COPY_OUT_VENDOR)/etc/configs/audio/cdnhdmi_config.json \
    $(CONFIG_REPO_PATH)/common/audio-json/btsco_config.json:$(TARGET_COPY_OUT_VENDOR)/etc/configs/audio/btsco_config.json \
    $(CONFIG_REPO_PATH)/common/audio-json/readme.txt:$(TARGET_COPY_OUT_VENDOR)/etc/configs/audio/readme.txt

PRODUCT_COPY_FILES += \
    $(NXP_DEVICE_PATH)/audio_effects.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio_effects.xml \
    $(NXP_DEVICE_PATH)/audio_policy_configuration.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio_policy_configuration.xml

# Audio SOF firmware and tplg files
PRODUCT_COPY_FILES += \
    $(FSL_PROPRIETARY_PATH)/fsl-proprietary/sof/sof-tplg/sof-imx8-wm8960.tplg:$(TARGET_COPY_OUT_VENDOR)/firmware/imx/sof-tplg/sof-imx8-wm8960.tplg \
    $(FSL_PROPRIETARY_PATH)/fsl-proprietary/sof/sof-tplg/sof-imx8-compr-wm8960.tplg:$(TARGET_COPY_OUT_VENDOR)/firmware/imx/sof-tplg/sof-imx8-compr-wm8960.tplg \
    $(FSL_PROPRIETARY_PATH)/fsl-proprietary/sof/sof-gcc/sof-imx8x.ldc:$(TARGET_COPY_OUT_VENDOR)/firmware/imx/sof/sof-imx8x.ldc \
    $(FSL_PROPRIETARY_PATH)/fsl-proprietary/sof/sof-gcc/sof-imx8x.ri:$(TARGET_COPY_OUT_VENDOR)/firmware/imx/sof/sof-imx8x.ri

PRODUCT_CHARACTERISTICS := tablet

# -------@block_camera-------
PRODUCT_COPY_FILES += \
    $(IMX_DEVICE_PATH)/camera_config_imx8qxp.json:$(TARGET_COPY_OUT_VENDOR)/etc/configs/camera_config_imx8qxp.json \
    $(IMX_DEVICE_PATH)/camera_config_imx8qxp_logic.json:$(TARGET_COPY_OUT_VENDOR)/etc/configs/camera_config_imx8qxp_logic.json \
    $(IMX_DEVICE_PATH)/external_camera_config.xml:$(TARGET_COPY_OUT_VENDOR)/etc/external_camera_config.xml

PRODUCT_SOONG_NAMESPACES += hardware/google/camera
PRODUCT_SOONG_NAMESPACES += vendor/nxp-opensource/imx/camera

# -------@block_display-------
PRODUCT_AAPT_CONFIG += xlarge large tvdpi hdpi xhdpi xxhdpi

# -----some limiataion of overlay/g2d in hwcomposer3 --------
SOONG_CONFIG_NAMESPACES += nxp_hwc
SOONG_CONFIG_nxp_hwc += g2d_ip
SOONG_CONFIG_nxp_hwc_g2d_ip := DPU

# HWC3 HAL
PRODUCT_PACKAGES += \
    android.hardware.graphics.composer3-service.imx

# define frame buffer count
PRODUCT_DEFAULT_PROPERTY_OVERRIDES += \
    ro.surface_flinger.max_frame_buffer_acquired_buffers=4

# disable frame rate override
PRODUCT_DEFAULT_PROPERTY_OVERRIDES += \
    ro.surface_flinger.enable_frame_rate_override=false

# Gralloc HAL
PRODUCT_PACKAGES += \
    android.hardware.graphics.allocator-service.imx \
    mapper.imx

# 2d test
ifneq (,$(filter userdebug eng, $(TARGET_BUILD_VARIANT)))
PRODUCT_PACKAGES += 2d-test
endif

PRODUCT_PACKAGES += \
        libg2d-dpu \
        libg2d-opencl

PRODUCT_COPY_FILES += \
    vendor/nxp/linux-firmware-imx/firmware/hdmi/cadence/hdmitxfw.bin:$(TARGET_COPY_OUT_VENDOR)/firmware/hdmitxfw.bin

PRODUCT_COPY_FILES += \
    $(IMX_DEVICE_PATH)/input-port-associations.xml:$(TARGET_COPY_OUT_VENDOR)/etc/input-port-associations.xml
# -------@block_gpu-------
PRODUCT_PACKAGES += \
        libEGL_VIVANTE \
        libGLESv1_CM_VIVANTE \
        libGLESv2_VIVANTE \
        gralloc_viv.$(TARGET_BOARD_PLATFORM) \
        libGAL \
        libGLSLC \
        libVSC \
        libg2d-viv \
        libgpuhelper \
        libSPIRV_viv \
        libvulkan_VIVANTE \
        vulkan.$(TARGET_BOARD_PLATFORM) \
        libCLC \
        libOpenCL \
        libOpenVX \
        libOpenVXU \
        libNNVXCBinary-evis \
        libNNVXCBinary-evis2 \
        libOvx12VXCBinary-evis \
        libOvx12VXCBinary-evis2 \
        libNNGPUBinary-evis \
        libNNGPUBinary-evis2 \
        libNNGPUBinary-lite \
        libNNGPUBinary-ulite \
        libNNGPUBinary-nano \
        libNNArchPerf \
        libarchmodelSw

PRODUCT_VENDOR_PROPERTIES += \
    ro.hardware.egl = VIVANTE

# GPU openCL g2d
PRODUCT_COPY_FILES += \
    $(IMX_PATH)/imx/opencl-2d/cl_g2d.cl:$(TARGET_COPY_OUT_VENDOR)/etc/cl_g2d.cl

# GPU openCL SDK header file
-include $(FSL_PROPRIETARY_PATH)/fsl-proprietary/include/CL/cl_sdk.mk

# -------@block_vpu-------
# VPU files
PRODUCT_COPY_FILES += \
	$(LINUX_FIRMWARE_IMX_PATH)/linux-firmware-imx/firmware/vpu/vpu_fw_imx8_dec.bin:$(TARGET_COPY_OUT_VENDOR)/firmware/amphion/vpu/vpu_fw_imx8_dec.bin \
	$(LINUX_FIRMWARE_IMX_PATH)/linux-firmware-imx/firmware/vpu/vpu_fw_imx8_enc.bin:$(TARGET_COPY_OUT_VENDOR)/firmware/amphion/vpu/vpu_fw_imx8_enc.bin
# -------@block_wifi-------
PRODUCT_COPY_FILES += \
    $(CONFIG_REPO_PATH)/common/wifi/p2p_supplicant_overlay.conf:$(TARGET_COPY_OUT_VENDOR)/etc/wifi/p2p_supplicant_overlay.conf \
    $(CONFIG_REPO_PATH)/common/wifi/wpa_supplicant_overlay.conf:$(TARGET_COPY_OUT_VENDOR)/etc/wifi/wpa_supplicant_overlay.conf

PRODUCT_PACKAGES += \
    wificond

# WiFi HAL
PRODUCT_PACKAGES += \
    android.hardware.wifi-service

# WiFi RRO
PRODUCT_PACKAGES += \
    WifiOverlay

# Sterling LWB / LWB5 wifi and bluetooth combo Firmware
PRODUCT_COPY_FILES += \
    $(BCM_FIRMWARE_PATH)/brcm/BCM4335C0.hcd:vendor/firmware/brcm/BCM4335C0.hcd \
    $(BCM_FIRMWARE_PATH)/brcm/BCM43430A1.hcd:vendor/firmware/brcm/BCM43430A1.hcd \
    $(BCM_FIRMWARE_PATH)/brcm/brcmfmac4339-sdio.bin:vendor/firmware/brcm/brcmfmac4339-sdio.bin \
    $(BCM_FIRMWARE_PATH)/brcm/brcmfmac4339-sdio.txt:vendor/firmware/brcm/brcmfmac4339-sdio.txt \
    $(BCM_FIRMWARE_PATH)/brcm/brcmfmac43430-sdio.bin:vendor/firmware/brcm/brcmfmac43430-sdio.bin \
    $(BCM_FIRMWARE_PATH)/brcm/brcmfmac43430-sdio.txt:vendor/firmware/brcm/brcmfmac43430-sdio.txt \
    $(BCM_FIRMWARE_PATH)/brcm/brcmfmac43430-sdio.clm_blob:vendor/firmware/brcm/brcmfmac43430-sdio.clm_blob

# Wifi regulatory
PRODUCT_COPY_FILES += \
    external/wireless-regdb/regulatory.db:$(TARGET_COPY_OUT_VENDOR)/firmware/regulatory.db \
    external/wireless-regdb/regulatory.db.p7s:$(TARGET_COPY_OUT_VENDOR)/firmware/regulatory.db.p7s

# -------@block_bluetooth-------
# Bluetooth HAL
TARGET_USES_VND_LIBBT := false

ifeq ($(TARGET_USES_VND_LIBBT),true)
PRODUCT_PACKAGES += \
    android.hardware.bluetooth \
    android.hardware.bluetooth-service.default.nxp
else
PRODUCT_PACKAGES += \
    android.hardware.bluetooth-service.default
endif

# Bluetooth LE Audio
PRODUCT_PRODUCT_PROPERTIES += \
    ro.bluetooth.leaudio_offload.supported=false \
    persist.bluetooth.leaudio_offload.disabled=false \
    ro.bluetooth.leaudio_switcher.supported=true

PRODUCT_COPY_FILES += \
    vendor/nxp/linux-firmware-imx/firmware/hdmi/cadence/hdmitxfw.bin:$(TARGET_COPY_OUT_VENDOR)/firmware/hdmitxfw.bin \
    vendor/nxp/linux-firmware-imx/firmware/hdmi/cadence/dpfw.bin:$(TARGET_COPY_OUT_VENDOR)/firmware/dpfw.bin

# -------@block_usb-------
# Usb HAL
PRODUCT_PACKAGES += \
    android.hardware.usb-service.imx \
    android.hardware.usb.gadget-service.imx

PRODUCT_COPY_FILES += \
    $(IMX_DEVICE_PATH)/init.usb.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/hw/init.nxp.usb.rc

# -------@block_multimedia_codec-------
# Vendor seccomp policy files for media components:
PRODUCT_COPY_FILES += \
    $(IMX_DEVICE_PATH)/seccomp/mediaextractor-seccomp.policy:vendor/etc/seccomp_policy/mediaextractor.policy \
    $(IMX_DEVICE_PATH)/seccomp/mediacodec-seccomp.policy:vendor/etc/seccomp_policy/mediacodec.policy

ifeq ($(PREBUILT_FSL_IMX_CODEC),true)
ifneq ($(IMX_BUILD_32BIT_ROOTFS),true)
INSTALL_64BIT_LIBRARY := true
endif
-include $(FSL_RESTRICTED_CODEC_PATH)/fsl-restricted-codec/imx_dsp/imx_dsp_8q.mk
endif

# -------@block_neural_network-------
# Neural Network HAL and Lib
PRODUCT_PACKAGES += \
    libtim-vx \
    libVsiSupportLibrary \
    android.hardware.neuralnetworks-shell-service-imx

# Tensorflow lite camera demo
PRODUCT_PACKAGES += \
                    tflitecamerademo

# imx8 sensor HAL libs.
PRODUCT_PACKAGES += \
    android.hardware.sensors-service.multihal \
    android.hardware.sensors@2.1-nxp-IIO-Subhal

PRODUCT_COPY_FILES += \
    $(IMX_PATH)/imx/sensor/config/sensor_hal_configuration.xml:$(TARGET_COPY_OUT_VENDOR)/etc/sensors/sensor_hal_configuration.xml \
    $(IMX_PATH)/imx/sensor/hals.conf:$(TARGET_COPY_OUT_VENDOR)/etc/sensors/hals.conf

# Copy device related config and binary to board
PRODUCT_COPY_FILES += \
    $(IMX_DEVICE_PATH)/init.imx8qxp.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/hw/init.nxp.imx8qxp.rc

PRODUCT_COPY_FILES += \
    $(IMX_DEVICE_PATH)/required_hardware.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/required_hardware.xml
ifeq ($(TARGET_USE_VENDOR_BOOT),true)
  PRODUCT_COPY_FILES += \
    $(IMX_DEVICE_PATH)/init.recovery.nxp.rc:$(TARGET_COPY_OUT_VENDOR_RAMDISK)/init.recovery.nxp.rc
else
  PRODUCT_COPY_FILES += \
    $(IMX_DEVICE_PATH)/init.recovery.nxp.rc:root/init.recovery.nxp.rc
endif

# Display Device Config
PRODUCT_COPY_FILES += \
    device/nxp/imx8q/displayconfig/display_port_1.xml:$(TARGET_COPY_OUT_VENDOR)/etc/displayconfig/display_port_1.xml

# ONLY devices that meet the CDD's requirements may declare these features
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.audio.output.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.audio.output.xml \
    frameworks/native/data/etc/android.hardware.bluetooth.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.bluetooth.xml \
    frameworks/native/data/etc/android.hardware.bluetooth_le.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.bluetooth_le.xml \
    frameworks/native/data/etc/android.hardware.ethernet.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.ethernet.xml \
    frameworks/native/data/etc/android.hardware.screen.landscape.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.screen.landscape.xml \
    frameworks/native/data/etc/android.hardware.touchscreen.multitouch.distinct.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.touchscreen.multitouch.distinct.xml \
    frameworks/native/data/etc/android.hardware.touchscreen.multitouch.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.touchscreen.multitouch.xml \
    frameworks/native/data/etc/android.hardware.touchscreen.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.touchscreen.xml \
    frameworks/native/data/etc/android.hardware.usb.accessory.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.usb.accessory.xml \
    frameworks/native/data/etc/android.hardware.usb.host.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.usb.host.xml \
    frameworks/native/data/etc/android.hardware.vulkan.level-0.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.vulkan.level-0.xml \
    frameworks/native/data/etc/android.hardware.vulkan.version-1_3.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.vulkan.version-1_3.xml \
    frameworks/native/data/etc/android.software.vulkan.deqp.level-2024-03-01.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.vulkan.deqp.level.xml \
    frameworks/native/data/etc/android.software.opengles.deqp.level-2024-03-01.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.opengles.deqp.level.xml \
    frameworks/native/data/etc/android.hardware.wifi.direct.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.wifi.direct.xml \
    frameworks/native/data/etc/android.hardware.wifi.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.wifi.xml \
    frameworks/native/data/etc/android.hardware.wifi.passpoint.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.wifi.passpoint.xml \
    frameworks/native/data/etc/android.software.backup.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.backup.xml \
    frameworks/native/data/etc/android.software.midi.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.midi.xml \
    frameworks/native/data/etc/android.software.sip.voip.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.sip.voip.xml \
    frameworks/native/data/etc/android.software.verified_boot.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.verified_boot.xml \
    frameworks/native/data/etc/android.software.voice_recognizers.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.voice_recognizers.xml \
    frameworks/native/data/etc/android.software.activities_on_secondary_displays.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.activities_on_secondary_displays.xml \
    frameworks/native/data/etc/android.software.picture_in_picture.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.picture_in_picture.xml \
    frameworks/native/data/etc/android.software.credentials.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.credentials.xml

PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.sensor.accelerometer.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.accelerometer.xml \
    frameworks/native/data/etc/android.hardware.sensor.ambient_temperature.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.ambient_temperature.xml \
    frameworks/native/data/etc/android.hardware.sensor.barometer.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.barometer.xml \
    frameworks/native/data/etc/android.hardware.sensor.compass.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.compass.xml \
    frameworks/native/data/etc/android.hardware.sensor.gyroscope.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.gyroscope.xml \
    frameworks/native/data/etc/android.hardware.sensor.light.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.light.xml \
    frameworks/native/data/etc/android.hardware.camera.external.xml:vendor/etc/permissions/android.hardware.camera.external.xml \
    frameworks/native/data/etc/android.hardware.camera.front.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.camera.front.xml \
    frameworks/native/data/etc/android.hardware.camera.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.camera.xml \
    frameworks/native/data/etc/android.software.app_widgets.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.app_widgets.xml \
    frameworks/native/data/etc/android.software.device_admin.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.device_admin.xml \
    frameworks/native/data/etc/android.software.managed_users.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.managed_users.xml \
    frameworks/native/data/etc/android.software.print.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.print.xml

PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.screen.portrait.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.screen.portrait.xml

# Keymint configuration
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.software.device_id_attestation.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.device_id_attestation.xml

# Included GMS package
ifeq ($(filter TRUE true 1,$(IMX_BUILD_32BIT_ROOTFS) $(IMX_BUILD_32BIT_64BIT_ROOTFS)),)
$(call inherit-product-if-exists, vendor/partner_gms/products/gms_64bit_only.mk)
else
$(call inherit-product-if-exists, vendor/partner_gms/products/gms.mk)
endif
PRODUCT_SOONG_NAMESPACES += vendor/partner_gms

PRODUCT_PACKAGES += \
    privapp_whitelist_com.android.emergency

# -------@block_cm_rpmsg-------
PRODUCT_COPY_FILES += \
    $(IMX_DEVICE_PATH)/cm_rpmsg_lite_pingpong_rtos_linux_remote_m40.bin.debug:cm_rpmsg_lite_pingpong_rtos_linux_remote_m40.bin.debug \
    $(IMX_DEVICE_PATH)/cm_rpmsg_lite_pingpong_rtos_linux_remote_m40.elf.debug:$(TARGET_COPY_OUT_VENDOR)/firmware/cm_rpmsg_lite_pingpong_rtos_linux_remote_m40.elf.debug
