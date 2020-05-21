LOCAL_PATH:= $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE := init.brcm.wifibt.8qm.sh
LOCAL_MODULE_PATH := $(TARGET_OUT_VENDOR)/bin
LOCAL_SRC_FILES := $(LOCAL_MODULE)
LOCAL_MODULE_CLASS := SCRIPTS
LOCAL_SRC_FILES:= ../init.brcm.wifibt.8qm.sh
LOCAL_POST_INSTALL_CMD := mkdir -p $(TARGET_OUT_VENDOR)/bin; \
    cd $(TARGET_OUT_VENDOR)/bin; \
    mv init.brcm.wifibt.8qm.sh init.brcm.wifibt.sh; \
    ln -sf init.brcm.wifibt.sh init.brcm.wifibt.suspend.sh; \
    ln -sf init.brcm.wifibt.sh init.brcm.wifibt.resume.sh;

include $(BUILD_PREBUILT)
