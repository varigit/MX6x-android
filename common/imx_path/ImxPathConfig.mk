# Reuse the Android 16 NXP component paths and select Variscite BSP sources.
include device/nxp/common/imx_path/ImxPathConfig.mk

VARISCITE_PATH := vendor/variscite
KERNEL_IMX_PATH := $(VARISCITE_PATH)
UBOOT_IMX_PATH := $(VARISCITE_PATH)
BCM_FIRMWARE_PATH := $(VARISCITE_PATH)/bcm_4343w_fw
# Variscite imx-mkimage packs DMEM with 4 KB padding (CONFIG_IMX_REDUCE_DMEM_PADDING).
IMX_MKIMAGE_PATH := $(VARISCITE_PATH)
