#!/bin/bash

# hardcode this one again in this shell script
CONFIG_REPO_PATH=device/nxp

# import other paths in the file "common/imx_path/ImxPathConfig.mk" of this
# repository

while read -r line
do
	if [ "$(echo ${line} | grep "=")" != "" ]; then
		env_arg=`echo ${line} | cut -d "=" -f1`
		env_arg=${env_arg%:}
		env_arg=`eval echo ${env_arg}`

		env_arg_value=`echo ${line} | cut -d "=" -f2`
		env_arg_value=`eval echo ${env_arg_value}`

		eval ${env_arg}=${env_arg_value}
	fi
done < ${CONFIG_REPO_PATH}/common/imx_path/ImxPathConfig.mk

if [ "${AARCH64_GCC_CROSS_COMPILE}" != "" ]; then
	ATF_CROSS_COMPILE=`eval echo ${AARCH64_GCC_CROSS_COMPILE}`
else
	echo ERROR: \*\*\* env AARCH64_GCC_CROSS_COMPILE is not set
	exit 1
fi


MCU_SDK_IMX8MP_DEMO_PATH=${IMX_MCU_SDK_PATH}/mcu-sdk/imx8mp/boards/evkmimx8mp/demo_apps/sai_low_power_audio_low_ddr/armgcc
MCU_SDK_IMX8MP_CMAKE_FILE=../../../../../tools/cmake_toolchain_files/armgcc.cmake

UBOOT_MCU_OUT=${TARGET_OUT_INTERMEDIATES}/MCU_OBJ
UBOOT_MCU_BUILD_TYPE=release

build_mcu_image_core()
{
	mkdir -p ${UBOOT_MCU_OUT}/$2
	/usr/local/bin/cmake -DCMAKE_TOOLCHAIN_FILE="$4" -G "Unix Makefiles" -DCMAKE_BUILD_TYPE=$3 -S $1 -B ${UBOOT_MCU_OUT}/$2 1>/dev/null
	make -C ${UBOOT_MCU_OUT}/$2 1>/dev/null
}

# POWERSAVE is set in the command line which triggers the build process
if [ "${POWERSAVE}" = "true" ]; then
	POWERSAVE_STATE=ENABLE

	if [ "${ARMGCC_DIR}" = "" ]; then
		echo ERROR: \*\*\* please install arm-none-eabi-gcc toolchain and set the installed path to ARMGCC_DIR
		exit 1
	fi

	build_pre_image()
	{
		rm -rf ${UBOOT_MCU_OUT}
		mkdir -p ${UBOOT_MCU_OUT}

		cmake_version=$(/usr/local/bin/cmake --version | head -n 1 | tr " " "\n" | tail -n 1)
		req_version="3.13.0"
		if [ "`echo "$cmake_version $req_version" | tr " " "\n" | sort -V | head -n 1`" != "$req_version" ]; then
			echo ERROR: \*\*\* please upgrade cmake version to $req_version or newer
			exit 1
		fi

		build_mcu_image_core ${MCU_SDK_IMX8MP_DEMO_PATH} MIMX8MP ${UBOOT_MCU_BUILD_TYPE} ${MCU_SDK_IMX8MP_CMAKE_FILE}
		cp ${MCU_SDK_IMX8MP_DEMO_PATH}/${UBOOT_MCU_BUILD_TYPE}/*.bin ${PRODUCT_OUT}/imx8mp_mcu_demo.bin
	}
else
	build_pre_image()
	{
		echo "android build without building MCU image"
	}
fi

build_imx_uboot()
{
	echo Building i.MX U-Boot with firmware
	cp ${UBOOT_OUT}/u-boot-nodtb.$1 ${IMX_MKIMAGE_PATH}/imx-mkimage/iMX8M/
	cp ${UBOOT_OUT}/spl/u-boot-spl.bin  ${IMX_MKIMAGE_PATH}/imx-mkimage/iMX8M/
	cp ${UBOOT_OUT}/tools/mkimage  ${IMX_MKIMAGE_PATH}/imx-mkimage/iMX8M/mkimage_uboot
	if echo "$2" | grep -q "frdm" ; then
		cp ${UBOOT_OUT}/arch/arm/dts/imx8mp-frdm.dtb ${IMX_MKIMAGE_PATH}/imx-mkimage/iMX8M/imx8mp-evk.dtb
	else
		cp ${UBOOT_OUT}/dts/upstream/src/arm64/freescale/imx8mp-evk.dtb ${IMX_MKIMAGE_PATH}/imx-mkimage/iMX8M/
	fi
	cp ${FSL_PROPRIETARY_PATH}/linux-firmware-imx/firmware/ddr/synopsys/lpddr4_pmu_train* ${IMX_MKIMAGE_PATH}/imx-mkimage/iMX8M/

	# build ATF based on whether tee is involved
	make -C ${IMX_PATH}/arm-trusted-firmware/ CROSS_COMPILE="${ATF_CROSS_COMPILE}" PLAT=`echo $2 | cut -d '-' -f1` clean
	if [ "`echo $2 | cut -d '-' -f2`" = "trusty" ]; then
		cp ${FSL_PROPRIETARY_PATH}/fsl-proprietary/uboot-firmware/imx8m/tee-imx8mp.bin ${IMX_MKIMAGE_PATH}/imx-mkimage/iMX8M/tee.bin
		if echo "$2" | grep -q "frdm" ; then
			make -C ${IMX_PATH}/arm-trusted-firmware/ CROSS_COMPILE="${ATF_CROSS_COMPILE}" PLAT=`echo $2 | cut -d '-' -f1` bl31 -B DDR_SIZE=0x100000000 SPD=trusty LPA=${POWERSAVE_STATE} IMX_ANDROID_BUILD=true 1>/dev/null || exit 1
		else
			make -C ${IMX_PATH}/arm-trusted-firmware/ CROSS_COMPILE="${ATF_CROSS_COMPILE}" PLAT=`echo $2 | cut -d '-' -f1` bl31 -B SPD=trusty LPA=${POWERSAVE_STATE} IMX_ANDROID_BUILD=true 1>/dev/null || exit 1
		fi
	else
		if [ -f ${IMX_MKIMAGE_PATH}/imx-mkimage/iMX8M/tee.bin ] ; then
			rm -rf ${IMX_MKIMAGE_PATH}/imx-mkimage/iMX8M/tee.bin
		fi
		if [ -f ${IMX_MKIMAGE_PATH}/imx-mkimage/iMX8M/tee.bin.lz4 ] ; then
			rm -rf ${IMX_MKIMAGE_PATH}/imx-mkimage/iMX8M/tee.bin.lz4
		fi
		make -C ${IMX_PATH}/arm-trusted-firmware/ CROSS_COMPILE="${ATF_CROSS_COMPILE}" PLAT=`echo $2 | cut -d '-' -f1` bl31 -B LPA=${POWERSAVE_STATE} IMX_ANDROID_BUILD=true 1>/dev/null || exit 1
	fi
	cp ${IMX_PATH}/arm-trusted-firmware/build/`echo $2 | cut -d '-' -f1`/release/bl31.bin ${IMX_MKIMAGE_PATH}/imx-mkimage/iMX8M/bl31.bin

	make -C ${IMX_MKIMAGE_PATH}/imx-mkimage/ clean
	if [ `echo $2 | rev | cut -d '-' -f1 | rev` = "dual" ]; then
		make -C ${IMX_MKIMAGE_PATH}/imx-mkimage/ SOC=iMX8MP flash_evk_no_hdmi_dual_bootloader || exit 1
		make -C ${IMX_MKIMAGE_PATH}/imx-mkimage/ SOC=iMX8MP PRINT_FIT_HAB_OFFSET=0x0 print_fit_hab || exit 1
		cp ${IMX_MKIMAGE_PATH}/imx-mkimage/iMX8M/flash.bin ${UBOOT_COLLECTION}/spl-$2.bin
		cp ${IMX_MKIMAGE_PATH}/imx-mkimage/iMX8M/u-boot-ivt.itb ${UBOOT_COLLECTION}/bootloader-$2.img
	else
		make -C ${IMX_MKIMAGE_PATH}/imx-mkimage/ SOC=iMX8MP flash_evk || exit 1
		make -C ${IMX_MKIMAGE_PATH}/imx-mkimage/ SOC=iMX8MP print_fit_hab || exit 1
		cp ${IMX_MKIMAGE_PATH}/imx-mkimage/iMX8M/flash.bin ${UBOOT_COLLECTION}/u-boot-$2.imx
	fi
}

