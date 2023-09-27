-include device/variscite/imx8q/som_mx8q/som_mx8q_common.mk

PRODUCT_NAME := som_mx8qx
PRODUCT_DEVICE := som_mx8q

# Broadcom BT
BOARD_BLUETOOTH_BDROID_BUILDCFG_INCLUDE_DIR := $(IMX_DEVICE_PATH)/bluetooth/qx
BOARD_CUSTOM_BT_CONFIG := $(BOARD_BLUETOOTH_BDROID_BUILDCFG_INCLUDE_DIR)/vnd_config.txt
BOARD_HAVE_BLUETOOTH_BCM := true

PRODUCT_VENDOR_PROPERTIES += vendor.typec.legacy=true

PRODUCT_COPY_FILES += \
       $(IMX_DEVICE_PATH)/bluetooth/qm/bt_vendor.conf:vendor/etc/bluetooth/bt_vendor.conf

PRODUCT_COPY_FILES += \
    $(IMX_DEVICE_PATH)/init.imx8qxp.init.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/hw/init.nxp.rc \
    $(IMX_DEVICE_PATH)/init.imx8qxp.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/hw/init.nxp.imx8qxp.rc \
    $(IMX_DEVICE_PATH)/ueventd.imx8qxp.nxp.rc:$(TARGET_COPY_OUT_VENDOR)/etc/ueventd.rc

BOARD_PREBUILT_DTBOIMAGE := out/target/product/som_mx8q/dtbo-imx8qxp-var-som-symphony-wifi.img

ifeq ($(TARGET_USE_DYNAMIC_PARTITIONS),true)
TARGET_BOARD_DTS_CONFIG := \
        imx8qxp-var-som-symphony-sd:imx8qxp-var-som-symphony-sd.dtb \
        imx8qxp-var-som-symphony-sd-m4:imx8qxp-var-som-symphony-sd-m4.dtb \
        imx8qxp-var-som-symphony-wifi:imx8qxp-var-som-symphony-wifi.dtb \
        imx8qxp-var-som-symphony-wifi-m4:imx8qxp-var-som-symphony-wifi-m4.dtb
endif

TARGET_BOOTLOADER_CONFIG := \
	imx8qxp-var-som:imx8qxp_var_som_android_defconfig \
        imx8qxpb0-var-som:imx8qxp_var_som_android_defconfig \
        imx8qxp-var-som-uuu:imx8qxp_var_som_android_uuu_defconfig \
        imx8qxpb0-var-som-uuu:imx8qxp_var_som_android_uuu_defconfig
