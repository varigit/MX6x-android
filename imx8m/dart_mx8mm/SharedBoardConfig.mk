KERNEL_NAME := Image
TARGET_KERNEL_ARCH := arm64
# IMX8MM_USES_GKI := true
# after selecting the target by "lunch" command, TARGET_PRODUCT will be set
ifeq ($(TARGET_PRODUCT),evk_8mm_ddr4)
  PRODUCT_8MM_DDR4 := true
endif

#Enable this to config 1GB ddr on evk_imx8mm
#LOW_MEMORY := true

#Enable this to include trusty support
PRODUCT_IMX_TRUSTY := true

#Enable this to disable product partition build.
#IMX_NO_PRODUCT_PARTITION := true

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
# CONFIG_KEYBOARD_SNVS_PWRKEY: powerkey driver
# CONFIG_FEC: fec.ko which depend on pps_core.ko and ptp.ko
# CONFIG_AT803X_PHY: ethernet phy driver at803x.ko

ifneq ($(IMX8MM_USES_GKI),)
BOARD_VENDOR_KERNEL_MODULES += \
    $(KERNEL_OUT)/drivers/mxc/gpu-viv/galcore.ko \
    $(KERNEL_OUT)/drivers/media/platform/mxc/capture/mx6s_capture.ko \
    $(KERNEL_OUT)/drivers/media/platform/mxc/capture/mxc_mipi_csi.ko \
    $(KERNEL_OUT)/drivers/media/platform/mxc/capture/ov5640_camera_mipi_v2.ko \
    $(KERNEL_OUT)/drivers/bluetooth/mx8_bt_rfkill.ko \
    $(KERNEL_OUT)/sound/soc/codecs/snd-soc-wm8524.ko \
    $(KERNEL_OUT)/drivers/dma/imx-sdma.ko \
    $(KERNEL_OUT)/sound/soc/generic/snd-soc-simple-card.ko \
    $(KERNEL_OUT)/sound/soc/generic/snd-soc-simple-card-utils.ko \
    $(KERNEL_OUT)/sound/soc/fsl/snd-soc-fsl-sai.ko \
    $(KERNEL_OUT)/sound/soc/fsl/imx-pcm-dma-common.ko \
    $(KERNEL_OUT)/sound/soc/fsl/snd-soc-fsl-micfil.ko \
    $(KERNEL_OUT)/sound/soc/fsl/snd-soc-imx-micfil.ko \
    $(KERNEL_OUT)/drivers/mxc/hantro/hantrodec.ko \
    $(KERNEL_OUT)/drivers/mxc/hantro_845/hantrodec_845s.ko \
    $(KERNEL_OUT)/drivers/mxc/hantro_845_h1/hx280enc.ko \
    $(KERNEL_OUT)/drivers/rtc/rtc-snvs.ko \
    $(KERNEL_OUT)/drivers/input/keyboard/snvs_pwrkey.ko \
    $(KERNEL_OUT)/drivers/pps/pps_core.ko \
    $(KERNEL_OUT)/drivers/ptp/ptp.ko \
    $(KERNEL_OUT)/drivers/net/phy/at803x.ko \
    $(KERNEL_OUT)/drivers/net/ethernet/freescale/fec.ko

else
BOARD_VENDOR_KERNEL_MODULES +=     \
    $(KERNEL_OUT)/drivers/net/wireless/broadcom/brcm80211/brcmutil/brcmutil.ko \
    $(KERNEL_OUT)/drivers/net/wireless/broadcom/brcm80211/brcmfmac/brcmfmac.ko
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

ifneq ($(IMX8MM_USES_GKI),)
BOARD_VENDOR_RAMDISK_KERNEL_MODULES +=     \
    $(KERNEL_OUT)/drivers/clk/imx/clk-imx8mm.ko \
    $(KERNEL_OUT)/drivers/soc/imx/imx8m_pm_domains.ko \
    $(KERNEL_OUT)/drivers/pinctrl/freescale/pinctrl-imx8mm.ko \
    $(KERNEL_OUT)/drivers/tty/serial/imx.ko \
    $(KERNEL_OUT)/drivers/watchdog/imx2_wdt.ko \
    $(KERNEL_OUT)/drivers/mfd/rohm-bd718x7.ko \
    $(KERNEL_OUT)/drivers/gpio/gpio-generic.ko \
    $(KERNEL_OUT)/drivers/gpio/gpio-mxc.ko \
    $(KERNEL_OUT)/drivers/mmc/host/sdhci-esdhc-imx.ko \
    $(KERNEL_OUT)/drivers/mmc/host/cqhci.ko \
    $(KERNEL_OUT)/drivers/i2c/busses/i2c-imx.ko \
    $(KERNEL_OUT)/drivers/staging/android/ion/heaps/ion_cma_heap.ko \
    $(KERNEL_OUT)/drivers/reset/reset-dispmix.ko \
    $(KERNEL_OUT)/drivers/input/touchscreen/synaptics_dsx/synaptics_dsx_i2c.ko \
    $(KERNEL_OUT)/drivers/gpu/imx/lcdif/imx-lcdif-core.ko \
    $(KERNEL_OUT)/drivers/gpu/drm/imx/lcdif/imx-lcdif-crtc.ko \
    $(KERNEL_OUT)/drivers/gpu/drm/imx/imxdrm.ko \
    $(KERNEL_OUT)/drivers/gpu/drm/bridge/sec-dsim.ko \
    $(KERNEL_OUT)/drivers/gpu/drm/imx/sec_mipi_dsim-imx.ko \
    $(KERNEL_OUT)/drivers/gpu/drm/panel/panel-raydium-rm67191.ko \
    $(KERNEL_OUT)/drivers/gpu/drm/bridge/adv7511/adv7511.ko \
    $(KERNEL_OUT)/drivers/usb/chipidea/usbmisc_imx.ko \
    $(KERNEL_OUT)/drivers/usb/common/ulpi.ko \
    $(KERNEL_OUT)/drivers/usb/chipidea/ci_hdrc_imx.ko \
    $(KERNEL_OUT)/drivers/usb/chipidea/ci_hdrc.ko \
    $(KERNEL_OUT)/drivers/usb/phy/phy-generic.ko \
    $(KERNEL_OUT)/drivers/usb/typec/tcpm/tcpci.ko \
    $(KERNEL_OUT)/drivers/power/supply/dummy_battery.ko \
    $(KERNEL_OUT)/drivers/trusty/trusty.ko \
    $(KERNEL_OUT)/drivers/trusty/trusty-fiq.ko \
    $(KERNEL_OUT)/drivers/trusty/trusty-arm64-fiq.ko \
    $(KERNEL_OUT)/drivers/trusty/trusty-ipc.ko \
    $(KERNEL_OUT)/drivers/trusty/trusty-irq.ko \
    $(KERNEL_OUT)/drivers/trusty/trusty-log.ko \
    $(KERNEL_OUT)/drivers/trusty/trusty-mem.ko \
    $(KERNEL_OUT)/drivers/trusty/trusty-virtio.ko
endif
