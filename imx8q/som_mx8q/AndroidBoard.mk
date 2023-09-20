LOCAL_PATH := $(call my-dir)

include device/variscite/common/VarPathConfig.mk
include device/nxp/common/build/dtbo.mk
include device/nxp/common/build/imx-recovery.mk
include device/nxp/common/build/gpt.mk
include $(FSL_PROPRIETARY_PATH)/fsl-proprietary/media-profile/media-profile.mk

ifneq ($(BOARD_OTA_BOOTLOADERIMAGE),)
  INSTALLED_RADIOIMAGE_TARGET += $(PRODUCT_OUT)/bootloader.img
  BOARD_PACK_RADIOIMAGES += bootloader.img
endif

-include $(IMX_MEDIA_CODEC_XML_PATH)/mediacodec-profile/mediacodec-profile.mk
