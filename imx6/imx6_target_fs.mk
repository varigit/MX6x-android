# BUILD_TARGET_FS is from BoardConfig or build environment
# e.g make BUILD_TARGET_FS=ubifs for NAND device
# e.g make BUILD_TARGET_FS=ext4 for eMMC/SD
# sabreauto_6dq default target for EXT4
#
ifeq ($(BUILD_TARGET_FS),ubifs)
# build ubifs for nand devices
TARGET_USERIMAGES_USE_UBIFS := true
TARGET_USERIMAGES_USE_EXT4 := false
else
# build for ext4
TARGET_USERIMAGES_USE_EXT4 := true
ifeq ($(BUILD_TARGET_FS),f2fs)
TARGET_USERIMAGES_USE_F2FS := true
endif
TARGET_USERIMAGES_USE_UBIFS := false
endif # BUILD_TARGET_FS

