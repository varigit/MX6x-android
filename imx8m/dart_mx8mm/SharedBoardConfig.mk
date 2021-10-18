KERNEL_NAME := Image
TARGET_KERNEL_ARCH := arm64

#Enable this to config 1GB ddr on evk_imx8mm
#LOW_MEMORY := true

#Enable this to include trusty support
PRODUCT_IMX_TRUSTY := true

#Enable this to disable product partition build.
#IMX_NO_PRODUCT_PARTITION := true

BOARD_VENDOR_KERNEL_MODULES +=     \
    $(KERNEL_OUT)/drivers/net/wireless/broadcom/brcm80211/brcmutil/brcmutil.ko \
    $(KERNEL_OUT)/drivers/net/wireless/broadcom/brcm80211/brcmfmac/brcmfmac.ko \
    $(KERNEL_OUT)/drivers/net/can/flexcan.ko \
    $(KERNEL_OUT)/drivers/net/can/spi/mcp251xfd/mcp251xfd.ko \
