-include device/variscite/imx8q/som_mx8q/som_mx8q_common.mk

PRODUCT_NAME := som_mx8qx
PRODUCT_DEVICE := som_mx8q

SOONG_CONFIG_IMXPLUGIN_IMX_CAR = false

# Broadcom BT (kernel-managed via hci_uart_bcm serdev)
BOARD_BLUETOOTH_BDROID_BUILDCFG_INCLUDE_DIR := $(IMX_DEVICE_PATH)/bluetooth/qx

PRODUCT_VENDOR_PROPERTIES += vendor.typec.legacy=true

PRODUCT_COPY_FILES += \
    $(IMX_DEVICE_PATH)/init.imx8qxp.init.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/hw/init.nxp.rc \
    $(IMX_DEVICE_PATH)/ueventd.imx8qxp.nxp.rc:$(TARGET_COPY_OUT_VENDOR)/etc/ueventd.rc

# Touchscreen IDC
PRODUCT_COPY_FILES += \
    $(IMX_DEVICE_PATH)/idc/generic_ft5x06__79_.idc:$(TARGET_COPY_OUT_VENDOR)/usr/idc/generic_ft5x06__79_.idc

# Variscite UUU eMMC burning scripts
PRODUCT_COPY_FILES += \
    device/variscite/scripts/uuu_scripts/emmc_burn_android_var_som_mx8x_c0.lst:emmc_burn_android_var_som_mx8x_c0.lst \
    device/variscite/scripts/uuu_scripts/emmc_burn_android_var_som_mx8x_b0.lst:emmc_burn_android_var_som_mx8x_b0.lst \
    device/variscite/scripts/uuu_scripts/emmc_burn_android_var_som_mx8x_c0_symphony_1.x.lst:emmc_burn_android_var_som_mx8x_c0_symphony_1.x.lst \
    device/variscite/scripts/uuu_scripts/emmc_burn_android_var_som_mx8x_b0_symphony_1.x.lst:emmc_burn_android_var_som_mx8x_b0_symphony_1.x.lst

BOARD_PREBUILT_DTBOIMAGE := $(OUT_DIR)/target/product/som_mx8q/dtbo-imx8qxp-var-som-symphony-wifi.img

TARGET_BOARD_DTS_CONFIG := \
        imx8qxp-var-som-symphony-sd:imx8qxp-var-som-symphony-sd.dtb \
        imx8qxp-var-som-symphony-sd-m4:imx8qxp-var-som-symphony-sd-m4.dtb \
        imx8qxp-var-som-symphony-wifi:imx8qxp-var-som-symphony-wifi.dtb \
        imx8qxp-var-som-symphony-wifi-m4:imx8qxp-var-som-symphony-wifi-m4.dtb \
        imx8qxp-var-som-symphony-1.x-sd:imx8qxp-var-som-symphony-1.x-sd.dtb \
        imx8qxp-var-som-symphony-1.x-sd-m4:imx8qxp-var-som-symphony-1.x-sd-m4.dtb \
        imx8qxp-var-som-symphony-1.x-wifi:imx8qxp-var-som-symphony-1.x-wifi.dtb \
        imx8qxp-var-som-symphony-1.x-wifi-m4:imx8qxp-var-som-symphony-1.x-wifi-m4.dtb


