# This is a FSL Android Reference Design platform based on i.MX8MQ board
# It will inherit from FSL core product which in turn inherit from Google generic

PRODUCT_IMX_DRM := true

# copy drm specific files before inherit dart_mx8m.mk, otherwise copy is ignored
PRODUCT_COPY_FILES += \
	device/variscite/dart_mx8m/audio_policy_configuration_drm.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio_policy_configuration.xml \
	device/variscite/dart_mx8m/init.imx8mq.rc:root/init.freescale.imx8mq.main.rc \
	device/variscite/dart_mx8m/init.imx8mq.drm.rc:root/init.freescale.imx8mq.rc \


$(call inherit-product, $(TOPDIR)device/fsl/imx8/optee-packages.mk)
$(call inherit-product, $(TOPDIR)device/variscite/imx8/dart_mx8m.mk)

# Overrides
TARGET_KERNEL_DEFCONF := imx8m_var_dart_android_drm_defconfig
PRODUCT_NAME := dart_mx8m_drm

CFG_SECURE_DATA_PATH ?= y
CFG_TEE_SDP_MEM_BASE := 0xcc000000
CFG_TEE_SDP_MEM_SIZE := 0x02000000
DECRYPTED_BUFFER_START	:= $(CFG_TEE_SDP_MEM_BASE)
DECRYPTED_BUFFER_LEN	:= $(CFG_TEE_SDP_MEM_SIZE)
DECODED_BUFFER_START	:= 0xCE000000
DECODED_BUFFER_LEN		:= 0x30000000

# Exoplayer
PRODUCT_PACKAGES += \
	exoplayer \

# Playready
PRODUCT_COPY_FILES += \
	vendor/nxp/drm_artifacts/playready/Samples/devcert.dat:$(TARGET_COPY_OUT_VENDOR)/playready/devcert.dat \
	vendor/nxp/drm_artifacts/playready/Samples/priv.dat:$(TARGET_COPY_OUT_VENDOR)/playready/priv.dat \
	vendor/nxp/drm_artifacts/playready/ta/82dbae9c-9ce0-47e0-a1cb4048cfdb84aa.ta:$(TARGET_OUT)/system/lib/optee_armtz/82dbae9c-9ce0-47e0-a1cb4048cfdb84aa.ta \
	vendor/nxp/drm_artifacts/playready/bgroupcert.dat:$(TARGET_COPY_OUT_VENDOR)/playready/bgroupcert.dat \
	vendor/nxp/drm_artifacts/playready/zgpriv_protected.dat:$(TARGET_COPY_OUT_VENDOR)/playready/zgpriv_protected.dat \
	vendor/nxp/drm_artifacts/playready/optee_playready_test:$(TARGET_OUT)/system/bin/optee_playready_test

ifneq ($(CFG_BUILD_DRM_FROM_SOURCES),y)
PRODUCT_COPY_FILES += \
	vendor/nxp/drm_artifacts/playready/libdrmplayreadyplugin.so:$(TARGET_OUT)/vendor/lib64/mediadrm/libdrmplayreadyplugin.so
endif

ifneq ($(CFG_BUILD_DRM_FROM_SOURCES),y)
# Widevine
PRODUCT_COPY_FILES += \
	vendor/nxp/drm_artifacts/widevine/lib/liboemcrypto.so:$(TARGET_COPY_OUT_VENDOR)/lib/liboemcrypto.so \
	vendor/nxp/drm_artifacts/widevine/lib/libwvdrmengine.so:$(TARGET_COPY_OUT_VENDOR)/lib/mediadrm/libwvdrmengine.so \
	vendor/nxp/drm_artifacts/widevine/lib/libvtswidevine.so:$(TARGET_COPY_OUT_VENDOR)/lib/drm-vts-test-libs/libvtswidevine.so \
	vendor/nxp/drm_artifacts/widevine/lib64/liboemcrypto.so:$(TARGET_COPY_OUT_VENDOR)/lib64/liboemcrypto.so \
	vendor/nxp/drm_artifacts/widevine/lib64/libwvdrmengine.so:$(TARGET_COPY_OUT_VENDOR)/lib64/mediadrm/libwvdrmengine.so \
	vendor/nxp/drm_artifacts/widevine/lib64/libvtswidevine.so:$(TARGET_COPY_OUT_VENDOR)/lib64/drm-vts-test-libs/libvtswidevine.so \
	vendor/nxp/drm_artifacts/widevine/ta/706f6574-7765-6469-77656e6942656665.ta:$(TARGET_OUT)/system/lib/optee_armtz/706f6574-7765-6469-77656e6942656665.ta
endif
