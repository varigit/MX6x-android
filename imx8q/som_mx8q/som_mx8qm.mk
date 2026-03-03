-include device/variscite/imx8q/som_mx8q/som_mx8q_common.mk

PRODUCT_NAME := som_mx8qm
PRODUCT_DEVICE := som_mx8q

SOONG_CONFIG_IMXPLUGIN_IMX_CAR = false

# Broadcom BT (kernel-managed via hci_uart_bcm serdev)
BOARD_BLUETOOTH_BDROID_BUILDCFG_INCLUDE_DIR := $(IMX_DEVICE_PATH)/bluetooth/qm

PRODUCT_VENDOR_PROPERTIES += vendor.typec.legacy=true

PRODUCT_COPY_FILES += \
    $(IMX_DEVICE_PATH)/init.imx8qm.init.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/hw/init.nxp.rc \
    $(IMX_DEVICE_PATH)/ueventd.imx8qm.nxp.rc:$(TARGET_COPY_OUT_VENDOR)/etc/ueventd.rc

# Touchscreen IDC
PRODUCT_COPY_FILES += \
    $(IMX_DEVICE_PATH)/idc/generic_ft5x06__79_.idc:$(TARGET_COPY_OUT_VENDOR)/usr/idc/generic_ft5x06__79_.idc

# Variscite UUU eMMC burning scripts
PRODUCT_COPY_FILES += \
    device/variscite/scripts/uuu_scripts/emmc_burn_android_imx8qm_var_som_symphony_hdmi.lst:emmc_burn_android_imx8qm_var_som_symphony_hdmi.lst \
    device/variscite/scripts/uuu_scripts/emmc_burn_android_imx8qm_var_som_symphony_lvds.lst:emmc_burn_android_imx8qm_var_som_symphony_lvds.lst \
    device/variscite/scripts/uuu_scripts/emmc_burn_android_imx8qm_var_som_symphony_dp.lst:emmc_burn_android_imx8qm_var_som_symphony_dp.lst \
    device/variscite/scripts/uuu_scripts/emmc_burn_android_imx8qm_spear_hdmi.lst:emmc_burn_android_imx8qm_spear_hdmi.lst \
    device/variscite/scripts/uuu_scripts/emmc_burn_android_imx8qm_spear_lvds.lst:emmc_burn_android_imx8qm_spear_lvds.lst \
    device/variscite/scripts/uuu_scripts/emmc_burn_android_imx8qm_spear_dp.lst:emmc_burn_android_imx8qm_spear_dp.lst \
    device/variscite/scripts/uuu_scripts/emmc_burn_android_imx8qm_var_som_symphony_1.x_hdmi.lst:emmc_burn_android_imx8qm_var_som_symphony_1.x_hdmi.lst \
    device/variscite/scripts/uuu_scripts/emmc_burn_android_imx8qm_var_som_symphony_1.x_lvds.lst:emmc_burn_android_imx8qm_var_som_symphony_1.x_lvds.lst \
    device/variscite/scripts/uuu_scripts/emmc_burn_android_imx8qm_var_som_symphony_1.x_dp.lst:emmc_burn_android_imx8qm_var_som_symphony_1.x_dp.lst

# -------@block_cm_rpmsg-------
# QM has two Cortex-M4 cores (m40 + m41); m40 is in som_mx8q_common.mk
PRODUCT_COPY_FILES += \
    $(IMX_DEVICE_PATH)/cm_rpmsg_lite_pingpong_rtos_linux_remote_m41.bin.debug:cm_rpmsg_lite_pingpong_rtos_linux_remote_m41.bin.debug \
    $(IMX_DEVICE_PATH)/cm_rpmsg_lite_pingpong_rtos_linux_remote_m41.elf.debug:$(TARGET_COPY_OUT_VENDOR)/firmware/cm_rpmsg_lite_pingpong_rtos_linux_remote_m41.elf.debug

BOARD_PREBUILT_DTBOIMAGE := $(OUT_DIR)/target/product/som_mx8q/dtbo-imx8qm-var-som-symphony-hdmi.img

# imx8qm Symphony
TARGET_BOARD_DTS_CONFIG := \
        imx8qm-var-som-symphony-hdmi:imx8qm-var-som-symphony-hdmi.dtb \
        imx8qm-var-som-symphony-hdmi-m4:imx8qm-var-som-symphony-hdmi-m4.dtb \
        imx8qm-var-som-symphony-lvds:imx8qm-var-som-symphony-lvds.dtb \
        imx8qm-var-som-symphony-lvds-m4:imx8qm-var-som-symphony-lvds-m4.dtb \
        imx8qm-var-som-symphony-dp:imx8qm-var-som-symphony-dp.dtb \
        imx8qm-var-som-symphony-dp-m4:imx8qm-var-som-symphony-dp-m4.dtb \
        imx8qm-var-som-symphony-1.x-hdmi:imx8qm-var-som-symphony-1.x-hdmi.dtb \
        imx8qm-var-som-symphony-1.x-hdmi-m4:imx8qm-var-som-symphony-1.x-hdmi-m4.dtb \
        imx8qm-var-som-symphony-1.x-lvds:imx8qm-var-som-symphony-1.x-lvds.dtb \
        imx8qm-var-som-symphony-1.x-lvds-m4:imx8qm-var-som-symphony-1.x-lvds-m4.dtb \
        imx8qm-var-som-symphony-1.x-dp:imx8qm-var-som-symphony-1.x-dp.dtb \
        imx8qm-var-som-symphony-1.x-dp-m4:imx8qm-var-som-symphony-1.x-dp-m4.dtb

# imx8qm Spear SP8CustomBoard
TARGET_BOARD_DTS_CONFIG += \
        imx8qm-var-spear-sp8customboard-hdmi:imx8qm-var-spear-sp8customboard-hdmi.dtb \
        imx8qm-var-spear-sp8customboard-hdmi-m4:imx8qm-var-spear-sp8customboard-hdmi-m4.dtb \
        imx8qm-var-spear-sp8customboard-lvds:imx8qm-var-spear-sp8customboard-lvds.dtb \
        imx8qm-var-spear-sp8customboard-lvds-m4:imx8qm-var-spear-sp8customboard-lvds-m4.dtb \
        imx8qm-var-spear-sp8customboard-dp:imx8qm-var-spear-sp8customboard-dp.dtb \
        imx8qm-var-spear-sp8customboard-dp-m4:imx8qm-var-spear-sp8customboard-dp-m4.dtb

# imx8qp Symphony
TARGET_BOARD_DTS_CONFIG += \
        imx8qp-var-som-symphony-hdmi:imx8qp-var-som-symphony-hdmi.dtb \
        imx8qp-var-som-symphony-hdmi-m4:imx8qp-var-som-symphony-hdmi-m4.dtb \
        imx8qp-var-som-symphony-lvds:imx8qp-var-som-symphony-lvds.dtb \
        imx8qp-var-som-symphony-lvds-m4:imx8qp-var-som-symphony-lvds-m4.dtb \
        imx8qp-var-som-symphony-dp:imx8qp-var-som-symphony-dp.dtb \
        imx8qp-var-som-symphony-dp-m4:imx8qp-var-som-symphony-dp-m4.dtb \
        imx8qp-var-som-symphony-1.x-hdmi:imx8qp-var-som-symphony-1.x-hdmi.dtb \
        imx8qp-var-som-symphony-1.x-hdmi-m4:imx8qp-var-som-symphony-1.x-hdmi-m4.dtb \
        imx8qp-var-som-symphony-1.x-lvds:imx8qp-var-som-symphony-1.x-lvds.dtb \
        imx8qp-var-som-symphony-1.x-lvds-m4:imx8qp-var-som-symphony-1.x-lvds-m4.dtb \
        imx8qp-var-som-symphony-1.x-dp:imx8qp-var-som-symphony-1.x-dp.dtb \
        imx8qp-var-som-symphony-1.x-dp-m4:imx8qp-var-som-symphony-1.x-dp-m4.dtb

# imx8qp Spear SP8CustomBoard
TARGET_BOARD_DTS_CONFIG += \
        imx8qp-var-spear-sp8customboard-hdmi:imx8qp-var-spear-sp8customboard-hdmi.dtb \
        imx8qp-var-spear-sp8customboard-hdmi-m4:imx8qp-var-spear-sp8customboard-hdmi-m4.dtb \
        imx8qp-var-spear-sp8customboard-lvds:imx8qp-var-spear-sp8customboard-lvds.dtb \
        imx8qp-var-spear-sp8customboard-lvds-m4:imx8qp-var-spear-sp8customboard-lvds-m4.dtb \
        imx8qp-var-spear-sp8customboard-dp:imx8qp-var-spear-sp8customboard-dp.dtb \
        imx8qp-var-spear-sp8customboard-dp-m4:imx8qp-var-spear-sp8customboard-dp-m4.dtb
