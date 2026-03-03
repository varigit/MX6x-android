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

VARISCITE_PATH=vendor/variscite

build_pre_image()
{
	:
}

build_imx_uboot()
{
	echo Building i.MX U-Boot with firmware for $2

	if [ `echo $2 | cut -d '-' -f1` = "imx8qm" ]; then
		MKIMAGE_PLATFORM=iMX8QM
		SCFW_PLATFORM=8qm
		ATF_PLATFORM=imx8qm
		REV=B0
		FLASH_TARGET=flash_spl
		cp ${FSL_PROPRIETARY_PATH}/imx-seco/firmware/seco/mx8qm*ahab-container.img ${IMX_MKIMAGE_PATH}/imx-mkimage/$MKIMAGE_PLATFORM/
		cp ${FSL_PROPRIETARY_PATH}/fsl-proprietary/mcu-sdk/imx8q/imx8qm_m4_0_default.bin ${IMX_MKIMAGE_PATH}/imx-mkimage/$MKIMAGE_PLATFORM/m4_image.bin
		cp ${FSL_PROPRIETARY_PATH}/fsl-proprietary/mcu-sdk/imx8q/imx8qm_m4_1_default.bin ${IMX_MKIMAGE_PATH}/imx-mkimage/$MKIMAGE_PLATFORM/m4_1_image.bin
		cp ${FSL_PROPRIETARY_PATH}/linux-firmware-imx/firmware/hdmi/cadence/hdmitxfw.bin ${IMX_MKIMAGE_PATH}/imx-mkimage/$MKIMAGE_PLATFORM/hdmitxfw.bin
		cp ${FSL_PROPRIETARY_PATH}/linux-firmware-imx/firmware/hdmi/cadence/hdmirxfw.bin ${IMX_MKIMAGE_PATH}/imx-mkimage/$MKIMAGE_PLATFORM/hdmirxfw.bin
	elif [ `echo $2 | cut -d '-' -f1` = "imx8qxp" ]; then
		MKIMAGE_PLATFORM=iMX8QX
		SCFW_PLATFORM=8qx
		ATF_PLATFORM=imx8qx
		if [ `echo $2 | cut -d '-' -f2` = "b0" ] || [ "`echo $2 | cut -d '-' -f3`" = "b0" ]; then
			REV=B0
		else
			REV=C0
		fi
		if [ `echo $2 | rev | cut -d '-' -f1` = "uuu" ]; then
			FLASH_TARGET=flash_spl
		else
			FLASH_TARGET=flash_spl
		fi
		cp ${FSL_PROPRIETARY_PATH}/imx-seco/firmware/seco/mx8qx*ahab-container.img ${IMX_MKIMAGE_PATH}/imx-mkimage/$MKIMAGE_PLATFORM/
		cp ${FSL_PROPRIETARY_PATH}/fsl-proprietary/mcu-sdk/imx8q/imx8qx_m4_default.bin ${IMX_MKIMAGE_PATH}/imx-mkimage/$MKIMAGE_PLATFORM/m4_image.bin
	else
		echo ERROR: unsupported SoC: $2
		exit 1
	fi

	cp  device/variscite/imx8q/som_mx8q/uboot-firmware/mx$SCFW_PLATFORM-var-som-scfw-tcm.bin ${IMX_MKIMAGE_PATH}/imx-mkimage/$MKIMAGE_PLATFORM/scfw_tcm.bin

	if [ -f ${IMX_MKIMAGE_PATH}/imx-mkimage/$MKIMAGE_PLATFORM/tee.bin ]; then
		rm -f ${IMX_MKIMAGE_PATH}/imx-mkimage/$MKIMAGE_PLATFORM/tee.bin
	fi

	make -C ${VARISCITE_PATH}/arm-trusted-firmware/ PLAT=$ATF_PLATFORM clean
	if [ "`echo $2 | cut -d '-' -f2`" = "trusty" ] && [ "`echo $2 | rev | cut -d '-' -f1`" != "uuu" ]; then
		make -C ${VARISCITE_PATH}/arm-trusted-firmware/ CROSS_COMPILE="${ATF_CROSS_COMPILE}" PLAT=$ATF_PLATFORM bl31 -B SPD=trusty IMX_ANDROID_BUILD=true 1>/dev/null || exit 1
	else
		make -C ${VARISCITE_PATH}/arm-trusted-firmware/ CROSS_COMPILE="${ATF_CROSS_COMPILE}" PLAT=$ATF_PLATFORM bl31 -B IMX_ANDROID_BUILD=true 1>/dev/null || exit 1
	fi
	cp ${VARISCITE_PATH}/arm-trusted-firmware/build/$ATF_PLATFORM/release/bl31.bin ${IMX_MKIMAGE_PATH}/imx-mkimage/$MKIMAGE_PLATFORM/bl31.bin

	cp  ${UBOOT_OUT}/u-boot.$1 ${IMX_MKIMAGE_PATH}/imx-mkimage/$MKIMAGE_PLATFORM/u-boot.bin
	if [ `echo $2 | rev | cut -d '-' -f1` != "uuu" ]; then
		cp  ${UBOOT_OUT}/spl/u-boot-spl.bin ${IMX_MKIMAGE_PATH}/imx-mkimage/$MKIMAGE_PLATFORM/u-boot-spl.bin
	fi
	cp  ${UBOOT_OUT}/tools/mkimage  ${IMX_MKIMAGE_PATH}/imx-mkimage/$MKIMAGE_PLATFORM/mkimage_uboot

	make -C ${IMX_MKIMAGE_PATH}/imx-mkimage/ clean
	# in imx-mkimage/Makefile, MKIMG is assigned with a value of "$(PWD)/mkimage_imx8", the value of PWD is set by shell to current
	# directory. Directly execute "make -C ${IMX_MKIMAGE_PATH}/imx-mkimage/ ..." command in this script, PWD is the top dir of Android
	# codebase, so mkimage_imx8 will be generated under Android codebase top dir.
	pwd_backup=${PWD}
	PWD=${PWD}/${IMX_MKIMAGE_PATH}/imx-mkimage/
	make -C ${IMX_MKIMAGE_PATH}/imx-mkimage/ SOC=$MKIMAGE_PLATFORM REV=$REV $FLASH_TARGET || exit 1
	PWD=${pwd_backup}

	if [ "${PRODUCT_IMX_DUAL_BOOTLOADER}" = "true" ] && [ `echo $2 | rev | cut -d '-' -f1` != "uuu" ] || [ `echo $2 | rev | cut -d '-' -f1 | rev` = "dual" ]; then
		cp ${IMX_MKIMAGE_PATH}/imx-mkimage/$MKIMAGE_PLATFORM/boot-spl-container.img ${UBOOT_COLLECTION}/spl-$2.bin
		cp ${IMX_MKIMAGE_PATH}/imx-mkimage/$MKIMAGE_PLATFORM/u-boot-atf-container.img ${UBOOT_COLLECTION}/bootloader-$2.img
	else
		cp ${IMX_MKIMAGE_PATH}/imx-mkimage/$MKIMAGE_PLATFORM/flash.bin ${UBOOT_COLLECTION}/u-boot-$2.imx
	fi
}
