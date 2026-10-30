#!/bin/sh
# Sourced by device/nxp/common/build/uboot.mk from the Android source root.
# Use the same BSP paths as this product's ImxPathConfig.mk.
VARISCITE_PATH=vendor/variscite
IMX_MKIMAGE_PATH=vendor/variscite
FSL_PROPRIETARY_PATH=vendor/nxp

build_pre_image()
{
    :
}

build_imx_uboot()
(
    postfix=$1 variant=$2
    mkimage_dir="${IMX_MKIMAGE_PATH}/imx-mkimage"
    image_dir="${mkimage_dir}/iMX8M"
    atf_dir="${VARISCITE_PATH}/arm-trusted-firmware"
    atf_cross="${AARCH64_GCC_CROSS_COMPILE:?AARCH64_GCC_CROSS_COMPILE is required}"
    set -- CROSS_COMPILE="$atf_cross" CC="${atf_cross}gcc" AS="${atf_cross}gcc" PLAT=imx8mp IMX_ANDROID_BUILD=true

    case "$variant" in *-trusty-*)
        case "$variant" in
        *-var-som-*) tee_image="${FSL_PROPRIETARY_PATH}/fsl-proprietary/uboot-firmware/imx8m/tee-imx8mp.bin" ;;
        *) tee_image=device/variscite/imx8m/dart_mx8mp/tee-imx8mp-dart.bin ;;
        esac
        VARISCITE_TEE_IMAGE="${VARISCITE_TEE_IMAGE:-$tee_image}"
        if [ ! -f "$VARISCITE_TEE_IMAGE" ]; then
            echo "ERROR: Trusty image not found: $VARISCITE_TEE_IMAGE" >&2
            return 1
        fi
        set -- "$@" SPD=trusty
    esac

    make -C "$mkimage_dir" clean || return 1
    cp "${UBOOT_OUT}/u-boot-nodtb.${postfix}" "$image_dir/" || return 1
    cp "${UBOOT_OUT}/spl/u-boot-spl.bin" "$image_dir/" || return 1
    cp "${UBOOT_OUT}/tools/mkimage" "$image_dir/mkimage_uboot" || return 1
    cp "${FSL_PROPRIETARY_PATH}"/linux-firmware-imx/firmware/ddr/synopsys/lpddr4_pmu_train* "$image_dir/" || return 1

    # Keep DT names intact: Variscite SPL selects the FIT configuration by name.
    dtbs="imx8mp-var-dart-sonataboard.dtb imx8mp-var-som-symphony.dtb imx8mp-var-smarc-echo.dtb"
    copy_dtbs()
    {
        for dtb in $dtbs; do
            cp "${UBOOT_OUT}/arch/arm/dts/$dtb" "$image_dir/" || return 1
        done
    }
    copy_dtbs || return 1

    rm -f "$image_dir/tee.bin" "$image_dir/tee.bin.lz4"
    case "$variant" in *-trusty-*)
        cp "$VARISCITE_TEE_IMAGE" "$image_dir/tee.bin" || return 1
    esac
    make -C "$atf_dir" "$@" clean || return 1
    make -C "$atf_dir" "$@" bl31 -B || return 1
    cp "$atf_dir/build/imx8mp/release/bl31.bin" "$image_dir/bl31.bin" || return 1

    # Building u-boot.itb deletes the DTBs, so copy them again before
    # print_fit_hab, which prints the FIT offsets needed for HAB signing.
    set -- SOC=iMX8MP "dtbs=$dtbs"
    case "$variant" in *-dual)
        make -C "$mkimage_dir" "$@" flash_evk_no_hdmi_dual_bootloader || return 1
        cp "$image_dir/flash.bin" "${UBOOT_COLLECTION}/spl-${variant}.bin" || return 1
        cp "$image_dir/u-boot-ivt.itb" "${UBOOT_COLLECTION}/bootloader-${variant}.img" || return 1
        copy_dtbs || return 1
        make -C "$mkimage_dir" "$@" PRINT_FIT_HAB_OFFSET=0x0 print_fit_hab || return 1
        ;;
    *)
        make -C "$mkimage_dir" "$@" flash_evk || return 1
        cp "$image_dir/flash.bin" "${UBOOT_COLLECTION}/u-boot-${variant}.imx" || return 1
        copy_dtbs || return 1
        make -C "$mkimage_dir" "$@" print_fit_hab || return 1
        ;;
    esac
)
