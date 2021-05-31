LOCAL_PATH := $(call my-dir)

include device/variscite/common/VarPathConfig.mk
include device/nxp/common/build/dtbo.mk
include device/nxp/common/build/imx-recovery.mk
include device/nxp/common/build/gpt.mk
include $(FSL_PROPRIETARY_PATH)/fsl-proprietary/media-profile/media-profile.mk
include $(FSL_PROPRIETARY_PATH)/fsl-proprietary/sensor/fsl-sensor.mk
-include $(IMX_MEDIA_CODEC_XML_PATH)/mediacodec-profile/mediacodec-profile.mk
