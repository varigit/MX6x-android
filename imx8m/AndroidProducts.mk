# Copyright 2026 Variscite
PRODUCT_MAKEFILES := $(LOCAL_DIR)/dart_mx8mp/dart_mx8mp.mk

COMMON_LUNCH_CHOICES := \
    dart_mx8mp-var_stable-user \
    dart_mx8mp-var_stable-userdebug

PRODUCT_MAKEFILES += $(LOCAL_DIR)/dart_mx8mm/dart_mx8mm.mk

COMMON_LUNCH_CHOICES += \
    dart_mx8mm-var_stable-user \
    dart_mx8mm-var_stable-userdebug
