# -------@block_kernel_bootimg-------
KERNEL_NAME := Image.lz4
TARGET_KERNEL_ARCH := arm64
LOADABLE_KERNEL_MODULE ?= true

#ARM GPU driver module
BOARD_VENDOR_KERNEL_MODULES += \
    $(KERNEL_OUT)/drivers/gpu/arm/midgard/mali_kbase.ko

ifeq ($(LOADABLE_KERNEL_MODULE),true)
IMX_ANDROID_FIRST_STAGE_MODULES += \
    $(KERNEL_OUT)/drivers/hwmon/hwmon.ko \
    $(KERNEL_OUT)/drivers/hwmon/scmi-hwmon.ko \
    $(KERNEL_OUT)/drivers/firmware/arm_scmi/vendors/imx/imx-sm-lmm.ko \
    $(KERNEL_OUT)/drivers/firmware/arm_scmi/vendors/imx/imx-sm-cpu.ko \
    $(KERNEL_OUT)/drivers/firmware/arm_scmi/vendors/imx/imx-sm-bbm.ko \
    $(KERNEL_OUT)/drivers/firmware/arm_scmi/vendors/imx/imx-sm-misc.ko \
    $(KERNEL_OUT)/drivers/firmware/arm_scmi/scmi_power_control.ko \
    $(KERNEL_OUT)/drivers/iommu/arm/arm-smmu-v3/arm_smmu_v3.ko \
    $(KERNEL_OUT)/drivers/clk/clk-scmi.ko \
    $(KERNEL_OUT)/drivers/clk/imx/mxc-clk.ko \
    $(KERNEL_OUT)/drivers/clk/imx/clk-imx95-blk-ctl.ko \
    $(KERNEL_OUT)/drivers/clocksource/timer-imx-sysctr.ko \
    $(KERNEL_OUT)/drivers/mailbox/imx-mailbox.ko \
    $(KERNEL_OUT)/drivers/rpmsg/rpmsg_ns.ko \
    $(KERNEL_OUT)/drivers/rpmsg/virtio_rpmsg_bus.ko \
    $(KERNEL_OUT)/drivers/firmware/imx/sm-cpu.ko \
    $(KERNEL_OUT)/drivers/firmware/imx/sm-lmm.ko \
    $(KERNEL_OUT)/drivers/remoteproc/imx_rproc.ko \
    $(KERNEL_OUT)/drivers/pinctrl/freescale/pinctrl-imx.ko \
    $(KERNEL_OUT)/drivers/pinctrl/freescale/pinctrl-imx-scmi.ko \
    $(KERNEL_OUT)/drivers/dma/fsl-edma.ko \
    $(KERNEL_OUT)/drivers/tty/serial/fsl_lpuart.ko \
    $(KERNEL_OUT)/drivers/trusty/trusty-core.ko \
    $(KERNEL_OUT)/drivers/trusty/trusty-log.ko \
    $(KERNEL_OUT)/drivers/trusty/trusty-ipc.ko \
    $(KERNEL_OUT)/drivers/trusty/trusty-virtio.ko \
    $(KERNEL_OUT)/drivers/i2c/busses/i2c-imx-lpi2c.ko \
    $(KERNEL_OUT)/drivers/i2c/i2c-dev.ko \
    $(KERNEL_OUT)/drivers/i2c/busses/i2c-rpmsg-imx.ko \
    $(KERNEL_OUT)/drivers/i2c/i2c-mux.ko \
    $(KERNEL_OUT)/drivers/irqchip/irq-imx-irqsteer.ko \
    $(KERNEL_OUT)/drivers/rtc/rtc-imx-sm-bbm.ko \
    $(KERNEL_OUT)/drivers/firmware/imx/sm-misc.ko \
    $(KERNEL_OUT)/drivers/cpufreq/cpufreq-dt.ko \
    $(KERNEL_OUT)/drivers/watchdog/imx7ulp_wdt.ko \
    $(KERNEL_OUT)/drivers/firmware/imx/sec_enclave.ko \
    $(KERNEL_OUT)/drivers/mmc/host/cqhci.ko \
    $(KERNEL_OUT)/drivers/soc/imx/busfreq-imx8mq.ko \
    $(KERNEL_OUT)/drivers/mmc/host/sdhci-esdhc-imx.ko \
    $(KERNEL_OUT)/drivers/nvmem/nvmem-imx-ocotp.ko \
    $(KERNEL_OUT)/drivers/nvmem/nvmem-imx-ocotp-fsb-s400.ko \
    $(KERNEL_OUT)/drivers/mmc/core/pwrseq_simple.ko \
    $(KERNEL_OUT)/drivers/pwm/pwm-imx-tpm.ko \
    $(KERNEL_OUT)/drivers/soc/imx/soc-imx9.ko \
    $(KERNEL_OUT)/drivers/gpio/gpio-adp5585.ko \
    $(KERNEL_OUT)/drivers/gpio/gpio-pca953x.ko \
    $(KERNEL_OUT)/drivers/gpio/gpio-vf610.ko

IMX_RECOVERY_FIRST_STAGE_ADDITION_MODULES += \
    $(KERNEL_OUT)/drivers/video/backlight/led_bl.ko \
    $(KERNEL_OUT)/drivers/video/backlight/pwm_bl.ko \
    $(KERNEL_OUT)/drivers/dma-buf/heaps/system_heap.ko \
    $(KERNEL_OUT)/drivers/dma-buf/heaps/dsp_heap.ko \
    $(KERNEL_OUT)/drivers/dma-buf/heaps/cma_heap.ko \
    $(KERNEL_OUT)/drivers/dma-buf/dma-buf-imx.ko \
    $(KERNEL_OUT)/drivers/mfd/maxim_serdes.ko \
    $(KERNEL_OUT)/drivers/mfd/max96752-core.ko \
    $(KERNEL_OUT)/drivers/mfd/max96752-i2c.ko \
    $(KERNEL_OUT)/drivers/mfd/adp5585.ko \
    $(KERNEL_OUT)/drivers/mfd/max96789-core.ko \
    $(KERNEL_OUT)/drivers/mfd/max96789-i2c.ko \
    $(KERNEL_OUT)/drivers/power/supply/dummy_battery.ko \
    $(KERNEL_OUT)/drivers/pwm/pwm-adp5585.ko \
    $(KERNEL_OUT)/drivers/phy/freescale/phy-fsl-imx8mq-usb.ko \
    $(KERNEL_OUT)/drivers/input/touchscreen/focaltech_ts.ko \
    $(KERNEL_OUT)/drivers/input/touchscreen/ilitek_ts_i2c.ko \
    $(KERNEL_OUT)/drivers/input/touchscreen/exc3000.ko \
    $(KERNEL_OUT)/drivers/input/keyboard/imx-sm-bbm-key.ko \
    $(KERNEL_OUT)/drivers/usb/chipidea/usbmisc_imx.ko \
    $(KERNEL_OUT)/drivers/usb/common/ulpi.ko \
    $(KERNEL_OUT)/drivers/usb/chipidea/ci_hdrc_imx.ko \
    $(KERNEL_OUT)/drivers/usb/chipidea/ci_hdrc.ko \
    $(KERNEL_OUT)/drivers/usb/phy/phy-generic.ko \
    $(KERNEL_OUT)/drivers/usb/dwc3/dwc3-imx8mp.ko \
    $(KERNEL_OUT)/drivers/usb/typec/mux/gpio-switch.ko \
    $(KERNEL_OUT)/drivers/mux/mux-core.ko \
    $(KERNEL_OUT)/drivers/mux/mux-mmio.ko \
    $(KERNEL_OUT)/drivers/phy/freescale/phy-fsl-imx9-dphy-rx.ko \
    $(KERNEL_OUT)/drivers/phy/freescale/phy-fsl-imx8mp-lvds.ko \
    $(KERNEL_OUT)/drivers/gpu/drm/drm_dma_helper.ko \
    $(KERNEL_OUT)/drivers/gpu/drm/bridge/it6161.ko \
    $(KERNEL_OUT)/drivers/gpu/drm/bridge/max96752-lvds.ko \
    $(KERNEL_OUT)/drivers/gpu/drm/bridge/display-connector.ko \
    $(KERNEL_OUT)/drivers/gpu/drm/bridge/adv7511/adv7511.ko \
    $(KERNEL_OUT)/drivers/gpu/drm/bridge/fsl-imx-ldb.ko \
    $(KERNEL_OUT)/drivers/gpu/drm/bridge/max96789-dsi.ko \
    $(KERNEL_OUT)/drivers/gpu/drm/bridge/it6263.ko \
    $(KERNEL_OUT)/drivers/gpu/drm/bridge/ti-sn65dsi83.ko \
    $(KERNEL_OUT)/drivers/gpu/drm/bridge/nwl-dsi.ko \
    $(KERNEL_OUT)/drivers/gpu/drm/bridge/lontium-lt8912b.ko \
    $(KERNEL_OUT)/drivers/gpu/drm/bridge/lontium-lt9611uxc.ko \
    $(KERNEL_OUT)/drivers/gpu/drm/bridge/imx/imx95-pixel-link.ko \
    $(KERNEL_OUT)/drivers/gpu/drm/bridge/imx/imx95-pixel-interleaver.ko \
    $(KERNEL_OUT)/drivers/gpu/drm/bridge/imx/imx-ldb-helper.ko \
    $(KERNEL_OUT)/drivers/gpu/drm/bridge/imx/imx95-ldb.ko \
    $(KERNEL_OUT)/drivers/gpu/drm/bridge/synopsys/dw-mipi-dsi.ko \
    $(KERNEL_OUT)/drivers/gpu/drm/bridge/imx/imx95-mipi-dsi.ko \
    $(KERNEL_OUT)/drivers/gpu/drm/mxsfb/imx-lcdif.ko \
    $(KERNEL_OUT)/drivers/gpu/drm/panel/panel-raydium-rm67191.ko \
    $(KERNEL_OUT)/drivers/gpu/drm/panel/panel-nxp-rm67162.ko \
    $(KERNEL_OUT)/drivers/gpu/drm/panel/panel-simple.ko \
    $(KERNEL_OUT)/drivers/gpu/drm/panel/panel-raydium-rm692c9.ko \
    $(KERNEL_OUT)/drivers/gpu/drm/panel/panel-rocktech-hx8394f.ko \
    $(KERNEL_OUT)/drivers/gpu/drm/panel/panel-lvds.ko \
    $(KERNEL_OUT)/drivers/gpu/drm/display/drm_display_helper.ko \
    $(KERNEL_OUT)/drivers/gpu/drm/imx/dpu95/imx95-dpu-drm.ko \
    $(KERNEL_OUT)/drivers/gpu/drm/imx/display-imx-rpmsg.ko \
    $(KERNEL_OUT)/drivers/media/platform/nxp/imx8-isi/imx8-isi.ko \
    $(KERNEL_OUT)/drivers/media/platform/nxp/imx-csi-formatter.ko \
    $(KERNEL_OUT)/drivers/media/platform/nxp/dwc-mipi-csi2.ko

BOARD_VENDOR_RAMDISK_KERNEL_MODULES += \
    $(IMX_ANDROID_FIRST_STAGE_MODULES) \
    $(IMX_RECOVERY_FIRST_STAGE_ADDITION_MODULES)

BOARD_VENDOR_KERNEL_MODULES += \
    $(KERNEL_OUT)/drivers/media/i2c/ap1302.ko \
    $(KERNEL_OUT)/mm/zsmalloc.ko \
    $(KERNEL_OUT)/drivers/block/zram/zram.ko \
    $(KERNEL_OUT)/net/rfkill/rfkill.ko \
    $(KERNEL_OUT)/net/wireless/cfg80211.ko \
    $(KERNEL_OUT)/lib/crypto/libarc4.ko \
    $(KERNEL_OUT)/net/mac80211/mac80211.ko \
    $(KERNEL_OUT)/drivers/perf/fsl_imx9_ddr_perf.ko \
    $(KERNEL_OUT)/drivers/iio/adc/imx93_adc.ko \
    $(KERNEL_OUT)/drivers/reset/gpio-reset.ko \
    $(KERNEL_OUT)/drivers/power/reset/imx-sm-reset.ko \
    $(KERNEL_OUT)/drivers/pci/controller/dwc/pci-imx6.ko \
    $(KERNEL_OUT)/drivers/spi/spidev.ko \
    $(KERNEL_OUT)/drivers/spi/spi-bitbang.ko \
    $(KERNEL_OUT)/drivers/spi/spi-nxp-fspi.ko \
    $(KERNEL_OUT)/drivers/spi/spi-fsl-lpspi.ko \
    $(KERNEL_OUT)/drivers/mtd/mtd.ko \
    $(KERNEL_OUT)/drivers/mtd/spi-nor/spi-nor.ko \
    $(KERNEL_OUT)/drivers/leds/leds-gpio.ko \
    $(KERNEL_OUT)/drivers/leds/leds-pca995x.ko \
    $(KERNEL_OUT)/drivers/leds/leds-pca963x.ko \
    $(KERNEL_OUT)/drivers/mxc/vpu/wave6/wave6-vpu-ctrl.ko \
    $(KERNEL_OUT)/drivers/mxc/vpu/wave6/wave6.ko \
    $(KERNEL_OUT)/drivers/media/i2c/ox05b1s/ox05b1s_mipi.ko \
    $(KERNEL_OUT)/drivers/media/v4l2-core/v4l2-jpeg.ko \
    $(KERNEL_OUT)/drivers/media/platform/nxp/imx-jpeg/mxc-jpeg-encdec.ko \
    $(KERNEL_OUT)/drivers/media/platform/nxp/neoisp/neoisp.ko \
    $(KERNEL_OUT)/sound/soc/fsl/imx-pcm-dma.ko \
    $(KERNEL_OUT)/sound/soc/fsl/imx-pcm-rpmsg.ko \
    $(KERNEL_OUT)/sound/soc/fsl/snd-soc-fsl-utils.ko \
    $(KERNEL_OUT)/sound/soc/fsl/snd-soc-fsl-micfil.ko \
    $(KERNEL_OUT)/sound/soc/fsl/snd-soc-fsl-mqs.ko \
    $(KERNEL_OUT)/sound/soc/fsl/snd-soc-fsl-asrc.ko \
    $(KERNEL_OUT)/sound/soc/fsl/snd-soc-fsl-sai.ko \
    $(KERNEL_OUT)/sound/soc/codecs/snd-soc-bt-sco.ko \
    $(KERNEL_OUT)/sound/soc/generic/snd-soc-simple-card-utils.ko \
    $(KERNEL_OUT)/sound/soc/generic/snd-soc-simple-card.ko \
    $(KERNEL_OUT)/sound/soc/generic/snd-soc-audio-graph-card2.ko \
    $(KERNEL_OUT)/sound/soc/fsl/snd-soc-imx-card.ko \
    $(KERNEL_OUT)/sound/soc/fsl/snd-soc-imx-audmux.ko \
    $(KERNEL_OUT)/sound/soc/fsl/snd-soc-imx-rpmsg.ko \
    $(KERNEL_OUT)/sound/soc/fsl/snd-soc-fsl-asoc-card.ko \
    $(KERNEL_OUT)/sound/soc/fsl/imx-audio-rpmsg.ko \
    $(KERNEL_OUT)/sound/soc/fsl/snd-soc-fsl-rpmsg.ko \
    $(KERNEL_OUT)/sound/soc/codecs/snd-soc-ak4458.ko \
    $(KERNEL_OUT)/sound/soc/codecs/snd-soc-ak5558.ko \
    $(KERNEL_OUT)/sound/soc/codecs/snd-soc-wm8962.ko \
    $(KERNEL_OUT)/sound/soc/codecs/snd-soc-wm8904.ko \
    $(KERNEL_OUT)/sound/soc/codecs/snd-soc-cs42xx8.ko \
    $(KERNEL_OUT)/sound/soc/codecs/snd-soc-cs42xx8-i2c.ko \
    $(KERNEL_OUT)/drivers/net/phy/aquantia/aquantia.ko \
    $(KERNEL_OUT)/drivers/pps/pps_core.ko \
    $(KERNEL_OUT)/drivers/ptp/ptp.ko \
    $(KERNEL_OUT)/drivers/net/ethernet/freescale/enetc/nxp-netc-lib.ko \
    $(KERNEL_OUT)/drivers/net/ethernet/freescale/enetc/nxp-netc-blk-ctrl.ko \
    $(KERNEL_OUT)/drivers/ptp/ptp_netc.ko \
    $(KERNEL_OUT)/drivers/ptp/ptp-qoriq.ko \
    $(KERNEL_OUT)/drivers/net/ethernet/freescale/enetc/fsl-enetc-ptp.ko \
    $(KERNEL_OUT)/drivers/net/pcs/pcs-lynx.ko \
    $(KERNEL_OUT)/drivers/net/pcs/pcs_xpcs.ko \
    $(KERNEL_OUT)/drivers/net/ethernet/freescale/enetc/fsl-enetc-mdio.ko \
    $(KERNEL_OUT)/drivers/net/ethernet/freescale/enetc/fsl-enetc-core.ko \
    $(KERNEL_OUT)/lib/crc-itu-t.ko \
    $(KERNEL_OUT)/drivers/net/ethernet/freescale/enetc/fsl-enetc-vf.ko \
    $(KERNEL_OUT)/drivers/net/ethernet/freescale/enetc/fsl-enetc4.ko \
    $(KERNEL_OUT)/drivers/net/phy/realtek.ko

ifeq ($(ENABLE_CONTEXTHUB), true)
BOARD_VENDOR_KERNEL_MODULES += \
    $(KERNEL_OUT)/drivers/rpmsg/imx_rpmsg_chre.ko
endif
endif

#NXP 8997 wifi driver module
BOARD_VENDOR_KERNEL_MODULES += \
    $(TARGET_OUT_INTERMEDIATES)/MXMWIFI_OBJ/mlan.ko \
    $(TARGET_OUT_INTERMEDIATES)/MXMWIFI_OBJ/moal.ko

#neutron driver module
BOARD_VENDOR_KERNEL_MODULES += \
    $(KERNEL_OUT)/drivers/remoteproc/imx_neutron_rproc.ko \
    $(KERNEL_OUT)/drivers/staging/neutron/neutron.ko

ifeq ($(LOADABLE_KERNEL_MODULE),true)
    BOARD_VENDOR_RAMDISK_KERNEL_MODULES_LOAD := \
        $(foreach m,$(IMX_ANDROID_FIRST_STAGE_MODULES),$(notdir $(m)))
    BOARD_VENDOR_RAMDISK_RECOVERY_KERNEL_MODULES_LOAD := \
        $(foreach m,$(BOARD_VENDOR_RAMDISK_KERNEL_MODULES),$(notdir $(m)))

    BOARD_VENDOR_KERNEL_MODULES_LOAD := \
        $(foreach m,$(IMX_RECOVERY_FIRST_STAGE_ADDITION_MODULES),$(notdir $(m))) \
        $(foreach m,$(BOARD_VENDOR_KERNEL_MODULES),$(notdir $(m)))

    BOARD_VENDOR_RAMDISK_CHARGER_KERNEL_MODULES_LOAD := \
        $(BOARD_VENDOR_RAMDISK_RECOVERY_KERNEL_MODULES_LOAD)

    BOARD_VENDOR_KERNEL_MODULES += \
        $(IMX_RECOVERY_FIRST_STAGE_ADDITION_MODULES)
endif


# -------@block_memory-------
#Enable this to config 1GB ddr on evk_95
LOW_MEMORY := false

# -------@block_security-------
#Enable this to include trusty support
PRODUCT_IMX_TRUSTY := true

# -------@block_storage-------
# the bootloader image used in dual-bootloader OTA
BOARD_OTA_BOOTLOADERIMAGE := bootloader-imx95-trusty-dual.img
