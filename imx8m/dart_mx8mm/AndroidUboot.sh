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
{
	postfix=$1 variant=$2
	mkimage_dir="${IMX_MKIMAGE_PATH}/imx-mkimage"
	image_dir="${mkimage_dir}/iMX8M"
	atf_dir="${VARISCITE_PATH}/arm-trusted-firmware"
	atf_cross="${AARCH64_GCC_CROSS_COMPILE:?AARCH64_GCC_CROSS_COMPILE is required}"
	set -- CROSS_COMPILE="$atf_cross" CC="${atf_cross}gcc" AS="${atf_cross}gcc" PLAT=imx8mm IMX_ANDROID_BUILD=true

	# As in Android 15, Trusty is NXP's i.MX8MM Trusty from the same release
	# (matching its KeyMint/Gatekeeper/Secretkeeper HALs), rebuilt with the
	# board console UART: UART1 on DART, UART4 on VAR-SOM (*-var-som-*
	# variants). The NXP image prints on UART2 and hangs. Set
	# VARISCITE_TEE_IMAGE to use another Trusty build.
	case "$variant" in *-trusty-*)
		case "$variant" in
		*-var-som-*) tee_image=tee-imx8mm-som.bin ;;
		*) tee_image=tee-imx8mm-dart.bin ;;
		esac
		# Not assigned back to VARISCITE_TEE_IMAGE: uboot.mk builds every
		# variant in one shell, so that would reuse the first board's image
		tee_path="${VARISCITE_TEE_IMAGE:-device/variscite/imx8m/dart_mx8mm/$tee_image}"
		if [ ! -f "$tee_path" ]; then
			echo "ERROR: Trusty image not found: $tee_path" >&2
			return 1
		fi
		set -- "$@" SPD=trusty
		# As in NXP's 4G EVK build, 4 GB boards place Trusty at the top of
		# the 4 GB DRAM; the ATF default (0xbe000000) is the top of 2 GB
		case "$variant" in *-4g-*)
			tee_load_addr=0xfe000000
			set -- "$@" BL32_BASE=$tee_load_addr DDR_SIZE=0x100000000
			;;
		*)
			tee_load_addr=0xbe000000
			;;
		esac
	esac

	make -C "$mkimage_dir" clean || return 1
	cp "${UBOOT_OUT}/u-boot-nodtb.${postfix}" "$image_dir/" || return 1
	cp "${UBOOT_OUT}/spl/u-boot-spl.bin" "$image_dir/" || return 1
	cp "${UBOOT_OUT}/tools/mkimage" "$image_dir/mkimage_uboot" || return 1
	cp "${FSL_PROPRIETARY_PATH}"/linux-firmware-imx/firmware/ddr/synopsys/lpddr4_pmu_train* "$image_dir/" || return 1
	cp "${FSL_PROPRIETARY_PATH}"/linux-firmware-imx/firmware/ddr/synopsys/ddr4* "$image_dir/" || return 1

	# Keep DT names intact: Variscite SPL selects the FIT configuration by name.
	dtbs="imx8mm-var-dart-sonataboard.dtb imx8mm-var-som-symphony.dtb"
	copy_dtbs()
	{
		for dtb in $dtbs; do
			cp "${UBOOT_OUT}/arch/arm/dts/$dtb" "$image_dir/" || return 1
		done
	}
	copy_dtbs || return 1

	rm -f "$image_dir/tee.bin" "$image_dir/tee.bin.lz4"
	case "$variant" in *-trusty-*)
		cp "$tee_path" "$image_dir/tee.bin" || return 1
	esac
	make -C "$atf_dir" "$@" clean || return 1
	make -C "$atf_dir" "$@" bl31 -B || return 1
	cp "$atf_dir/build/imx8mm/release/bl31.bin" "$image_dir/bl31.bin" || return 1

	# Building u-boot.itb deletes the DTBs, so copy them again before
	# print_fit_hab, which prints the FIT offsets needed for HAB signing.
	set -- SOC=iMX8MM "dtbs=$dtbs"
	# Trusty runs at the ATF BL32_BASE, not at the imx-mkimage default
	case "$variant" in *-trusty-*)
		set -- "$@" TEE_LOAD_ADDR=$tee_load_addr
	esac
	case "$variant" in *-dual)
		make -C "$mkimage_dir" "$@" flash_lpddr4_ddr4_evk_no_hdmi_dual_bootloader || return 1
		cp "$image_dir/flash.bin" "${UBOOT_COLLECTION}/spl-${variant}.bin" || return 1
		cp "$image_dir/u-boot-ivt.itb" "${UBOOT_COLLECTION}/bootloader-${variant}.img" || return 1
		copy_dtbs || return 1
		make -C "$mkimage_dir" "$@" PRINT_FIT_HAB_OFFSET=0x0 print_fit_hab_lpddr_ddr4 || return 1
		;;
	*)
		make -C "$mkimage_dir" "$@" flash_lpddr4_ddr4_evk || return 1
		cp "$image_dir/flash.bin" "${UBOOT_COLLECTION}/u-boot-${variant}.imx" || return 1
		copy_dtbs || return 1
		make -C "$mkimage_dir" "$@" print_fit_hab_lpddr_ddr4 || return 1
		;;
	esac
}
