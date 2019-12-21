-include device/variscite/imx8q/som_mx8q/som_mx8q_common.mk

PRODUCT_NAME := som_mx8qm
PRODUCT_DEVICE := som_mx8q

# Broadcom BT
BOARD_BLUETOOTH_BDROID_BUILDCFG_INCLUDE_DIR := $(IMX_DEVICE_PATH)/bluetooth/qm
BOARD_CUSTOM_BT_CONFIG := $(BOARD_BLUETOOTH_BDROID_BUILDCFG_INCLUDE_DIR)/vnd_config.txt
BOARD_HAVE_BLUETOOTH_BCM := true
PRODUCT_COPY_FILES += \
       $(IMX_DEVICE_PATH)/bluetooth/qm/bt_vendor.conf:system/etc/bluetooth/bt_vendor.conf

PRODUCT_COPY_FILES += \
    $(FSL_PROPRIETARY_PATH)/linux-firmware-imx/firmware/hdmi/cadence/dpfw.bin:vendor/firmware/hdp/dpfw.bin \
    $(FSL_PROPRIETARY_PATH)/linux-firmware-imx/firmware/hdmi/cadence/hdmitxfw.bin:vendor/firmware/hdp/hdmitxfw.bin \
    $(FSL_PROPRIETARY_PATH)/linux-firmware-imx/firmware/hdmi/cadence/hdmirxfw.bin:vendor/firmware/hdp/hdmirxfw.bin \
    $(IMX_DEVICE_PATH)/init.imx8qm.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/hw/init.freescale.imx8qm.rc \
    $(IMX_DEVICE_PATH)/ueventd.freescale.8qm.rc:$(TARGET_COPY_OUT_VENDOR)/ueventd.rc \
    $(IMX_DEVICE_PATH)/init.brcm.wifibt.8qm.sh:vendor/bin/init.brcm.wifibt.sh

BOARD_PREBUILT_DTBOIMAGE := out/target/product/som_mx8q/dtbo-imx8qm-var-som-lvds.img

TARGET_BOARD_DTS_CONFIG := \
        imx8qm-var-som-dp:fsl-imx8qm-var-som-dp.dtb \
        imx8qm-var-som-hdmi:fsl-imx8qm-var-som-hdmi.dtb \
        imx8qm-var-som-lvds:fsl-imx8qm-var-som-lvds.dtb \
        imx8qm-var-spear-dp:fsl-imx8qm-var-spear-dp.dtb \
        imx8qm-var-spear-hdmi:fsl-imx8qm-var-spear-hdmi.dtb \
        imx8qm-var-spear-lvds:fsl-imx8qm-var-spear-lvds.dtb

TARGET_BOOTLOADER_CONFIG := \
        imx8qm:imx8qm_var_som_android_defconfig \
        imx8qm-som-uuu:imx8qm_var_som_android_uuu_defconfig

