# -------@block_kernel_bootimg-------
KERNEL_NAME := Image
TARGET_KERNEL_ARCH := arm64
IMX8MP_USES_GKI := true
#VVCAM_PATH := vendor/nxp-opensource/verisilicon_sw_isp_vvcam

# BCM fmac wifi driver module

# CONFIG_IMX_SDMA: imx-sdma.ko, sdma used for audio
# CONFIG_SND_SOC_IMX_PCM_DMA: imx-pcm-dma-common.ko, used for fsl_micfil
# CONFIG_SND_SOC_IMX_MICFIL: snd-soc-fsl-micfil.ko snd-soc-imx-micfil.ko, used for fsl_micfil
# CONFIG_SND_SOC_FSL_EASRC: snd-soc-fsl-easrc.ko, used for audio
# CONFIG_SND_IMX_SOC: snd-soc-fsl-sai.ko snd-soc-fsl-utils.ko, imx core audio
# CONFIG_DRM_DW_HDMI_CEC: dw-hdmi-cec.ko, used for hdmi audio
# CONFIG_DRM_DW_HDMI_GP_AUDIO: dw-hdmi-gp-audio.ko, used for hdmi audio
# CONFIG_SND_SOC_IMX_CDNHDMI: snd-soc-hdmi-codec.ko snd-soc-imx-cdnhdmi.ko snd-soc-fsl-aud2htx.ko, used for hdmi audio
# CONFIG_SND_SOC_IMX_WM8960: snd-soc-wm8960.ko snd-soc-imx-wm8960.ko, wm8960 audio driver
# CONFIG_SND_SOC_BT_SCO: snd-soc-bt-sco.ko, bt sco driver
# CONFIG_SND_SIMPLE_CARD: snd-soc-simple-card-utils.ko snd-soc-simple-card.ko, simple audio card used for bt sco
# CONFIG_RTC_DRV_SNVS: rtc-snvs.ko, snvs rtc driver
# CONFIG_STAGING_MEDIA: able to build drivers/staging/media/
# CONFIG_IMX_MBOX: imx-mailbox.ko, imx mailbox driver
# CONFIG_I2C_RPBUS: virtio_rpmsg_bus.ko, virtio rpmsg bus driver
# CONFIG_IMX_REMOTEPROC: imx_rproc.ko, remote proc driver
# CONFIG_SND_SOC_IMX_RPMSG: imx-pcm-rpmsg.ko snd-soc-fsl-rpmsg-i2s.ko imx-i2s-rpmsg.ko, rpmsg audio driver
# CONFIG_SND_SOC_FSL_DSP: snd-soc-fsl-dsp.ko snd-soc-fsl-dsp-audiomix.ko, dsp audio driver
# CONFIG_MXC_HANTRO_VC8000E: hx280enc_vc8000e.ko, vpu encoder driver
# CONFIG_MXC_HANTRO_845: hantrodec_845s.ko, vpu decoder driver

ifeq ($(IMX8MP_USES_GKI),true)
BOARD_VENDOR_KERNEL_MODULES += \
    $(KERNEL_OUT)/drivers/mxc/gpu-viv/galcore.ko \
    $(KERNEL_OUT)/drivers/dma/imx-sdma.ko \
    $(KERNEL_OUT)/sound/soc/fsl/imx-pcm-dma.ko \
    $(KERNEL_OUT)/sound/soc/fsl/imx-pcm-dma-v2.ko \
    $(KERNEL_OUT)/sound/soc/fsl/snd-soc-fsl-micfil.ko \
    $(KERNEL_OUT)/sound/soc/fsl/snd-soc-imx-micfil.ko \
    $(KERNEL_OUT)/sound/soc/fsl/snd-soc-fsl-asrc.ko \
    $(KERNEL_OUT)/sound/soc/fsl/snd-soc-fsl-easrc.ko \
    $(KERNEL_OUT)/sound/soc/fsl/snd-soc-fsl-sai.ko \
    $(KERNEL_OUT)/drivers/gpu/drm/bridge/synopsys/dw-hdmi-cec.ko \
    $(KERNEL_OUT)/drivers/gpu/drm/bridge/synopsys/dw-hdmi-gp-audio.ko \
    $(KERNEL_OUT)/sound/soc/codecs/snd-soc-hdmi-codec.ko \
    $(KERNEL_OUT)/sound/soc/fsl/snd-soc-imx-cdnhdmi.ko \
    $(KERNEL_OUT)/sound/soc/codecs/snd-soc-bt-sco.ko \
    $(KERNEL_OUT)/sound/soc/generic/snd-soc-simple-card-utils.ko \
    $(KERNEL_OUT)/sound/soc/generic/snd-soc-simple-card.ko \
    $(KERNEL_OUT)/sound/soc/fsl/snd-soc-imx-audmux.ko \
    $(KERNEL_OUT)/sound/soc/fsl/snd-soc-fsl-asoc-card.ko \
    $(KERNEL_OUT)/drivers/mxc/hantro_vc8000e/hx280enc_vc8000e.ko \
    $(KERNEL_OUT)/drivers/mxc/hantro_845/hantrodec_845s.ko \
    $(KERNEL_OUT)/drivers/mxc/hantro_v4l2/vsiv4l2.ko \
    $(KERNEL_OUT)/drivers/mailbox/imx-mailbox.ko \
    $(KERNEL_OUT)/drivers/rpmsg/virtio_rpmsg_bus.ko \
    $(KERNEL_OUT)/drivers/rpmsg/rpmsg_raw.ko \
    $(KERNEL_OUT)/drivers/rtc/rtc-snvs.ko \
    $(KERNEL_OUT)/drivers/pci/controller/dwc/pci-imx6.ko \
    $(KERNEL_OUT)/drivers/net/phy/realtek.ko \
    $(KERNEL_OUT)/drivers/ptp/ptp.ko \
    $(KERNEL_OUT)/drivers/pps/pps_core.ko \
    $(KERNEL_OUT)/drivers/net/wireless/broadcom/brcm80211/brcmutil/brcmutil.ko \
    $(KERNEL_OUT)/drivers/net/wireless/broadcom/brcm80211/brcmfmac/brcmfmac.ko \
    $(KERNEL_OUT)/drivers/net/ethernet/freescale/fec.ko
else
BOARD_VENDOR_KERNEL_MODULES +=     \
    $(KERNEL_OUT)/drivers/input/touchscreen/synaptics_dsx/synaptics_dsx_i2c.ko
endif

# CONFIG_CLK_IMX8MP: clk-imx8mp.ko, clk-audiomix.ko, clk-gate-shared.ko, clk-hdmimix.ko
# CONFIG_IMX8M_PM_DOMAINS: imx8m_pm_domains.ko
# CONFIG_PINCTRL_IMX: pinctrl-imx.ko
# CONFIG_PINCTRL_IMX8MP: pinctrl-imx8mp.ko
# CONFIG_SERIAL_IMX: imx.ko
# CONFIG_IMX2_WDT: imx2_wdt.ko
# CONFIG_I2C_IMX: i2c-imx.ko
# CONFIG_MFD_PCA9450: pca9450.ko
# CONFIG_REGULATOR_PCA9450: pca9450-regulator.ko
# CONFIG_PWM_IMX27: pwm-imx27.ko
# CONFIG_BACKLIGHT_PWM : pwm_bl.ko
# CONFIG_MMC_SDHCI_ESDHC_IMX: sdhci-esdhc-imx.ko, cqhci.ko
# CONFIG_ION_CMA_HEAP: ion_cma_heap.ko
# CONFIG_MFD_IMX_AUDIOMIX: imx-audiomix.ko
# CONFIG_PHY_FSL_IMX8MP_LVDS: phy-fsl-imx8mp-lvds.ko
# CONFIG_PHY_SAMSUNG_HDMI_PHY: phy-fsl-samsung-hdmi.ko
# CONFIG_MXC_GPU_VIV: galcore.ko
# CONFIG_IMX_LCDIF_CORE: imx-lcdif-core.ko
# CONFIG_DRM_I2C_ADV7511: adv7511.ko
# CONFIG_DRM_IMX_CDNS_MHDP: cdns_mhdp_drmcore.ko cdns_mhdp_imx.ko
# CONFIG_DRM_IMX8MP_LDB: imx8mp-ldb.ko
# CONFIG_DRM_FSL_IMX_LVDS_BRIDGE: fsl-imx-ldb.ko
# CONFIG_DRM_ITE_IT6263: it6263.ko
# CONFIG_DRM_IMX_SEC_DSIM: sec-dsim.ko sec_mipi_dsim-imx.ko
# CONFIG_DRM_IMX_HDMI: dw-hdmi.ko dw_hdmi-imx.ko imx8mp-hdmi-pavi.ko
# CONFIG_DRM_IMX: imxdrm.ko, imx-lcdif-crtc.ko
# CONFIG_IMX_LCDIFV3_CORE: imx-lcdifv3-core.ko imx-lcdifv3-crtc.ko
# CONFIG_USB_DWC3: dwc3-haps.ko dwc3-imx8mp.ko dwc3-of-simple.ko dwc3-qcom.ko dwc3.ko
# CONFIG_DRM_PANEL_SIMPLE: panel-simple.ko
# CONFIG_TYPEC_SWITCH_GPIO: gpio-switch.ko
# CONFIG_TYPEC_TCPCI: tcpci.ko
# CONFIG_PHY_FSL_IMX8MQ_USB: phy-fsl-imx8mq-usb.ko
# CONFIG_PHY_FSL_IMX_PCIE: phy-fsl-imx8-pcie.ko
# CONFIG_USB_XHCI_HCD: xhci-hcd.ko xhci-pci.ko xhci-plat-hcd.ko, usb host driver
# CONFIG_KEYBOARD_SNVS_PWRKEY: snvs_pwrkey.ko, snvs power key driver
# CONFIG_RESET_IMX7: reset-imx7.ko
# CONFIG_RESET_IMX_HDMIMIX: reset-imx-audiomix.ko
# CONFIG_RESET_IMX_AUDIOMIX: reset-imx-hdmimix.ko
# CONFIG_IMX8M_BUSFREQ: busfreq-imx8mq.ko
# CONFIG_IMX_IRQSTEER: irq-imx-irqsteer.ko
# CONFIG_GPIO_MXC: gpio-generic.ko gpio-mxc.ko
# CONFIG_TIMER_IMX_SYS_CTR: timer-imx-sysctr.ko
# CONFIG_NVMEM_IMX_OCOTP: nvmem-imx-ocotp.ko
# CONFIG_CPUFREQ_DT: cpufreq-dt.ko
# CONFIG_ARM_IMX_CPUFREQ_DT: imx-cpufreq-dt.ko
# CONFIG_VIDEO_OV5640: ov5640.ko, ov5640 sensor driver
# CONFIG_VIDEO_IMX_CAPTURE: imx8-media-dev.ko, imx8-isi-cap.ko, imx8-isi-hw.ko, imx8-isi-m2m.ko, imx8-mipi-csi2-sam.ko, imx isi and mipi driver

ifeq ($(IMX8MP_USES_GKI),true)
BOARD_VENDOR_RAMDISK_KERNEL_MODULES +=     \
    $(KERNEL_OUT)/drivers/soc/imx/soc-imx8m.ko \
    $(KERNEL_OUT)/drivers/soc/imx/mu/mx8_mu.ko \
    $(KERNEL_OUT)/drivers/clk/imx/mxc-clk.ko \
    $(KERNEL_OUT)/drivers/clk/imx/clk-imx8mp.ko \
    $(KERNEL_OUT)/drivers/clk/imx/clk-blk-ctrl.ko \
    $(KERNEL_OUT)/drivers/soc/imx/imx8m_pm_domains.ko \
    $(KERNEL_OUT)/drivers/clocksource/timer-imx-sysctr.ko \
    $(KERNEL_OUT)/drivers/soc/imx/busfreq-imx8mq.ko \
    $(KERNEL_OUT)/drivers/irqchip/irq-imx-irqsteer.ko \
    $(KERNEL_OUT)/drivers/pinctrl/freescale/pinctrl-imx.ko \
    $(KERNEL_OUT)/drivers/pinctrl/freescale/pinctrl-imx8mp.ko \
    $(KERNEL_OUT)/drivers/gpio/gpio-mxc.ko \
    $(KERNEL_OUT)/drivers/tty/serial/imx.ko \
    $(KERNEL_OUT)/drivers/regulator/gpio-regulator.ko \
    $(KERNEL_OUT)/drivers/watchdog/imx2_wdt.ko \
    $(KERNEL_OUT)/drivers/i2c/busses/i2c-imx.ko \
    $(KERNEL_OUT)/drivers/regulator/pca9450-regulator.ko \
    $(KERNEL_OUT)/drivers/pwm/pwm-imx27.ko \
    $(KERNEL_OUT)/drivers/video/backlight/pwm_bl.ko \
    $(KERNEL_OUT)/drivers/mmc/host/cqhci.ko \
    $(KERNEL_OUT)/drivers/mmc/host/sdhci-esdhc-imx.ko \
    $(KERNEL_OUT)/drivers/staging/android/ion/ion-alloc.ko \
    $(KERNEL_OUT)/drivers/staging/android/ion/heaps/ion_sys_heap.ko \
    $(KERNEL_OUT)/drivers/staging/android/ion/heaps/ion_cma_heap.ko \
    $(KERNEL_OUT)/drivers/staging/android/ion/heaps/ion_unmapped_heap.ko \
    $(KERNEL_OUT)/drivers/reset/reset-imx7.ko \
    $(KERNEL_OUT)/drivers/phy/freescale/phy-fsl-imx8mp-lvds.ko \
    $(KERNEL_OUT)/drivers/phy/freescale/phy-fsl-samsung-hdmi.ko \
    $(KERNEL_OUT)/drivers/phy/freescale/phy-fsl-imx8mq-usb.ko \
    $(KERNEL_OUT)/drivers/phy/freescale/phy-fsl-imx8-pcie.ko \
    $(KERNEL_OUT)/drivers/input/keyboard/snvs_pwrkey.ko \
    $(KERNEL_OUT)/drivers/input/touchscreen/synaptics_dsx/synaptics_dsx_i2c.ko \
    $(KERNEL_OUT)/drivers/gpu/imx/lcdif/imx-lcdif-core.ko \
    $(KERNEL_OUT)/drivers/gpu/drm/bridge/adv7511/adv7511.ko \
    $(KERNEL_OUT)/drivers/gpu/drm/bridge/cadence/cdns_mhdp_drmcore.ko \
    $(KERNEL_OUT)/drivers/gpu/drm/bridge/fsl-imx-ldb.ko \
    $(KERNEL_OUT)/drivers/gpu/drm/bridge/it6263.ko \
    $(KERNEL_OUT)/drivers/gpu/drm/bridge/sec-dsim.ko \
    $(KERNEL_OUT)/drivers/gpu/drm/bridge/synopsys/dw-hdmi.ko \
    $(KERNEL_OUT)/drivers/gpu/drm/imx/mhdp/cdns_mhdp_imx.ko \
    $(KERNEL_OUT)/drivers/gpu/drm/imx/dw_hdmi-imx.ko \
    $(KERNEL_OUT)/drivers/gpu/drm/imx/imx8mp-hdmi-pavi.ko \
    $(KERNEL_OUT)/drivers/gpu/drm/imx/imx8mp-ldb.ko \
    $(KERNEL_OUT)/drivers/gpu/drm/imx/imxdrm.ko \
    $(KERNEL_OUT)/drivers/gpu/drm/imx/lcdif/imx-lcdif-crtc.ko \
    $(KERNEL_OUT)/drivers/gpu/drm/imx/lcdifv3/imx-lcdifv3-crtc.ko \
    $(KERNEL_OUT)/drivers/gpu/imx/lcdifv3/imx-lcdifv3-core.ko \
    $(KERNEL_OUT)/drivers/gpu/drm/imx/sec_mipi_dsim-imx.ko \
    $(KERNEL_OUT)/drivers/gpu/drm/panel/panel-raydium-rm67191.ko \
    $(KERNEL_OUT)/drivers/gpu/drm/panel/panel-simple.ko \
    $(KERNEL_OUT)/drivers/usb/dwc3/dwc3-imx8mp.ko \
    $(KERNEL_OUT)/drivers/usb/typec/mux/gpio-switch.ko \
    $(KERNEL_OUT)/drivers/power/supply/dummy_battery.ko \
    $(KERNEL_OUT)/drivers/nvmem/nvmem-imx-ocotp.ko \
    $(KERNEL_OUT)/drivers/thermal/device_cooling.ko \
    $(KERNEL_OUT)/drivers/thermal/imx8mm_thermal.ko \
    $(KERNEL_OUT)/drivers/cpufreq/cpufreq-dt.ko \
    $(KERNEL_OUT)/drivers/cpufreq/imx-cpufreq-dt.ko \
    $(KERNEL_OUT)/drivers/media/v4l2-core/v4l2-fwnode.ko \
    $(KERNEL_OUT)/drivers/media/i2c/ov5640.ko \
    $(KERNEL_OUT)/drivers/staging/media/imx/imx8-capture.ko \
    $(KERNEL_OUT)/drivers/staging/media/imx/imx8-isi-cap.ko \
    $(KERNEL_OUT)/drivers/staging/media/imx/imx8-isi-hw.ko \
    $(KERNEL_OUT)/drivers/staging/media/imx/imx8-isi-m2m.ko \
    $(KERNEL_OUT)/drivers/staging/media/imx/imx8-mipi-csi2-sam.ko \
    $(KERNEL_OUT)/drivers/trusty/trusty-core.ko \
    $(KERNEL_OUT)/drivers/trusty/trusty-irq.ko \
    $(KERNEL_OUT)/drivers/trusty/trusty-log.ko \
    $(KERNEL_OUT)/drivers/trusty/trusty-virtio.ko \
    $(KERNEL_OUT)/drivers/trusty/trusty-ipc.ko \
    $(TARGET_OUT_INTERMEDIATES)/VVCAM_OBJ/basler-camera-driver-vvcam.ko \
    $(TARGET_OUT_INTERMEDIATES)/VVCAM_OBJ/vvcam-video.ko \
    $(TARGET_OUT_INTERMEDIATES)/VVCAM_OBJ/vvcam-dwe.ko \
    $(TARGET_OUT_INTERMEDIATES)/VVCAM_OBJ/vvcam-isp.ko \
    $(KERNEL_OUT)/net/can/can.ko \
    $(KERNEL_OUT)/net/can/can-raw.ko \
    $(KERNEL_OUT)/net/can/can-bcm.ko \
    $(KERNEL_OUT)/net/can/can-gw.ko \
    $(KERNEL_OUT)/drivers/net/can/dev/can-dev.ko \
    $(KERNEL_OUT)/drivers/spi/spi-imx.ko \
    $(KERNEL_OUT)/drivers/net/can/flexcan.ko \
    $(KERNEL_OUT)/drivers/net/can/spi/mcp251xfd/mcp251xfd.ko \
    $(KERNEL_OUT)/drivers/staging/media/imx/imx8-media-dev.ko \
    $(KERNEL_OUT)/net/rfkill/rfkill-gpio.ko \
    $(KERNEL_OUT)/drivers/extcon/extcon-usb-gpio.ko \
    $(KERNEL_OUT)/sound/soc/codecs/snd-soc-wm8904.ko

endif

# -------@block_memory-------
#Enable this to config 1GB ddr on evk_imx8mp
LOW_MEMORY := false

# -------@block_security-------
#Enable this to include trusty support
PRODUCT_IMX_TRUSTY := true
