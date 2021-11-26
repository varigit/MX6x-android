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
    $(IMX_DEVICE_PATH)/init.imx8qm.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/hw/init.nxp.imx8qm.rc \
    $(IMX_DEVICE_PATH)/ueventd.nxp.8qm.rc:$(TARGET_COPY_OUT_VENDOR)/ueventd.rc

PRODUCT_COPY_FILES += \
device/variscite/imx8q/som_mx8q/freertos/8q/cm_rpmsg_lite_pingpong_rtos_linux_remote_m40.bin.debug:vendor/firmware/cm_rpmsg_lite_pingpong_rtos_linux_remote_m40.bin \
device/variscite/imx8q/som_mx8q/freertos/8q/cm_rpmsg_lite_pingpong_rtos_linux_remote_m40.elf.debug:vendor/firmware/cm_rpmsg_lite_pingpong_rtos_linux_remote_m40.elf \
device/variscite/imx8q/som_mx8q/freertos/8q/cm_rpmsg_lite_pingpong_rtos_linux_remote_m41.bin.debug:vendor/firmware/cm_rpmsg_lite_pingpong_rtos_linux_remote_m41.bin \
device/variscite/imx8q/som_mx8q/freertos/8q/cm_rpmsg_lite_pingpong_rtos_linux_remote_m41.elf.debug:vendor/firmware/cm_rpmsg_lite_pingpong_rtos_linux_remote_m41.elf

BOARD_PREBUILT_DTBOIMAGE := out/target/product/som_mx8q/dtbo-imx8qm-var-som-lvds.img

ifeq ($(TARGET_USE_DYNAMIC_PARTITIONS),true)
TARGET_BOARD_DTS_CONFIG := \
	imx8qm-var-som-dp:imx8qm-var-som-dp.dtb \
	imx8qm-var-som-dp-m4:imx8qm-var-som-dp-m4.dtb \
	imx8qm-var-som-hdmi:imx8qm-var-som-hdmi.dtb \
	imx8qm-var-som-hdmi-m4:imx8qm-var-som-hdmi-m4.dtb \
	imx8qm-var-som-lvds:imx8qm-var-som-lvds.dtb \
	imx8qm-var-som-lvds-m4:imx8qm-var-som-lvds-m4.dtb \
	imx8qm-var-spear-dp:imx8qm-var-spear-dp.dtb \
	imx8qm-var-spear-dp-m4:imx8qm-var-spear-dp-m4.dtb \
	imx8qm-var-spear-hdmi:imx8qm-var-spear-hdmi.dtb \
	imx8qm-var-spear-hdmi-m4:imx8qm-var-spear-hdmi-m4.dtb \
	imx8qm-var-spear-lvds:imx8qm-var-spear-lvds.dtb \
	imx8qm-var-spear-lvds-m4:imx8qm-var-spear-lvds-m4.dtb \
	imx8qp-var-som-dp:imx8qp-var-som-dp.dtb \
	imx8qp-var-som-hdmi:imx8qp-var-som-hdmi.dtb \
	imx8qp-var-som-lvds:imx8qp-var-som-lvds.dtb \
	imx8qp-var-spear:imx8qp-var-spear-dp.dtb \
	imx8qp-var-spear-hdmi:imx8qp-var-spear-hdmi.dtb \
	imx8qp-var-spear-lvds:imx8qp-var-spear-lvds.dtb \
	imx8qp-var-som-dp-m4:imx8qp-var-som-dp-m4.dtb \
	imx8qp-var-som-hdmi-m4:imx8qp-var-som-hdmi-m4.dtb \
	imx8qp-var-som-lvds-m4:imx8qp-var-som-lvds-m4.dtb \
	imx8qp-var-spear-dp-m4:imx8qp-var-spear-dp-m4.dtb \
	imx8qp-var-spear-hdmi-m4:imx8qp-var-spear-hdmi-m4.dtb \
	imx8qp-var-spear-lvds-m4:imx8qp-var-spear-lvds-m4.dtb
endif

TARGET_BOOTLOADER_CONFIG := \
         imx8qm-var-som:imx8qm_var_som_android_defconfig \
         imx8qm-var-som-uuu:imx8qm_var_som_android_uuu_defconfig

#WiFI BT script tools
PRODUCT_PACKAGES += \
    init.brcm.wifibt.8qm.sh
