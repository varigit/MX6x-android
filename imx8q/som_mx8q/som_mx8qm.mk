-include device/variscite/imx8q/som_mx8q/som_mx8q_common.mk

PRODUCT_NAME := som_mx8qm
PRODUCT_DEVICE := som_mx8q

# Broadcom BT
BOARD_BLUETOOTH_BDROID_BUILDCFG_INCLUDE_DIR := $(IMX_DEVICE_PATH)/bluetooth/qm
BOARD_CUSTOM_BT_CONFIG := $(BOARD_BLUETOOTH_BDROID_BUILDCFG_INCLUDE_DIR)/vnd_config.txt
BOARD_HAVE_BLUETOOTH_BCM := true
PRODUCT_COPY_FILES += \
       $(IMX_DEVICE_PATH)/bluetooth/qm/bt_vendor.conf:vendor/etc/bluetooth/bt_vendor.conf

PRODUCT_COPY_FILES += \
    $(IMX_DEVICE_PATH)/init.imx8qm.init.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/hw/init.nxp.rc \
    $(FSL_PROPRIETARY_PATH)/linux-firmware-imx/firmware/hdmi/cadence/dpfw.bin:vendor/firmware/hdp/dpfw.bin \
    $(FSL_PROPRIETARY_PATH)/linux-firmware-imx/firmware/hdmi/cadence/hdmitxfw.bin:vendor/firmware/hdp/hdmitxfw.bin \
    $(FSL_PROPRIETARY_PATH)/linux-firmware-imx/firmware/hdmi/cadence/hdmirxfw.bin:vendor/firmware/hdp/hdmirxfw.bin \
    $(IMX_DEVICE_PATH)/init.imx8qm.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/hw/init.nxp.imx8qm.rc \
    $(IMX_DEVICE_PATH)/ueventd.imx8qm.nxp.rc:$(TARGET_COPY_OUT_VENDOR)/etc/ueventd.rc

BOARD_PREBUILT_DTBOIMAGE := out/target/product/som_mx8q/dtbo-imx8qm-var-som-lvds.img


ifeq ($(TARGET_USE_DYNAMIC_PARTITIONS),true)
TARGET_BOARD_DTS_CONFIG := \
	imx8qm-var-som-dp:imx8qm-var-som-symphony-dp.dtb \
	imx8qm-var-som-dp-m4:imx8qm-var-som-symphony-dp-m4.dtb \
	imx8qm-var-som-hdmi:imx8qm-var-som-symphony-hdmi.dtb \
	imx8qm-var-som-hdmi-m4:imx8qm-var-som-symphony-hdmi-m4.dtb \
	imx8qm-var-som-lvds:imx8qm-var-som-symphony-lvds.dtb \
	imx8qm-var-som-lvds-m4:imx8qm-var-som-symphony-lvds-m4.dtb \
	imx8qm-var-spear-dp:imx8qm-var-spear-sp8customboard-dp.dtb \
	imx8qm-var-spear-dp-m4:imx8qm-var-spear-sp8customboard-dp-m4.dtb \
	imx8qm-var-spear-hdmi:imx8qm-var-spear-sp8customboard-hdmi.dtb \
	imx8qm-var-spear-hdmi-m4:imx8qm-var-spear-sp8customboard-hdmi-m4.dtb \
	imx8qm-var-spear-lvds:imx8qm-var-spear-sp8customboard-lvds.dtb \
	imx8qm-var-spear-lvds-m4:imx8qm-var-spear-sp8customboard-lvds-m4.dtb \
	imx8qp-var-som-dp:imx8qp-var-som-symphony-dp.dtb \
	imx8qp-var-som-hdmi:imx8qp-var-som-symphony-hdmi.dtb \
	imx8qp-var-som-lvds:imx8qp-var-som-symphony-lvds.dtb \
	imx8qp-var-spear:imx8qp-var-spear-sp8customboard-dp.dtb \
	imx8qp-var-spear-hdmi:imx8qp-var-spear-sp8customboard-hdmi.dtb \
	imx8qp-var-spear-lvds:imx8qp-var-spear-sp8customboard-lvds.dtb \
	imx8qp-var-som-dp-m4:imx8qp-var-som-symphony-dp-m4.dtb \
	imx8qp-var-som-hdmi-m4:imx8qp-var-som-symphony-hdmi-m4.dtb \
	imx8qp-var-som-lvds-m4:imx8qp-var-som-symphony-lvds-m4.dtb \
	imx8qp-var-spear-dp-m4:imx8qp-var-spear-sp8customboard-dp-m4.dtb \
	imx8qp-var-spear-hdmi-m4:imx8qp-var-spear-sp8customboard-hdmi-m4.dtb \
	imx8qp-var-spear-lvds-m4:imx8qp-var-spear-sp8customboard-lvds-m4.dtb
endif

TARGET_BOOTLOADER_CONFIG := \
         imx8qm:imx8qm_var_som_android_defconfig \
         imx8qm-som-uuu:imx8qm_var_som_android_uuu_defconfig
