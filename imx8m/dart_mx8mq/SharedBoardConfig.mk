KERNEL_NAME := Image
TARGET_KERNEL_ARCH := arm64

#Enable this to include trusty support
PRODUCT_IMX_TRUSTY := true

#Enable this to disable product partition build.
#IMX_NO_PRODUCT_PARTITION := true

# BCM fmac wifi driver module
BOARD_VENDOR_KERNEL_MODULES += \
    $(KERNEL_OUT)/drivers/net/wireless/broadcom/brcm80211/brcmutil/brcmutil.ko \
    $(KERNEL_OUT)/drivers/net/wireless/broadcom/brcm80211/brcmfmac/brcmfmac.ko \
    $(KERNEL_OUT)/drivers/mxc/hantro/hantrodec.ko \
    $(KERNEL_OUT)/drivers/mxc/hantro_845/hantrodec_845s.ko
