# after selecting the target by "lunch" command, TARGET_PRODUCT will be set
ifeq ($(TARGET_PRODUCT),mek_8q_car)
  PRODUCT_IMX_CAR := true
  PRODUCT_IMX_CAR_M4 := true
# i.MX8QM  will boot from A72 core on Android Auto by default.
# Remove below defination will make i.MX8QM boot from A53 core.
  IMX8QM_A72_BOOT := true
endif
ifeq ($(TARGET_PRODUCT),mek_8q_car2)
  PRODUCT_IMX_CAR := true
  # the env setting in mek_8q_car to make the build without M4 image
  PRODUCT_IMX_CAR_M4 := false
# i.MX8QM  will boot from A72 core on Android Auto by default.
# Remove below defination will make i.MX8QM boot from A53 core.
  IMX8QM_A72_BOOT := true
endif

ifeq ($(PRODUCT_IMX_CAR),true)
  KERNEL_NAME := Image.lz4
else
  KERNEL_NAME := Image
endif
TARGET_KERNEL_ARCH := arm64

#Enable this to include trusty support
PRODUCT_IMX_TRUSTY := true

#Enable this to disable product partition build.
#IMX_NO_PRODUCT_PARTITION := true

# BCM fmac wifi driver module
BOARD_VENDOR_KERNEL_MODULES += \
    $(KERNEL_OUT)/drivers/net/wireless/broadcom/brcm80211/brcmutil/brcmutil.ko \
    $(KERNEL_OUT)/drivers/net/wireless/broadcom/brcm80211/brcmfmac/brcmfmac.ko \
    $(KERNEL_OUT)/drivers/extcon/extcon-ptn5150.ko \
    $(KERNEL_OUT)/drivers/rtc/rtc-ds1307.ko \
    $(KERNEL_OUT)/drivers/staging/media/imx/imx8-media-dev.ko

ifeq ($(PRODUCT_IMX_CAR),true)
BOARD_VENDOR_KERNEL_MODULES += \
                            $(KERNEL_OUT)/drivers/usb/chipidea/ci_hdrc.ko \
                            $(KERNEL_OUT)/drivers/usb/chipidea/ci_hdrc_imx.ko \
                            $(KERNEL_OUT)/drivers/usb/chipidea/usbmisc_imx.ko \
                            $(KERNEL_OUT)/drivers/usb/common/ulpi.ko \
                            $(KERNEL_OUT)/drivers/usb/host/ehci-hcd.ko \
                            $(KERNEL_OUT)/drivers/usb/storage/usb-storage.ko \
                            $(KERNEL_OUT)/drivers/scsi/sd_mod.ko \
                            $(KERNEL_OUT)/drivers/bluetooth/mx8_bt_rfkill.ko \
                            $(KERNEL_OUT)/drivers/hid/hid-multitouch.ko

ifeq ($(PRODUCT_IMX_CAR_M4),true)
BOARD_VENDOR_KERNEL_MODULES += \
                            $(KERNEL_OUT)/drivers/staging/media/imx/gmsl-max9286.ko \
                            $(KERNEL_OUT)/drivers/staging/media/imx/imx8-mipi-csi2.ko \
                            $(KERNEL_OUT)/drivers/staging/media/imx/imx8-media-dev.ko \
                            $(KERNEL_OUT)/drivers/staging/media/imx/imx8-capture.ko

endif
endif

