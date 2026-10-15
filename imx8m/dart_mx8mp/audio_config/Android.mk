LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)
LOCAL_MODULE := var-wm8904-config.json
LOCAL_MODULE_STEM := wm8904_config.json
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE_CLASS := ETC
LOCAL_VENDOR_MODULE := true
LOCAL_MODULE_PATH := $(TARGET_OUT_VENDOR)/vendor_overlay_audio/som/vendor/etc/configs/audio/
LOCAL_SRC_FILES := $(LOCAL_MODULE_STEM)
include $(BUILD_PREBUILT)

include $(CLEAR_VARS)
LOCAL_MODULE := var-wm8904-config-carrier.json
LOCAL_MODULE_STEM := wm8904_config_carrier.json
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE_CLASS := ETC
LOCAL_VENDOR_MODULE := true
LOCAL_MODULE_PATH := $(TARGET_OUT_VENDOR)/vendor_overlay_audio/carrier/vendor/etc/configs/audio/
LOCAL_SRC_FILES := $(LOCAL_MODULE_STEM)
include $(BUILD_PREBUILT)

#### make sure /vendor/etc/configs/audio/ is created
include $(CLEAR_VARS)
LOCAL_MODULE := var-audio-config
LOCAL_MODULE_STEM := varaudio
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE_CLASS := ETC
LOCAL_VENDOR_MODULE := true
LOCAL_MODULE_PATH := $(TARGET_OUT_VENDOR)/etc/configs/audio/
LOCAL_SRC_FILES := $(LOCAL_MODULE_STEM)

include $(BUILD_PREBUILT)
