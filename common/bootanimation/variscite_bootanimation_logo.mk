# Variscite boot animation logo override
#
# Include this file from your device product Makefile:
#
#   -include device/variscite/common/bootanimation/variscite_bootanimation_logo.mk
#

$(call soong_config_set,bootanimation,logo_mask,images/variscite-logo-mask.png)
$(call soong_config_set,bootanimation,logo_shine,images/variscite-logo-shine.png)
