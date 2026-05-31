# -------@block_infrastructure-------
CONFIG_REPO_PATH := device/nxp
CURRENT_FILE_PATH :=  $(lastword $(MAKEFILE_LIST))
IMX_DEVICE_PATH := $(strip $(patsubst %/, %, $(dir $(CURRENT_FILE_PATH))))
# IMX_DEVICE_PATH refers to the Variscite SoM folder
# NXP_DEVICE_PATH refers to the NXP EVK folder
NXP_DEVICE_PATH := $(CONFIG_REPO_PATH)/imx8m/evk_8mp

PRODUCT_ENFORCE_ARTIFACT_PATH_REQUIREMENTS := true
#Enable this to choose 32 bit user space build
IMX8_BUILD_32BIT_ROOTFS ?= false

# configs shared between uboot, kernel and Android rootfs
include $(IMX_DEVICE_PATH)/SharedBoardConfig.mk

-include device/variscite/common/imx_path/ImxPathConfig.mk
-include device/variscite/common/bootanimation/variscite_bootanimation_logo.mk
include $(CONFIG_REPO_PATH)/imx8m/ProductConfigCommon.mk


# -------@block_common_config-------
# Overrides
PRODUCT_NAME := dart_mx8mp
PRODUCT_DEVICE := dart_mx8mp
PRODUCT_MODEL := DART_MX8MP

TARGET_BOOTLOADER_BOARD_NAME := EVK

PRODUCT_CHARACTERISTICS := tablet

DEVICE_PACKAGE_OVERLAYS := $(IMX_DEVICE_PATH)/overlay

PRODUCT_COMPATIBLE_PROPERTY_OVERRIDE := true

PRODUCT_VENDOR_PROPERTIES += ro.soc.manufacturer=nxp
PRODUCT_VENDOR_PROPERTIES += ro.soc.model=IMX8MP
PRODUCT_VENDOR_PROPERTIES += ro.crypto.metadata_init_delete_all_keys.enabled=true
# -------@block_treble-------
PRODUCT_FULL_TREBLE_OVERRIDE := true

# -------@block_power-------
PRODUCT_SOONG_NAMESPACES += vendor/nxp-opensource/imx/power
PRODUCT_SOONG_NAMESPACES += hardware/google/pixel

PRODUCT_COPY_FILES += \
    $(NXP_DEVICE_PATH)/powerhint_imx8mp.json:$(TARGET_COPY_OUT_VENDOR)/etc/configs/powerhint_imx8mp.json

# Do not skip charger_not_need trigger by default
PRODUCT_DEFAULT_PROPERTY_OVERRIDES += \
    vendor.skip.charger_not_need=0

PRODUCT_PACKAGES += \
    android.hardware.power-service.imx

TARGET_VENDOR_PROP := $(NXP_DEVICE_PATH)/product.prop

# HDMI CEC AIDL HAL
PRODUCT_PACKAGES += \
    android.hardware.tv.hdmi.cec-service.imx \
    android.hardware.tv.hdmi.connection-service.imx \
    hdmi_cec_nxp

# Setup HDMI CEC as Playback Device
PRODUCT_PROPERTY_OVERRIDES += ro.hdmi.device_type=4 \
    persist.sys.hdmi.keep_awake=false

PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.hdmi.cec.xml:system/etc/permissions/android.hardware.hdmi.cec.xml

# Thermal HAL
PRODUCT_PACKAGES += \
    android.hardware.thermal-service.imx
PRODUCT_COPY_FILES += \
    $(NXP_DEVICE_PATH)/thermal_info_config_imx8mp.json:$(TARGET_COPY_OUT_VENDOR)/etc/configs/thermal_info_config_imx8mp.json

# -------@block_app-------
# Set permission for GMS packages
PRODUCT_COPY_FILES += \
	  $(CONFIG_REPO_PATH)/imx8m/permissions/privapp-permissions-imx.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/permissions/privapp.permissions-imx.xml

PRODUCT_COPY_FILES += \
    $(NXP_DEVICE_PATH)/app_whitelist.xml:system/etc/sysconfig/app_whitelist.xml

# -------@block_kernel_bootimg-------
# Enable this to support vendor boot and boot header v3, this would be a MUST for GKI
TARGET_USE_VENDOR_BOOT ?= true

# Allow LZ4 compression
BOARD_RAMDISK_USE_LZ4 := true

ifeq ($(LOADABLE_KERNEL_MODULE),true)
  BOARD_USES_GENERIC_KERNEL_IMAGE := true
  $(call inherit-product, $(SRC_TARGET_DIR)/product/generic_ramdisk.mk)
endif

# We load the fstab from device tree so this is not needed, but since no kernel modules are installed to vendor
# boot ramdisk so far, we need this step to generate the vendor-ramdisk folder or build process would fail. This
# can be deleted once we figure out what kernel modules should be put into the vendor boot ramdisk.
ifeq ($(TARGET_USE_VENDOR_BOOT),true)
PRODUCT_COPY_FILES += \
    $(IMX_DEVICE_PATH)/fstab.nxp:$(TARGET_COPY_OUT_VENDOR_RAMDISK)/first_stage_ramdisk/fstab.nxp
endif

PRODUCT_COPY_FILES += \
    $(NXP_DEVICE_PATH)/early.init.cfg:$(TARGET_COPY_OUT_VENDOR)/etc/early.init.cfg \
    $(LINUX_FIRMWARE_IMX_PATH)/linux-firmware-imx/firmware/sdma/sdma-imx7d.bin:$(TARGET_COPY_OUT_VENDOR_RAMDISK)/lib/firmware/imx/sdma/sdma-imx7d.bin \
    $(CONFIG_REPO_PATH)/common/init/init.insmod.sh:$(TARGET_COPY_OUT_VENDOR)/bin/init.insmod.sh \
    $(IMX_DEVICE_PATH)/ueventd.nxp.rc:$(TARGET_COPY_OUT_VENDOR)/etc/ueventd.rc

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

ifneq ($(filter TRUE true 1,$(IMX_OTA_POSTINSTALL)),)
  PRODUCT_PACKAGES += imx_ota_postinstall

  AB_OTA_POSTINSTALL_CONFIG += \
    RUN_POSTINSTALL_vendor=true \
    POSTINSTALL_PATH_vendor=bin/imx_ota_postinstall \
    FILESYSTEM_TYPE_vendor=erofs \
    POSTINSTALL_OPTIONAL_vendor=false

  PRODUCT_COPY_FILES += \
    $(OUT_DIR)/target/product/$(firstword $(PRODUCT_DEVICE))/obj/UBOOT_COLLECTION/spl-imx8mp-trusty-dual.bin:$(TARGET_COPY_OUT_VENDOR)/etc/bootloader0.img
  ifeq ($(BUILD_ENCRYPTED_BOOT),true)
    PRODUCT_COPY_FILES += \
      $(OUT_DIR)/target/product/$(firstword $(PRODUCT_DEVICE))/obj/UBOOT_COLLECTION/bootloader-imx8mp-var-dart-trusty-dual.img:$(TARGET_COPY_OUT_VENDOR)/etc/bootloader_ab.img
  endif
endif

# fastboot_imx_flashall scripts, imx-sdcard-partition script uuu_imx_android_flash scripts
PRODUCT_COPY_FILES += \
    $(CONFIG_REPO_PATH)/common/tools/fastboot_imx_flashall.bat:fastboot_imx_flashall.bat \
    $(CONFIG_REPO_PATH)/common/tools/fastboot_imx_flashall.sh:fastboot_imx_flashall.sh \
    $(CONFIG_REPO_PATH)/common/tools/imx-sdcard-partition.sh:imx-sdcard-partition.sh \
    $(CONFIG_REPO_PATH)/common/tools/uuu_imx_android_flash.bat:uuu_imx_android_flash.bat \
    $(CONFIG_REPO_PATH)/common/tools/uuu_imx_android_flash.sh:uuu_imx_android_flash.sh

# -------@block_security-------
# Include keystore attestation keys and certificates.
ifeq ($(PRODUCT_IMX_TRUSTY),true)
-include $(IMX_SECURITY_PATH)/attestation/imx_attestation.mk
endif

ifeq ($(PRODUCT_IMX_TRUSTY),true)
PRODUCT_COPY_FILES += \
    $(CONFIG_REPO_PATH)/common/security/rpmb_key_test.bin:rpmb_key_test.bin \
    $(CONFIG_REPO_PATH)/common/security/testkey_public_rsa4096.bin:testkey_public_rsa4096.bin
endif

# Keymaster HAL
ifeq ($(PRODUCT_IMX_TRUSTY),true)
PRODUCT_PACKAGES += \
    android.hardware.security.keymint-service.rust.trusty
endif

PRODUCT_PACKAGES += \
    android.hardware.security.keymint-service-imx

# Confirmation UI
ifeq ($(PRODUCT_IMX_TRUSTY),true)
PRODUCT_PACKAGES += \
    android.hardware.confirmationui-service.trusty
endif

# new gatekeeper HAL
PRODUCT_PACKAGES += \
    android.hardware.gatekeeper-service-imx

# Add oem unlocking option in settings.
PRODUCT_PROPERTY_OVERRIDES += ro.frp.pst=/dev/block/by-name/presistdata

ifeq ($(PRODUCT_IMX_TRUSTY),true)
#Oemlock HAL support
PRODUCT_PACKAGES += \
    android.hardware.oemlock-service.imx
endif

PRODUCT_PACKAGES += \
    android.hardware.oemlock-service-software.imx

# Add Trusty OS backed gatekeeper and secure storage proxy
ifeq ($(PRODUCT_IMX_TRUSTY),true)
PRODUCT_PACKAGES += \
    android.hardware.gatekeeper-service.trusty \
    storageproxyd \
    imx_dek_extractor \
    imx_dek_inserter
endif

# Secretkeeper HAL
PRODUCT_PACKAGES += \
    com.android.hardware.security.secretkeeper

ifeq ($(PRODUCT_IMX_TRUSTY),true)
PRODUCT_PACKAGES += \
    android.hardware.security.secretkeeper.trusty
endif

# Specify rollback index for boot and vbmeta partitions
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

#DRM Widevine 1.4 L1 support
PRODUCT_PACKAGES += \
    android.hardware.drm-service.clearkey \
    libwvdrmcryptoplugin \
    liboemcrypto

TARGET_BUILD_WIDEVINE :=
TARGET_BUILD_WIDEVINE_USE_PREBUILT := true

$(call inherit-product-if-exists, vendor/nxp-private/widevine/nxp_widevine_tee_8mp.mk)
$(call inherit-product-if-exists, vendor/nxp-private/widevine/apex/device.mk)

# -------@block_audio-------
# Audio card json
PRODUCT_COPY_FILES += \
    $(CONFIG_REPO_PATH)/common/audio-json/micfil_s32_config.json:$(TARGET_COPY_OUT_VENDOR)/etc/configs/audio/micfil_s32_config.json \
    $(CONFIG_REPO_PATH)/common/audio-json/hdmi_config.json:$(TARGET_COPY_OUT_VENDOR)/etc/configs/audio/hdmi_config.json \
    $(CONFIG_REPO_PATH)/common/audio-json/btsco_config.json:$(TARGET_COPY_OUT_VENDOR)/etc/configs/audio/btsco_config.json \
    $(CONFIG_REPO_PATH)/common/audio-json/readme.txt:$(TARGET_COPY_OUT_VENDOR)/etc/configs/audio/readme.txt


PRODUCT_COPY_FILES += \
    $(NXP_DEVICE_PATH)/audio_effects.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio_effects.xml \
    $(NXP_DEVICE_PATH)/usb_audio_policy_configuration-direct-output.xml:$(TARGET_COPY_OUT_VENDOR)/etc/usb_audio_policy_configuration-direct-output.xml

PRODUCT_COPY_FILES += \
    $(FSL_PROPRIETARY_PATH)/fsl-proprietary/mcu-sdk/imx8mp/imx8mp_mcu_demo.img:imx8mp_mcu_demo.img \
    $(IMX_DEVICE_PATH)/audio_policy_configuration.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio_policy_configuration.xml

# -------@block_camera-------
PRODUCT_COPY_FILES += \
    $(IMX_DEVICE_PATH)/camera_config_imx8mp-dual-ov5640.json:$(TARGET_COPY_OUT_VENDOR)/etc/configs/camera_config_imx8mp.json \
    $(IMX_DEVICE_PATH)/camera_config_imx8mp-dual-basler.json:$(TARGET_COPY_OUT_VENDOR)/etc/configs/camera_config_imx8mp-dual-basler.json \
    $(IMX_DEVICE_PATH)/camera_config_imx8mp-var-basler.json:$(TARGET_COPY_OUT_VENDOR)/etc/configs/camera_config_imx8mp-var-basler.json \
    $(NXP_DEVICE_PATH)/camera_config_imx8mp-4k-basler-ov5640.json:$(TARGET_COPY_OUT_VENDOR)/etc/configs/camera_config_imx8mp-4k-basler-ov5640.json \
    $(NXP_DEVICE_PATH)/camera_config_imx8mp-basler-ov5640.json:$(TARGET_COPY_OUT_VENDOR)/etc/configs/camera_config_imx8mp-basler-ov5640.json \
    $(NXP_DEVICE_PATH)/external_camera_config.xml:$(TARGET_COPY_OUT_VENDOR)/etc/external_camera_config.xml

PRODUCT_SOONG_NAMESPACES += hardware/google/camera
PRODUCT_SOONG_NAMESPACES += vendor/nxp-opensource/imx/camera

PRODUCT_PACKAGES += \
    media_profiles_8mp-ov5640.xml \
    media_profiles_8mp-ispsensor-ov5640.xml

# -------@block_display-------
PRODUCT_AAPT_CONFIG += xlarge large tvdpi hdpi xhdpi xxhdpi

# -----some limiataion of overlay/g2d in hwcomposer3 --------
SOONG_CONFIG_NAMESPACES += nxp_hwc
SOONG_CONFIG_nxp_hwc += g2d_ip
SOONG_CONFIG_nxp_hwc_g2d_ip := VIV

# HWC3 HAL
PRODUCT_PACKAGES += \
    android.hardware.graphics.composer3-service.imx

# define frame buffer count
PRODUCT_DEFAULT_PROPERTY_OVERRIDES += \
    ro.surface_flinger.max_frame_buffer_acquired_buffers=3

# set game default frame rate override
PRODUCT_DEFAULT_PROPERTY_OVERRIDES += \
    ro.surface_flinger.game_default_frame_rate_override=60

# Gralloc HAL
PRODUCT_PACKAGES += \
    android.hardware.graphics.allocator-service.imx \
    mapper.imx


# 2d test
ifneq (,$(filter userdebug eng, $(TARGET_BUILD_VARIANT)))
PRODUCT_PACKAGES += 2d-test
endif

PRODUCT_PACKAGES += \
    libg2d-opencl

# Multi-Display launcher
PRODUCT_PACKAGES += \
    MultiDisplay

# NOTE: The association is performed only for touch devices
# This file needs to be modified according to actual connection.
# One display port can be bound with multiple input ports (from Android User's Guide).
PRODUCT_COPY_FILES += \
    $(NXP_DEVICE_PATH)/input-port-associations.xml:$(TARGET_COPY_OUT_VENDOR)/etc/input-port-associations.xml

# By default, the secondary display in 'Mirror Mode',
# to have it in 'Extended Mode' set PRODUCT_MULTI_DISPLAY to true
PRODUCT_MULTI_DISPLAY ?= false

# Secondary Display Settings
# The secondary display will use the system's Home Screen Launcher.
# To have the mouse pointer associated with this display
# enable "Force Desktop Mode" in Developer Options or issue this command:
# 'settings put global force_desktop_mode_on_external_displays 1'
# and then reboot the device.
# Known issue: The navigation bar HOME and BACK button icons are invisible.
# There are still button mouse areas that receive mouse events in the left
# corner at the bottom of the screen.
ifeq ($(PRODUCT_MULTI_DISPLAY),true)
PRODUCT_COPY_FILES += \
    $(IMX_DEVICE_PATH)/display_settings.xml:$(TARGET_COPY_OUT_VENDOR)/etc/display_settings.xml
endif

# -------@block_gpu-------
PRODUCT_PACKAGES += \
    libEGL_VIVANTE \
    libGLESv1_CM_VIVANTE \
    libGLESv2_VIVANTE \
    gralloc_viv.$(TARGET_BOARD_PLATFORM) \
    libGAL \
    libGLSLC \
    libVSC \
    libgpuhelper \
    libSPIRV_viv \
    libvulkan_VIVANTE \
    vulkan.$(TARGET_BOARD_PLATFORM) \
    libCLC \
    libOpenCL \
    libg2d-viv \
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

# -------@block_wifi-------
PRODUCT_COPY_FILES += \
    $(CONFIG_REPO_PATH)/common/wifi/p2p_supplicant_overlay.conf:$(TARGET_COPY_OUT_VENDOR)/etc/wifi/p2p_supplicant_overlay.conf \
    $(CONFIG_REPO_PATH)/common/wifi/wpa_supplicant_overlay.conf:$(TARGET_COPY_OUT_VENDOR)/etc/wifi/wpa_supplicant_overlay.conf

# WiFi HAL
ifneq ($(TARGET_USES_BCM_WIFI),true)
PRODUCT_PACKAGES += \
    android.hardware.wifi-service
endif

PRODUCT_PACKAGES += \
    wificond

# WiFi RRO
PRODUCT_PACKAGES += \
    WifiOverlay

# NXP 8987 Wifi and Bluetooth Combo Firmware
# The firmware name is defined in wifi_mod_para_sd8987.conf
# If using WiFi and BT firmware separately, change the firmware name in wifi_mod_para_sd8987.conf to sd_w61x_v1.bin.se
# and the BT firmware will be loaded by the btnxpuart driver.
PRODUCT_COPY_FILES += \
    vendor/nxp/imx-firmware/nxp/FwImage_8987/sduart8987_combo.bin:vendor/firmware/sduart8987_combo.bin \
    vendor/nxp/imx-firmware/nxp/FwImage_IW612_SD/sduart_nw61x_v1.bin.se:vendor/firmware/sduart_nw61x_v1.bin.se \
    vendor/nxp/imx-firmware/nxp/FwImage_IW612_SD/uartspi_n61x_v1.bin.se:vendor/firmware/nxp/uartspi_n61x_v1.bin.se \
    vendor/nxp/imx-firmware/nxp/FwImage_IW612_SD/sd_w61x_v1.bin.se:vendor/firmware/sd_w61x_v1.bin.se \
    vendor/nxp/imx-firmware/nxp/mfguart/helper_uart_3000000.bin:vendor/firmware/helper_uart_3000000.bin \
    vendor/nxp/imx-firmware/nxp/android_wifi_mod_para.conf:vendor/firmware/wifi_mod_para_sd8987.conf

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

#nxp 8987 Bluetooth vendor config
PRODUCT_PACKAGES += \
    bt_vendor.conf

# -------@block_cm_rpmsg-------
PRODUCT_COPY_FILES += \
	device/variscite/imx8m/dart_mx8mp/cm_hello_world.bin.debug_dart:cm_hello_world.bin.debug_dart \
	device/variscite/imx8m/dart_mx8mp/cm_hello_world.bin.debug_som:cm_hello_world.bin.debug_som \
	device/variscite/imx8m/dart_mx8mp/cm_rpmsg_lite_pingpong_rtos_linux_remote.bin.debug_dart:cm_rpmsg_lite_pingpong_rtos_linux_remote.bin.debug_dart \
	device/variscite/imx8m/dart_mx8mp/cm_rpmsg_lite_pingpong_rtos_linux_remote.bin.debug_som:cm_rpmsg_lite_pingpong_rtos_linux_remote.bin.debug_som \
	device/variscite/imx8m/dart_mx8mp/cm_rpmsg_lite_str_echo_rtos.bin.debug_dart:cm_rpmsg_lite_str_echo_rtos.bin.debug_dart \
	device/variscite/imx8m/dart_mx8mp/cm_rpmsg_lite_str_echo_rtos.bin.debug_som:cm_rpmsg_lite_str_echo_rtos.bin.debug_som \
	device/variscite/imx8m/dart_mx8mp/cm_hello_world.elf.ddr_debug_dart:vendor/firmware/cm_hello_world.elf.ddr_debug_dart \
	device/variscite/imx8m/dart_mx8mp/cm_hello_world.elf.ddr_debug_som:vendor/firmware/cm_hello_world.elf.ddr_debug_som \
	device/variscite/imx8m/dart_mx8mp/cm_hello_world.elf.debug_dart:vendor/firmware/cm_hello_world.elf.debug_dart \
	device/variscite/imx8m/dart_mx8mp/cm_hello_world.elf.debug_som:vendor/firmware/cm_hello_world.elf.debug_som \
	device/variscite/imx8m/dart_mx8mp/cm_rpmsg_lite_pingpong_rtos_linux_remote.elf.ddr_debug_dart:vendor/firmware/cm_rpmsg_lite_pingpong_rtos_linux_remote.elf.ddr_debug_dart \
	device/variscite/imx8m/dart_mx8mp/cm_rpmsg_lite_pingpong_rtos_linux_remote.elf.ddr_debug_som:vendor/firmware/cm_rpmsg_lite_pingpong_rtos_linux_remote.elf.ddr_debug_som \
	device/variscite/imx8m/dart_mx8mp/cm_rpmsg_lite_pingpong_rtos_linux_remote.elf.debug_dart:vendor/firmware/cm_rpmsg_lite_pingpong_rtos_linux_remote.elf.debug_dart \
	device/variscite/imx8m/dart_mx8mp/cm_rpmsg_lite_pingpong_rtos_linux_remote.elf.debug_som:vendor/firmware/cm_rpmsg_lite_pingpong_rtos_linux_remote.elf.debug_som \
	device/variscite/imx8m/dart_mx8mp/cm_rpmsg_lite_str_echo_rtos_imxcm7.elf.ddr_debug_dart:vendor/firmware/cm_rpmsg_lite_str_echo_rtos_imxcm7.elf.ddr_debug_dart \
	device/variscite/imx8m/dart_mx8mp/cm_rpmsg_lite_str_echo_rtos_imxcm7.elf.ddr_debug_som:vendor/firmware/cm_rpmsg_lite_str_echo_rtos_imxcm7.elf.ddr_debug_som \
	device/variscite/imx8m/dart_mx8mp/cm_rpmsg_lite_str_echo_rtos_imxcm7.elf.debug_dart:vendor/firmware/cm_rpmsg_lite_str_echo_rtos_imxcm7.elf.debug_dart \
	device/variscite/imx8m/dart_mx8mp/cm_rpmsg_lite_str_echo_rtos_imxcm7.elf.debug_som:vendor/firmware/cm_rpmsg_lite_str_echo_rtos_imxcm7.elf.debug_som

# -------@block_usb-------
# Usb HAL
PRODUCT_PACKAGES += \
    android.hardware.usb-service.imx \
    android.hardware.usb.gadget-service.imx

PRODUCT_COPY_FILES += \
    $(NXP_DEVICE_PATH)/init.usb.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/hw/init.nxp.usb.rc

PRODUCT_DEFAULT_PROPERTY_OVERRIDES += \
    sys.usb.mtp.batchcancel=1

PRODUCT_PROPERTY_OVERRIDES += \
    vendor.typec.legacy=true

# -------@block_multimedia_codec-------
# Vendor seccomp policy files for media components:
PRODUCT_COPY_FILES += \
    $(NXP_DEVICE_PATH)/seccomp/mediacodec-seccomp.policy:vendor/etc/seccomp_policy/mediacodec.policy \
    $(NXP_DEVICE_PATH)/seccomp/mediaextractor-seccomp.policy:vendor/etc/seccomp_policy/mediaextractor.policy

PRODUCT_PACKAGES += \
    libg1 \
    libhantro \
    libcodec \
    libhantro_vc8000e

# imx c2 codec binary
PRODUCT_PACKAGES += \
    lib_vpu_wrapper \
    lib_imx_c2_videodec_common \
    lib_imx_c2_videodec \
    lib_imx_c2_videoenc_common \
    lib_imx_c2_videoenc \
    c2_component_register \
    c2_component_register_ms \
    c2_component_register_ra

# dsp decoder
PRODUCT_PACKAGES += \
    media_codecs_c2_dsp.xml \
    lib_dsp_bsac_dec \
    lib_dsp_codec_wrap \
    lib_dsp_mp3_dec \
    lib_dsp_wrap_arm12_android \
    lib_dsp_mp3_dec_ext \
    lib_dsp_codec_wrap_ext \
    lib_mp3d_wrap_dsp \
    c2_component_register_dsp


PRODUCT_PACKAGES += \
    DirectAudioPlayer

ifeq ($(PREBUILT_FSL_IMX_CODEC),true)
ifneq ($(IMX_BUILD_32BIT_ROOTFS),true)
INSTALL_64BIT_LIBRARY := true
endif
-include $(FSL_RESTRICTED_CODEC_PATH)/fsl-restricted-codec/imx_dsp/imx_dsp_8mp.mk
endif

# -------@block_memory-------
# Include Android Go config for low memory device.
ifeq ($(LOW_MEMORY),true)
$(call inherit-product, build/target/product/go_defaults.mk)
endif

# -------@block_neural_network-------
# Neural Network HAL and lib
PRODUCT_PACKAGES += \
    libtim-vx \
    libVsiSupportLibrary \
    android.hardware.neuralnetworks-shell-service-imx

# Tensorflow lite camera demo
PRODUCT_PACKAGES += \
                    tflitecamerademo

# -------@block_canbus_tools-------
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

# -------@block_var_mii-------------
PRODUCT_PACKAGES += \
    var-mii

# -------@block_miscellaneous-------
# Copy device related config and binary to board
PRODUCT_COPY_FILES += \
    $(NXP_DEVICE_PATH)/init.imx8mp.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/hw/init.nxp.imx8mp.rc \
    $(IMX_DEVICE_PATH)/init.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/hw/init.nxp.rc

ifeq ($(TARGET_USE_VENDOR_BOOT),true)
  PRODUCT_COPY_FILES += \
    $(NXP_DEVICE_PATH)/init.recovery.nxp.rc:$(TARGET_COPY_OUT_VENDOR_RAMDISK)/init.recovery.nxp.rc
else
  PRODUCT_COPY_FILES += \
    $(NXP_DEVICE_PATH)/init.recovery.nxp.rc:root/init.recovery.nxp.rc
endif

ifeq ($(POWERSAVE),true)
PRODUCT_COPY_FILES += \
    $(NXP_DEVICE_PATH)/required_hardware_powersave.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/required_hardware.xml
else
PRODUCT_COPY_FILES += \
    $(NXP_DEVICE_PATH)/required_hardware.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/required_hardware.xml
endif

# ONLY devices that meet the CDD's requirements may declare these features

ifneq ($(POWERSAVE),true)
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.camera.front.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.camera.front.xml \
    frameworks/native/data/etc/android.hardware.camera.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.camera.xml

PERMISSION_EXTCAM ?= true
ifeq ($(PERMISSION_EXTCAM),true)
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.camera.external.xml:vendor/etc/permissions/android.hardware.camera.external.xml
endif
endif

# Display Device Config
PRODUCT_COPY_FILES += \
    device/nxp/imx8m/displayconfig/display_port_1.xml:$(TARGET_COPY_OUT_VENDOR)/etc/displayconfig/display_port_1.xml

PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.audio.output.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.audio.output.xml \
    frameworks/native/data/etc/android.hardware.bluetooth.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.bluetooth.xml \
    frameworks/native/data/etc/android.hardware.bluetooth_le.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.bluetooth_le.xml \
    frameworks/native/data/etc/android.hardware.ethernet.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.ethernet.xml \
    frameworks/native/data/etc/android.hardware.screen.landscape.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.screen.landscape.xml \
    frameworks/native/data/etc/android.hardware.screen.portrait.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.screen.portrait.xml \
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
    frameworks/native/data/etc/android.software.app_widgets.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.app_widgets.xml \
    frameworks/native/data/etc/android.software.backup.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.backup.xml \
    frameworks/native/data/etc/android.software.device_admin.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.device_admin.xml \
    frameworks/native/data/etc/android.software.managed_users.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.managed_users.xml \
    frameworks/native/data/etc/android.software.midi.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.midi.xml \
    frameworks/native/data/etc/android.software.print.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.print.xml \
    frameworks/native/data/etc/android.software.sip.voip.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.sip.voip.xml \
    frameworks/native/data/etc/android.software.verified_boot.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.verified_boot.xml \
    frameworks/native/data/etc/android.software.voice_recognizers.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.voice_recognizers.xml \
    frameworks/native/data/etc/android.software.activities_on_secondary_displays.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.activities_on_secondary_displays.xml \
    frameworks/native/data/etc/android.software.picture_in_picture.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.picture_in_picture.xml \
    frameworks/native/data/etc/android.software.credentials.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.credentials.xml
    

# Boot Animation
#PRODUCT_COPY_FILES += \
    device/variscite/common/bootanimation/bootanimation-var1280.zip:system/media/bootanimation.zip

# trusty loadable apps
PRODUCT_COPY_FILES += \
    vendor/nxp/fsl-proprietary/uboot-firmware/imx8m/confirmationui-imx8mp.app:/vendor/firmware/tee/confirmationui.app

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

# isp block
# lib
PRODUCT_PACKAGES += \
    DAA3840_30MC_1080P \
    liba2dnr \
    liba3dnr \
    libadpcc \
    libadpf \
    libaec \
    libaee \
    libaflt \
    libaf \
    libahdr \
    libavs \
    libawb \
    libawdr3 \
    libbase64 \
    libbufferpool \
    libbufsync_ctrl \
    libcam_calibdb \
    libcam_device \
    libcam_engine \
    libcameric_drv \
    libcameric_reg_drv \
    libcim_ctrl \
    libcommon \
    libdaA3840_30mc \
    libdewarp_hal \
    libebase \
    libfpga \
    libhal \
    libi2c_drv \
    libibd \
    libisi \
    libmedia_server \
    libmim_ctrl \
    libmipi_drv \
    libmom_ctrl \
    libos08a20 \
    liboslayer \
    libov2775 \
    libsom_ctrl \
    libversion \
    libvom_ctrl \
    libvvdisplay_shared

# bin
PRODUCT_PACKAGES += \
    isp_media_server \
    vvext

# config for basler
PRODUCT_PACKAGES += \
    DAA3840_30MC_1080P-linear.xml \
    DAA3840_30MC_1080P-hdr.xml \
    DAA3840_30MC_4K-linear.xml \
    DAA3840_30MC_4K-hdr.xml \
    basler-Sensor0_Entry.cfg \
    basler-Sensor1_Entry.cfg \
    daA3840_30mc_1080P.json \
    daA3840_30mc_4K.json

# make sure /vendor/etc/configs/isp/ is created
    PRODUCT_PACKAGES += hollow

# config for audio selection
PRODUCT_PACKAGES += \
    var-audio-config \
    var-wm8904-config-carrier.json \
    var-wm8904-config.json

# Install the imx_rpmsg_pingpong.ko and imx_rpmsg_tty.ko
# modules to load when needed using insmod
PRODUCT_COPY_FILES += \
    $(OUT_DIR)/target/product/$(firstword $(PRODUCT_DEVICE))/obj/KERNEL_OBJ/drivers/rpmsg/imx_rpmsg_pingpong.ko:/vendor/imx_rpmsg_pingpong.ko \
    $(OUT_DIR)/target/product/$(firstword $(PRODUCT_DEVICE))/obj/KERNEL_OBJ/drivers/rpmsg/imx_rpmsg_tty.ko:/vendor/imx_rpmsg_tty.ko

# Add Virtualization support
$(call inherit-product, packages/modules/Virtualization/apex/product_packages.mk)

# Add imx private apps
$(call inherit-product-if-exists, vendor/nxp-private/imx-apps/imx-private-app.mk)

# Input Device Configuration files
PRODUCT_COPY_FILES += \
    $(IMX_DEVICE_PATH)/idc/generic_ft5x06__79_.idc:$(TARGET_COPY_OUT_VENDOR)/usr/idc/generic_ft5x06__79_.idc
