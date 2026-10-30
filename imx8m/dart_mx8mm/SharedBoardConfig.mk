# -------@block_kernel_bootimg-------
KERNEL_NAME := Image.lz4
TARGET_KERNEL_ARCH := arm64
TARGET_USES_BCM_WIFI ?= false

LOADABLE_KERNEL_MODULE ?= true
BAZEL_BUILD_VENDOR_MODULES ?= false

# BCM fmac wifi driver module
BOARD_VENDOR_KERNEL_MODULES += \
    $(KERNEL_OUT)/drivers/net/wireless/broadcom/brcm80211/brcmutil/brcmutil.ko \
    $(KERNEL_OUT)/drivers/net/wireless/broadcom/brcm80211/brcmfmac/wcc/brcmfmac-wcc.ko \
    $(KERNEL_OUT)/drivers/net/wireless/broadcom/brcm80211/brcmfmac/brcmfmac.ko

# NXP 8987 wifi driver module
BOARD_VENDOR_KERNEL_MODULES += \
    $(TARGET_OUT_INTERMEDIATES)/MXMWIFI_OBJ/mlan.ko \
    $(TARGET_OUT_INTERMEDIATES)/MXMWIFI_OBJ/moal.ko

ifeq ($(BAZEL_BUILD_VENDOR_MODULES),false)
ifeq ($(LOADABLE_KERNEL_MODULE),true)
BOARD_VENDOR_KERNEL_MODULES += \
    $(KERNEL_OUT)/mm/zsmalloc.ko \
    $(KERNEL_OUT)/drivers/block/zram/zram.ko \
    $(KERNEL_OUT)/net/rfkill/rfkill.ko \
    $(KERNEL_OUT)/net/wireless/cfg80211.ko \
    $(KERNEL_OUT)/lib/crypto/libarc4.ko \
    $(KERNEL_OUT)/net/mac80211/mac80211.ko \
    $(KERNEL_OUT)/drivers/mxc/gpu-viv/galcore.ko \
    $(KERNEL_OUT)/drivers/thermal/imx8mm_thermal.ko \
    $(KERNEL_OUT)/drivers/media/rc/gpio-ir-recv.ko \
    $(KERNEL_OUT)/drivers/media/platform/nxp/imx7-media-csi.ko \
    $(KERNEL_OUT)/drivers/media/platform/nxp/imx-mipi-csis.ko \
    $(KERNEL_OUT)/drivers/media/i2c/ov5640.ko \
    $(KERNEL_OUT)/drivers/leds/leds-gpio.ko \
    $(KERNEL_OUT)/drivers/leds/leds-pca995x.ko \
    $(KERNEL_OUT)/drivers/gpio/gpio-pca953x.ko \
    $(KERNEL_OUT)/drivers/firmware/imx/sm-misc.ko \
    $(KERNEL_OUT)/sound/soc/fsl/imx-pcm-dma.ko \
    $(KERNEL_OUT)/sound/soc/fsl/snd-soc-fsl-utils.ko \
    $(KERNEL_OUT)/sound/soc/fsl/snd-soc-fsl-micfil.ko \
    $(KERNEL_OUT)/sound/soc/fsl/snd-soc-fsl-asrc.ko \
    $(KERNEL_OUT)/sound/soc/fsl/snd-soc-fsl-easrc.ko \
    $(KERNEL_OUT)/sound/soc/fsl/snd-soc-fsl-sai.ko \
    $(KERNEL_OUT)/sound/soc/fsl/snd-soc-fsl-spdif.ko \
    $(KERNEL_OUT)/sound/soc/fsl/snd-soc-imx-audmux.ko \
    $(KERNEL_OUT)/sound/soc/fsl/snd-soc-fsl-asoc-card.ko \
    $(KERNEL_OUT)/sound/soc/codecs/snd-soc-wm8524.ko \
    $(KERNEL_OUT)/sound/soc/codecs/snd-soc-ak4458.ko \
    $(KERNEL_OUT)/sound/soc/codecs/snd-soc-ak5558.ko \
    $(KERNEL_OUT)/sound/soc/codecs/snd-soc-bt-sco.ko \
    $(KERNEL_OUT)/sound/soc/generic/snd-soc-simple-card.ko \
    $(KERNEL_OUT)/sound/soc/generic/snd-soc-simple-card-utils.ko \
    $(KERNEL_OUT)/drivers/rpmsg/rpmsg_ns.ko \
    $(KERNEL_OUT)/drivers/rpmsg/virtio_rpmsg_bus.ko \
    $(KERNEL_OUT)/drivers/firmware/imx/sm-cpu.ko \
    $(KERNEL_OUT)/drivers/firmware/imx/sm-lmm.ko \
    $(KERNEL_OUT)/drivers/remoteproc/imx_rproc.ko \
    $(KERNEL_OUT)/drivers/i2c/busses/i2c-rpmsg-imx.ko \
    $(KERNEL_OUT)/sound/soc/fsl/imx-pcm-rpmsg.ko \
    $(KERNEL_OUT)/sound/soc/fsl/snd-soc-fsl-rpmsg.ko \
    $(KERNEL_OUT)/sound/soc/fsl/imx-audio-rpmsg.ko \
    $(KERNEL_OUT)/sound/soc/fsl/snd-soc-imx-rpmsg.ko \
    $(KERNEL_OUT)/sound/soc/codecs/snd-soc-wm8904.ko \
    $(KERNEL_OUT)/sound/soc/fsl/snd-soc-imx-card.ko \
    $(KERNEL_OUT)/drivers/mxc/vpu/hantrodec/hantro-dec.ko \
    $(KERNEL_OUT)/drivers/mxc/vpu/hantroenc/hantro-enc.ko \
    $(KERNEL_OUT)/drivers/mxc/vpu/memory_usage/memory_usage.ko \
    $(KERNEL_OUT)/drivers/mxc/hantro_v4l2/vsiv4l2.ko \
    $(KERNEL_OUT)/drivers/rtc/rtc-snvs.ko \
    $(KERNEL_OUT)/drivers/misc/eeprom/at24.ko \
    $(KERNEL_OUT)/drivers/net/phy/qcom/qcom-phy-lib.ko \
    $(KERNEL_OUT)/drivers/net/phy/qcom/at803x.ko \
    $(KERNEL_OUT)/drivers/net/phy/realtek/realtek.ko \
    $(KERNEL_OUT)/drivers/pps/pps_core.ko \
    $(KERNEL_OUT)/drivers/ptp/ptp.ko \
    $(KERNEL_OUT)/drivers/net/phy/adin.ko \
    $(KERNEL_OUT)/drivers/net/phy/mxl-86110.ko \
    $(KERNEL_OUT)/drivers/net/phy/dp83867.ko \
    $(KERNEL_OUT)/drivers/net/ethernet/freescale/fec.ko \
    $(KERNEL_OUT)/drivers/rtc/rtc-ds1307.ko \
    $(KERNEL_OUT)/drivers/phy/freescale/phy-fsl-imx8m-pcie.ko \
    $(KERNEL_OUT)/drivers/pci/controller/dwc/pci-imx6.ko \
    $(KERNEL_OUT)/net/can/can.ko \
    $(KERNEL_OUT)/net/can/can-raw.ko \
    $(KERNEL_OUT)/net/can/can-bcm.ko \
    $(KERNEL_OUT)/net/can/can-gw.ko \
    $(KERNEL_OUT)/drivers/net/can/dev/can-dev.ko \
    $(KERNEL_OUT)/drivers/net/can/spi/mcp251xfd/mcp251xfd.ko


# Bluetooth depends on rfkill, so keep the whole stack in vendor_dlkm.
# hci_uart covers Broadcom BT on 1.x SOMs; btnxpuart covers NXP 8987/IW612.
BOARD_VENDOR_KERNEL_MODULES += \
    $(KERNEL_OUT)/net/bluetooth/bluetooth.ko \
    $(KERNEL_OUT)/drivers/power/sequencing/pwrseq-core.ko \
    $(KERNEL_OUT)/drivers/bluetooth/btbcm.ko \
    $(KERNEL_OUT)/drivers/bluetooth/btqca.ko \
    $(KERNEL_OUT)/drivers/bluetooth/hci_uart.ko \
    $(KERNEL_OUT)/drivers/bluetooth/btnxpuart.ko


# TPM support
BOARD_VENDOR_KERNEL_MODULES += \
    $(KERNEL_OUT)/lib/crc/crc-ccitt.ko \
    $(KERNEL_OUT)/drivers/char/tpm/tpm.ko \
    $(KERNEL_OUT)/drivers/char/tpm/tpm_tis_core.ko \
    $(KERNEL_OUT)/drivers/char/tpm/tpm_tis_i2c.ko
endif

ifeq ($(LOADABLE_KERNEL_MODULE),true)
BOARD_VENDOR_RAMDISK_KERNEL_MODULES +=     \
    $(KERNEL_OUT)/drivers/soc/imx/soc-imx8m.ko \
    $(KERNEL_OUT)/drivers/clk/imx/mxc-clk.ko \
    $(KERNEL_OUT)/drivers/clk/imx/clk-imx8mm.ko \
    $(KERNEL_OUT)/drivers/pmdomain/imx/gpcv2.ko \
    $(KERNEL_OUT)/drivers/pmdomain/imx/gpcv2-imx.ko \
    $(KERNEL_OUT)/drivers/pmdomain/imx/imx8m-blk-ctrl.ko \
    $(KERNEL_OUT)/drivers/clocksource/timer-imx-sysctr.ko \
    $(KERNEL_OUT)/drivers/soc/imx/busfreq-imx8mq.ko \
    $(KERNEL_OUT)/drivers/pinctrl/freescale/pinctrl-imx.ko \
    $(KERNEL_OUT)/drivers/pinctrl/freescale/pinctrl-imx8mm.ko \
    $(KERNEL_OUT)/drivers/tty/serial/imx.ko \
    $(KERNEL_OUT)/drivers/watchdog/imx2_wdt.ko \
    $(KERNEL_OUT)/drivers/regulator/rohm-regulator.ko \
    $(KERNEL_OUT)/drivers/mfd/rohm-bd718x7.ko \
    $(KERNEL_OUT)/drivers/regulator/bd718x7-regulator.ko \
    $(KERNEL_OUT)/drivers/regulator/gpio-regulator.ko \
    $(KERNEL_OUT)/drivers/gpio/gpio-mxc.ko \
    $(KERNEL_OUT)/drivers/leds/leds-gpio.ko \
    $(KERNEL_OUT)/drivers/gpio/gpio-pca953x.ko \
    $(KERNEL_OUT)/drivers/perf/fsl_imx8_ddr_perf.ko \
    $(KERNEL_OUT)/drivers/cpufreq/cpufreq-dt.ko \
    $(KERNEL_OUT)/drivers/cpufreq/imx-cpufreq-dt.ko \
    $(KERNEL_OUT)/drivers/nvmem/nvmem-imx-ocotp.ko \
    $(KERNEL_OUT)/drivers/pwm/pwm-imx27.ko \
    $(KERNEL_OUT)/drivers/video/backlight/pwm_bl.ko \
    $(KERNEL_OUT)/drivers/mmc/host/sdhci-esdhc-imx.ko \
    $(KERNEL_OUT)/drivers/mmc/host/cqhci.ko \
    $(KERNEL_OUT)/drivers/i2c/busses/i2c-imx.ko \
    $(KERNEL_OUT)/drivers/i2c/i2c-dev.ko \
    $(KERNEL_OUT)/drivers/mtd/mtd.ko \
    $(KERNEL_OUT)/drivers/spi/spidev.ko \
    $(KERNEL_OUT)/drivers/spi/spi-bitbang.ko \
    $(KERNEL_OUT)/drivers/spi/spi-nxp-fspi.ko \
    $(KERNEL_OUT)/drivers/spi/spi-imx.ko \
    $(KERNEL_OUT)/drivers/mtd/spi-nor/spi-nor.ko \
    $(KERNEL_OUT)/lib/stmp_device.ko \
    $(KERNEL_OUT)/drivers/dma/mxs-dma.ko \
    $(KERNEL_OUT)/drivers/mmc/core/pwrseq_simple.ko \
    $(KERNEL_OUT)/drivers/mailbox/imx-mailbox.ko \
    $(KERNEL_OUT)/drivers/dma-buf/heaps/system_heap.ko \
    $(KERNEL_OUT)/drivers/dma-buf/heaps/cma_heap.ko \
    $(KERNEL_OUT)/drivers/dma-buf/dma-buf-imx.ko \
    $(KERNEL_OUT)/drivers/input/keyboard/snvs_pwrkey.ko \
    $(KERNEL_OUT)/drivers/input/touchscreen/goodix_ts.ko \
    $(KERNEL_OUT)/drivers/input/touchscreen/edt-ft5x06.ko \
    $(KERNEL_OUT)/drivers/input/touchscreen/ads7846.ko \
    $(KERNEL_OUT)/drivers/input/touchscreen/synaptics_dsx/synaptics_dsx_i2c.ko \
    $(KERNEL_OUT)/drivers/reset/reset-dispmix.ko \
    $(KERNEL_OUT)/drivers/reset/reset-imx7.ko \
    $(KERNEL_OUT)/drivers/video/fbdev/core/fb.ko \
    $(KERNEL_OUT)/drivers/video/fbdev/core/cfbfillrect.ko \
    $(KERNEL_OUT)/drivers/video/fbdev/core/cfbcopyarea.ko \
    $(KERNEL_OUT)/drivers/video/fbdev/core/cfbimgblt.ko \
    $(KERNEL_OUT)/drivers/video/fbdev/core/fb_io_fops.ko \
    $(KERNEL_OUT)/drivers/video/fbdev/core/fb_sys_fops.ko \
    $(KERNEL_OUT)/drivers/video/fbdev/core/sysimgblt.ko \
    $(KERNEL_OUT)/drivers/video/fbdev/core/syscopyarea.ko \
    $(KERNEL_OUT)/drivers/video/fbdev/core/sysfillrect.ko \
    $(KERNEL_OUT)/drivers/video/logo/linux_logo.ko \
    $(KERNEL_OUT)/drivers/gpu/drm/clients/drm_client_lib.ko \
    $(KERNEL_OUT)/drivers/gpu/drm/mxsfb/mxsfb.ko \
    $(KERNEL_OUT)/drivers/gpu/imx/lcdif/imx8mm-lcdif-core.ko \
    $(KERNEL_OUT)/drivers/gpu/drm/drm_dma_helper.ko \
    $(KERNEL_OUT)/drivers/gpu/drm/drm_fbdev_helper.ko \
    $(KERNEL_OUT)/drivers/gpu/drm/display/drm_display_helper.ko \
    $(KERNEL_OUT)/drivers/gpu/drm/bridge/adv7511/adv7511.ko \
    $(KERNEL_OUT)/drivers/gpu/drm/bridge/samsung-dsim.ko \
    $(KERNEL_OUT)/drivers/gpu/drm/bridge/sec-dsim.ko \
    $(KERNEL_OUT)/drivers/gpu/drm/panel/panel-lvds.ko \
    $(KERNEL_OUT)/drivers/gpu/drm/imx/imxdrm.ko \
    $(KERNEL_OUT)/drivers/gpu/drm/imx/lcdif/imx8mm-lcdif-crtc.ko \
    $(KERNEL_OUT)/drivers/gpu/drm/imx/sec_mipi_dsim-imx.ko \
    $(KERNEL_OUT)/drivers/gpu/drm/bridge/ti-sn65dsi83.ko \
    $(KERNEL_OUT)/drivers/usb/chipidea/usbmisc_imx.ko \
    $(KERNEL_OUT)/drivers/usb/common/ulpi.ko \
    $(KERNEL_OUT)/drivers/usb/chipidea/ci_hdrc_imx.ko \
    $(KERNEL_OUT)/drivers/usb/chipidea/ci_hdrc.ko \
    $(KERNEL_OUT)/drivers/usb/phy/phy-generic.ko \
    $(KERNEL_OUT)/drivers/power/supply/dummy_battery.ko \
    $(KERNEL_OUT)/drivers/dma/imx-sdma.ko \
    $(KERNEL_OUT)/drivers/trusty/trusty-smc.ko \
    $(KERNEL_OUT)/drivers/trusty/trusty-core.ko \
    $(KERNEL_OUT)/drivers/trusty/trusty-log.ko \
    $(KERNEL_OUT)/drivers/trusty/trusty-ipc.ko \
    $(KERNEL_OUT)/drivers/trusty/trusty-virtio.ko \
    $(KERNEL_OUT)/drivers/extcon/extcon-usb-gpio.ko \
    $(KERNEL_OUT)/drivers/extcon/extcon-ptn5150.ko

else
endif
endif

# -------@block_memory-------
#Enable this to config 1GB ddr on evk_imx8mm
LOW_MEMORY := false

# -------@block_security-------
#Enable this to include trusty support
PRODUCT_IMX_TRUSTY ?= false

ifeq ($(PRODUCT_IMX_TRUSTY),true)
# Trusty logs on the board console UART and sits at the top of the DRAM,
# so each board and DRAM size has its own bootloader. Build OTA packages
# with TARGET_TEE_SOM=true for VAR-SOM and TARGET_TEE_4G=true for 4 GB.
ifeq ($(TARGET_TEE_SOM),true)
VARISCITE_OTA_BOOTLOADER := imx8mm-var-som-trusty
else
VARISCITE_OTA_BOOTLOADER := imx8mm-var-dart-trusty
endif
ifeq ($(TARGET_TEE_4G),true)
VARISCITE_OTA_BOOTLOADER := $(VARISCITE_OTA_BOOTLOADER)-4g-dual
else
VARISCITE_OTA_BOOTLOADER := $(VARISCITE_OTA_BOOTLOADER)-dual
endif
else
VARISCITE_OTA_BOOTLOADER := imx8mm-var-dart-dual
endif
BOARD_OTA_BOOTLOADERIMAGE := bootloader-$(VARISCITE_OTA_BOOTLOADER).img

#Enable this to use dynamic partitions for the readonly partitions not touched by bootloader
TARGET_USE_DYNAMIC_PARTITIONS ?= true

#Enable this to disable product partition build.
IMX_NO_PRODUCT_PARTITION := false

# -------@block_infrastructure-------
CONFIG_REPO_PATH := device/nxp
NXP_DEVICE_PATH := $(CONFIG_REPO_PATH)/imx8m/evk_8mm

ifeq ($(SUPPORT_GBL),true)
# Enable this to include the dtb images into vendor_boot image.
TARGET_INCLUDE_DTB_TO_VENDOR_BOOT ?= true
endif
