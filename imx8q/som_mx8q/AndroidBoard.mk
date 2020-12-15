LOCAL_PATH := $(call my-dir)

include device/variscite/common/VarPathConfig.mk
include device/fsl/common/build/dtbo.mk
include device/fsl/common/build/imx-recovery.mk
include device/fsl/common/build/gpt.mk
include $(FSL_PROPRIETARY_PATH)/fsl-proprietary/media-profile/media-profile.mk

