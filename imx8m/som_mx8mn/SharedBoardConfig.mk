# -------@block_kernel_bootimg-------
KERNEL_NAME := Image.lz4
TARGET_KERNEL_ARCH := arm64
IMX8MN_USES_GKI := true


# CONFIG_TOUCHSCREEN_SYNAPTICS_DSX_I2C: synaptics_dsx_i2c.ko, mipi-panel touch driver module
# CONFIG_VIDEO_MXC_CSI_CAMERA: mx6s_capture.ko, it's csi adapt driver which is the input of v4l2 framework
# CONFIG_MXC_CAMERA_OV5640_MIPI_V2: ov5640_camera_mipi_v2.ko, sensor ov5640 driver, the input of mipi
# CONFIG_MXC_MIPI_CSI: mxc_mipi_csi.ko, mipi driver which get the sensor data and send data to csi
# CONFIG_VIDEO_MXC_CAPTURE: only enable compile dir drivers/media/platform/mxc/capture/, no need mxc_v4l2_capture.c which used in imx6/7
# linux bsp team will add new configure for mxc_v4l2_capture.c in lf-5.4 branch.
# CONFIG_SND_SOC_WM8524: snd-soc-wm8524.ko, wm8524 audio codec
# CONFIG_SND_IMX_SOC: SoC Audio for Freescale i.MX CPUs
# CONFIG_SND_SIMPLE_CARD: snd-soc-simple-card.ko snd-soc-simple-card-utils.ko, connect cpu and codec
# CONFIG_SND_SOC_FSL_SAI: snd-soc-fsl-sai.ko, audio cpu, privide i2s
# CONFIG_IMX_SDMA: imx-sdma.ko, sdma used for audio
# CONFIG_SND_SOC_FSL_MICFIL: snd-soc-fsl-micfil.ko, used in audio mic
# CONFIG_SND_SOC_IMX_MICFIL: snd-soc-imx-micfil.ko, used in audio mic
# CONFIG_SND_SOC_IMX_PCM_DMA: imx-pcm-dma-common.ko, used in fsl_micfil
# CONFIG_MXC_HANTRO: hantrodec.ko vpu decoder
# CONFIG_MXC_HANTRO_845: hantrodec_845s.ko vpu decodder
# CONFIG_MXC_HANTRO_845_H1: hx280enc.ko vpu encoder
# CONFIG_RTC_DRV_SNVS: rtc-snvs.ko, snvs driver
# CONFIG_FEC: fec.ko which depend on pps_core.ko and ptp.ko
# CONFIG_AT803X_PHY: ethernet phy driver at803x.ko

ifeq ($(IMX8MN_USES_GKI),true)
BOARD_VENDOR_KERNEL_MODULES += \
    $(KERNEL_OUT)/drivers/mxc/gpu-viv/galcore.ko \
    $(KERNEL_OUT)/drivers/thermal/imx8mm_thermal.ko \
    $(KERNEL_OUT)/drivers/leds/leds-gpio.ko \
    $(KERNEL_OUT)/drivers/media/platform/mxc/capture/mx6s_capture.ko \
    $(KERNEL_OUT)/drivers/media/platform/mxc/capture/mxc_mipi_csi.ko \
    $(KERNEL_OUT)/drivers/media/platform/mxc/capture/ov5640_camera_mipi_v2.ko \
    $(KERNEL_OUT)/drivers/dma/imx-sdma.ko \
    $(KERNEL_OUT)/sound/soc/fsl/imx-pcm-dma.ko \
    $(KERNEL_OUT)/sound/soc/fsl/snd-soc-fsl-micfil.ko \
    $(KERNEL_OUT)/sound/soc/fsl/snd-soc-fsl-asrc.ko \
    $(KERNEL_OUT)/sound/soc/fsl/snd-soc-fsl-easrc.ko \
    $(KERNEL_OUT)/sound/soc/fsl/snd-soc-fsl-sai.ko \
    $(KERNEL_OUT)/sound/soc/fsl/snd-soc-fsl-spdif.ko \
    $(KERNEL_OUT)/sound/soc/fsl/snd-soc-imx-spdif.ko \
    $(KERNEL_OUT)/sound/soc/codecs/snd-soc-bt-sco.ko \
    $(KERNEL_OUT)/sound/soc/generic/snd-soc-simple-card-utils.ko \
    $(KERNEL_OUT)/sound/soc/generic/snd-soc-simple-card.ko \
    $(KERNEL_OUT)/sound/soc/fsl/snd-soc-imx-audmux.ko \
    $(KERNEL_OUT)/sound/soc/fsl/snd-soc-fsl-asoc-card.ko \
    $(KERNEL_OUT)/drivers/rtc/rtc-snvs.ko \
    $(KERNEL_OUT)/drivers/i2c/i2c-dev.ko \
    $(KERNEL_OUT)/drivers/net/ethernet/freescale/fec.ko \
    $(KERNEL_OUT)/drivers/net/wireless/broadcom/brcm80211/brcmutil/brcmutil.ko \
    $(KERNEL_OUT)/drivers/net/wireless/broadcom/brcm80211/brcmfmac/brcmfmac.ko


#Cortex-M7
BOARD_VENDOR_KERNEL_MODULES += \
    $(KERNEL_OUT)/drivers/mailbox/imx-mailbox.ko \
    $(KERNEL_OUT)/drivers/rpmsg/rpmsg_ns.ko \
    $(KERNEL_OUT)/drivers/rpmsg/virtio_rpmsg_bus.ko \
    $(KERNEL_OUT)/drivers/remoteproc/imx_rproc.ko 

else
BOARD_VENDOR_KERNEL_MODULES +=     \
    $(KERNEL_OUT)/drivers/input/touchscreen/synaptics_dsx/synaptics_dsx_i2c.ko
endif

# CONFIG_CLK_IMX8MM: clk-imx8mm.ko
# CONFIG_IMX8M_PM_DOMAINS: imx8m_pm_domains.ko, this driver still not upstream
# CONFIG_PINCTRL_IMX8MM: pinctrl-imx8mm.ko
# CONFIG_SERIAL_IMX: imx.ko
# CONFIG_IMX2_WDT: imx2_wdt.ko
# CONFIG_MFD_ROHM_BD718XX: rohm-bd718x7.ko
# CONFIG_GPIO_MXC: gpio-generic.ko gpio-mxc.ko
# CONFIG_MMC_SDHCI_ESDHC_IMX: sdhci-esdhc-imx.ko cqhci.ko
# CONFIG_I2C_IMX:i2c-imx.ko
# CONFIG_ION_CMA_HEAP: ion_cma_heap.ko
# depend on clk module: reset-dispmix.ko, it will been select as m if clk build as m.
# CONFIG_KEYBOARD_SNVS_PWRKEY: snvs_pwrkey.ko, snvs power key driver
# CONFIG_IMX_LCDIF_CORE: imx-lcdif-core.ko
# CONFIG_DRM_IMX: imxdrm.ko imx-lcdif-crtc.ko
# CONFIG_DRM_SEC_MIPI_DSIM: sec-dsim.ko
# CONFIG_DRM_IMX_SEC_DSIM: sec_mipi_dsim-imx.ko
# CONFIG_DRM_I2C_ADV7511: adv7511.ko
# CONFIG_USB_CHIPIDEA_OF: usbmisc_imx.ko ci_hdrc_imx.ko
# CONFIG_USB_CHIPIDEA: ci_hdrc.ko
# CONFIG_NOP_USB_XCEIV: phy-generic.ko
# CONFIG_TYPEC_TCPCI: tcpci.ko
# CONFIG_USB_EHCI_HCD: ehci-hcd.ko
# CONFIG_VIDEO_IMX_CAPTURE: imx8-media-dev.ko, imx8-isi-cap.ko, imx8-isi-hw.ko, imx8-isi-m2m.ko, imx8-mipi-csi2-sam.ko, imx isi and mipi driver
# CONFIG_CFG80211: cfg80211.ko, cfg80211 - wireless configuration API
# CONFIG_MAC80211: mac80211.ko, Generic IEEE 802.11 Networking Stack

ifeq ($(IMX8MN_USES_GKI),true)
BOARD_VENDOR_RAMDISK_KERNEL_MODULES += \
    $(KERNEL_OUT)/mm/zsmalloc.ko \
    $(KERNEL_OUT)/drivers/block/zram/zram.ko \
    $(KERNEL_OUT)/drivers/soc/imx/soc-imx8m.ko \
    $(KERNEL_OUT)/drivers/clk/imx/mxc-clk.ko \
    $(KERNEL_OUT)/drivers/clk/imx/clk-imx8mn.ko \
    $(KERNEL_OUT)/drivers/soc/imx/imx8m_pm_domains.ko \
    $(KERNEL_OUT)/drivers/clocksource/timer-imx-sysctr.ko \
    $(KERNEL_OUT)/drivers/soc/imx/busfreq-imx8mq.ko \
    $(KERNEL_OUT)/drivers/pinctrl/freescale/pinctrl-imx.ko \
    $(KERNEL_OUT)/drivers/pinctrl/freescale/pinctrl-imx8mn.ko \
    $(KERNEL_OUT)/drivers/i2c/busses/i2c-imx.ko \
    $(KERNEL_OUT)/drivers/i2c/i2c-smbus.ko \
    $(KERNEL_OUT)/drivers/i2c/i2c-mux.ko \
    $(KERNEL_OUT)/drivers/i2c/muxes/i2c-mux-gpio.ko \
    $(KERNEL_OUT)/drivers/i2c/muxes/i2c-mux-pca954x.ko \
    $(KERNEL_OUT)/drivers/i2c/busses/i2c-imx-lpi2c.ko \
    $(KERNEL_OUT)/drivers/gpio/gpio-pca953x.ko \
    $(KERNEL_OUT)/drivers/tty/serial/imx.ko \
    $(KERNEL_OUT)/drivers/watchdog/imx2_wdt.ko \
    $(KERNEL_OUT)/drivers/regulator/gpio-regulator.ko \
    $(KERNEL_OUT)/drivers/regulator/pca9450-regulator.ko \
    $(KERNEL_OUT)/drivers/gpio/gpio-mxc.ko \
    $(KERNEL_OUT)/drivers/thermal/device_cooling.ko \
    $(KERNEL_OUT)/drivers/perf/fsl_imx8_ddr_perf.ko \
    $(KERNEL_OUT)/drivers/cpufreq/cpufreq-dt.ko \
    $(KERNEL_OUT)/drivers/cpufreq/imx-cpufreq-dt.ko \
    $(KERNEL_OUT)/drivers/nvmem/nvmem-imx-ocotp.ko \
    $(KERNEL_OUT)/drivers/pwm/pwm-imx27.ko \
    $(KERNEL_OUT)/drivers/video/backlight/pwm_bl.ko \
    $(KERNEL_OUT)/drivers/mmc/host/sdhci-esdhc-imx.ko \
    $(KERNEL_OUT)/drivers/mmc/host/cqhci.ko \
    $(KERNEL_OUT)/drivers/spi/spidev.ko \
    $(KERNEL_OUT)/drivers/spi/spi-bitbang.ko \
    $(KERNEL_OUT)/drivers/spi/spi-nxp-fspi.ko \
    $(KERNEL_OUT)/drivers/spi/spi-imx.ko \
    $(KERNEL_OUT)/lib/stmp_device.ko \
    $(KERNEL_OUT)/drivers/dma/mxs-dma.ko \
    $(KERNEL_OUT)/drivers/mmc/core/pwrseq_simple.ko \
    $(KERNEL_OUT)/drivers/dma-buf/heaps/system_heap.ko \
    $(KERNEL_OUT)/drivers/dma-buf/heaps/cma_heap.ko \
    $(KERNEL_OUT)/drivers/dma-buf/dma-buf-imx.ko \
    $(KERNEL_OUT)/drivers/reset/gpio-reset.ko \
    $(KERNEL_OUT)/drivers/reset/reset-imx7.ko \
    $(KERNEL_OUT)/drivers/input/keyboard/snvs_pwrkey.ko \
    $(KERNEL_OUT)/drivers/input/touchscreen/synaptics_dsx/synaptics_dsx_i2c.ko \
    $(KERNEL_OUT)/drivers/reset/reset-dispmix.ko \
    $(KERNEL_OUT)/drivers/gpu/imx/lcdif/imx-lcdif-core.ko \
    $(KERNEL_OUT)/drivers/gpu/drm/bridge/sec-dsim.ko \
    $(KERNEL_OUT)/drivers/gpu/drm/imx/imxdrm.ko \
    $(KERNEL_OUT)/drivers/gpu/drm/imx/lcdif/imx-lcdif-crtc.ko \
    $(KERNEL_OUT)/drivers/gpu/drm/imx/sec_mipi_dsim-imx.ko \
    $(KERNEL_OUT)/drivers/gpu/drm/bridge/ti-sn65dsi83.ko \
    $(KERNEL_OUT)/drivers/usb/chipidea/usbmisc_imx.ko \
    $(KERNEL_OUT)/drivers/usb/common/ulpi.ko \
    $(KERNEL_OUT)/drivers/usb/chipidea/ci_hdrc_imx.ko \
    $(KERNEL_OUT)/drivers/usb/chipidea/ci_hdrc.ko \
    $(KERNEL_OUT)/drivers/usb/phy/phy-generic.ko \
    $(KERNEL_OUT)/drivers/power/supply/dummy_battery.ko \
    $(KERNEL_OUT)/drivers/media/rc/gpio-ir-recv.ko \
    $(KERNEL_OUT)/drivers/media/v4l2-core/v4l2-async.ko \
    $(KERNEL_OUT)/drivers/media/v4l2-core/v4l2-fwnode.ko \
    $(KERNEL_OUT)/drivers/media/i2c/ov5640.ko \
    $(KERNEL_OUT)/drivers/staging/media/imx/imx8-capture.ko \
    $(KERNEL_OUT)/drivers/staging/media/imx/imx8-isi-capture.ko \
    $(KERNEL_OUT)/drivers/staging/media/imx/imx8-isi-hw.ko \
    $(KERNEL_OUT)/drivers/staging/media/imx/imx8-isi-mem2mem.ko \
    $(KERNEL_OUT)/drivers/staging/media/imx/imx8-mipi-csi2-sam.ko \
    $(KERNEL_OUT)/drivers/trusty/trusty-ipc.ko \
    $(KERNEL_OUT)/drivers/trusty/trusty-core.ko \
    $(KERNEL_OUT)/drivers/trusty/trusty-irq.ko \
    $(KERNEL_OUT)/drivers/trusty/trusty-log.ko \
    $(KERNEL_OUT)/drivers/trusty/trusty-virtio.ko \
    $(KERNEL_OUT)/drivers/staging/media/imx/imx8-media-dev.ko \
    $(KERNEL_OUT)/net/wireless/cfg80211.ko \
    $(KERNEL_OUT)/net/mac80211/mac80211.ko \
    $(KERNEL_OUT)/net/can/can.ko \
    $(KERNEL_OUT)/net/can/can-raw.ko \
    $(KERNEL_OUT)/net/can/can-bcm.ko \
    $(KERNEL_OUT)/net/can/can-gw.ko \
    $(KERNEL_OUT)/drivers/net/can/dev/can-dev.ko \
    $(KERNEL_OUT)/drivers/net/can/flexcan.ko \
    $(KERNEL_OUT)/drivers/net/can/spi/mcp251xfd/mcp251xfd.ko \
    $(KERNEL_OUT)/drivers/extcon/extcon-gpio.ko \
    $(KERNEL_OUT)/drivers/extcon/extcon-ptn5150.ko \
    $(KERNEL_OUT)/net/rfkill/rfkill-gpio.ko \
    $(KERNEL_OUT)/sound/soc/codecs/snd-soc-wm8904.ko
endif

# -------@block_memory-------
#Enable this to config 1GB ddr on evk_imx8mn
LOW_MEMORY := true

# -------@block_security-------
#Enable this to include trusty support
PRODUCT_IMX_TRUSTY := true
