#!/bin/sh
# Sourced by device/nxp/common/build/uboot.mk from the Android source root.
# Use the same BSP paths as this product's ImxPathConfig.mk.
VARISCITE_PATH=vendor/variscite
IMX_MKIMAGE_PATH=vendor/variscite
FSL_PROPRIETARY_PATH=vendor/nxp

SM_PATH="${VARISCITE_PATH}/imx-sm"
OEI_PATH="${VARISCITE_PATH}/imx-oei"

# System Manager configurations:
# - dart-mx95: A55 only
# - dart-mx95-m7: Cortex-M7 logical machine for the RPMSG bootloader
# - dart-mx95-android: A55 secure resources for Trusty
SM_CONFIGS="dart-mx95 dart-mx95-m7 dart-mx95-android"

build_pre_image()
(
    sm_cross="${AARCH32_GCC_CROSS_COMPILE:?AARCH32_GCC_CROSS_COMPILE is required}"
    # Exported by UbootKernelBoardConfig.mk from TARGET_DRAM_SIZE_GB.
    ddr_config="${TARGET_DDR_CONFIG:?TARGET_DDR_CONFIG is required}"

    echo "Building imx-sm ..."
    make -C "$SM_PATH" really-clean || return 1
    for config in $SM_CONFIGS; do
        make -C "$SM_PATH" SM_CROSS_COMPILE="$sm_cross" cfg config="$config" >/dev/null || return 1
        make -C "$SM_PATH" SM_CROSS_COMPILE="$sm_cross" all config="$config" >/dev/null || return 1
    done

    echo "Building imx-oei with ${ddr_config} ..."
    make -C "$OEI_PATH" really-clean || return 1
    set -- OEI_CROSS_COMPILE="$sm_cross" board=mx95-var-dart r=b0 d=1
    make -C "$OEI_PATH" "$@" oei=ddr DDR_CONFIG="$ddr_config" all >/dev/null || return 1
    make -C "$OEI_PATH" "$@" oei=tcm all >/dev/null || return 1
)

build_imx_uboot()
(
    postfix=$1 variant=$2
    mkimage_dir="${IMX_MKIMAGE_PATH}/imx-mkimage"
    image_dir="${mkimage_dir}/iMX95"
    atf_dir="${VARISCITE_PATH}/arm-trusted-firmware"
    atf_cross="${AARCH64_GCC_CROSS_COMPILE:?AARCH64_GCC_CROSS_COMPILE is required}"

    case "$variant" in
    *-trusty-*) sm_config=dart-mx95-android ;;
    *-rpmsg-*) sm_config=dart-mx95-m7 ;;
    *) sm_config=dart-mx95 ;;
    esac

    cp "$OEI_PATH/build/mx95-var-dart/ddr/oei-m33-ddr.bin" "$image_dir/" || return 1
    cp "$OEI_PATH/build/mx95-var-dart/tcm/oei-m33-tcm.bin" "$image_dir/" || return 1
    cp "$SM_PATH/build/$sm_config/m33_image.bin" "$image_dir/" || return 1
    cp "${FSL_PROPRIETARY_PATH}/ele/mx95b0-ahab-container.img" "$image_dir/" || return 1
    cp "${UBOOT_OUT}/u-boot.${postfix}" "$image_dir/" || return 1
    cp "${UBOOT_OUT}/spl/u-boot-spl.bin" "$image_dir/" || return 1
    cp "${UBOOT_OUT}/tools/mkimage" "$image_dir/mkimage_uboot" || return 1
    cp "${FSL_PROPRIETARY_PATH}"/linux-firmware-imx/firmware/ddr/synopsys/lpddr5_[id]mem_* "$image_dir/" || return 1

    # NXP's Trusty for i.MX95 logs on LPUART1, the DART-MX95 console too.
    set -- CROSS_COMPILE="$atf_cross" PLAT=imx95
    rm -f "$image_dir/tee.bin"
    case "$variant" in *-trusty-*)
        cp "${FSL_PROPRIETARY_PATH}/fsl-proprietary/uboot-firmware/imx95/tee-imx95.bin" "$image_dir/tee.bin" || return 1
        set -- "$@" SPD=trusty
    esac
    make -C "$atf_dir" "$@" clean || return 1
    make -C "$atf_dir" "$@" bl31 -B || return 1
    cp "$atf_dir/build/imx95/release/bl31.bin" "$image_dir/bl31.bin" || return 1

    # The Cortex-M7 image is not packed into the container: U-Boot loads it
    # from the mcu_os partition (CONFIG_FLASH_MCUFIRMWARE_SUPPORT).
    # imx-mkimage sets MKIMG from $(PWD), so point PWD at its directory.
    make -C "$mkimage_dir" clean || return 1
    PWD="$(pwd)/$mkimage_dir" make -C "$mkimage_dir" SOC=iMX95 REV=B0 LPDDR_TYPE=lpddr5 OEI=YES flash_a55 || return 1

    case "$variant" in
    *-dual)
        cp "$image_dir/boot-spl-container.img" "${UBOOT_COLLECTION}/spl-${variant}.bin" || return 1
        cp "$image_dir/u-boot-atf-container.img" "${UBOOT_COLLECTION}/bootloader-${variant}.img" || return 1
        ;;
    *)
        cp "$image_dir/flash.bin" "${UBOOT_COLLECTION}/u-boot-${variant}.imx" || return 1
        ;;
    esac
)
