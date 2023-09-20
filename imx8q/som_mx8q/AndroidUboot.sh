#!/bin/bash

# hardcode this one again in this shell script
CONFIG_REPO_PATH=device/variscite

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
done < ${CONFIG_REPO_PATH}/common/VarPathConfig.mk


if [ "${AARCH64_GCC_CROSS_COMPILE}" != "" ]; then
       ATF_CROSS_COMPILE=`eval echo ${AARCH64_GCC_CROSS_COMPILE}`
else
       echo ERROR: \*\*\* env AARCH64_GCC_CROSS_COMPILE is not set
       exit 1
fi

VARISCITE_PATH=vendor/variscite
MCU_SDK_IMX8QM_DEMO_PATH=${IMX_MCU_SDK_PATH}/mcu-sdk-auto/SDK_MEK-MIMX8QM/boards/mekmimx8qm/demo_apps/rear_view_camera/cm4_core1/armgcc
MCU_SDK_IMX8QM_CMAKE_FILE=../../../../../../tools/cmake_toolchain_files/armgcc.cmake
MCU_SDK_IMX8QX_DEMO_PATH=${IMX_MCU_SDK_PATH}/mcu-sdk-auto/SDK_MEK-MIMX8QX/boards/mekmimx8qx/demo_apps/rear_view_camera/armgcc
MCU_SDK_IMX8QX_CMAKE_FILE=../../../../../tools/cmake_toolchain_files/armgcc.cmake

if [ "${IMX8QM_A72_BOOT}" = "true" ]; then
       MCU_SDK_IMX8QM_EXTRA_CONFIG="-DCMAKE_BOOT_FROM_A72=ON"
else
       MCU_SDK_IMX8QM_EXTRA_CONFIG=
fi
MCU_SDK_IMX8QX_EXTRA_CONFIG=

UBOOT_M4_OUT=${TARGET_OUT_INTERMEDIATES}/MCU_OBJ
UBOOT_M4_BUILD_TYPE=ddr_release

build_m4_image_core()
{
       make -C ${UBOOT_M4_OUT}/$2 1>/dev/null
}

if [ "${PRODUCT_IMX_CAR_M4}" = "true" ]; then
       if [ "${ARMGCC_DIR}" = "" ]; then
               echo ERROR: \*\*\* please install arm-none-eabi-gcc toolchain and set the installed path to ARMGCC_DIR
               exit 1
       fi

       build_m4_image()
       {
               rm -rf ${UBOOT_M4_OUT}
               mkdir -p ${UBOOT_M4_OUT}
               cmake_version=$(/usr/local/bin/cmake --version | head -n 1 | tr " " "\n" | tail -n 1)
               req_version="3.13.0"
               if [ "`echo "$cmake_version $req_version" | tr " " "\n" | sort -V | head -n 1`" != "$req_version" ]; then
                       echo "please upgrade cmake version to ${req_version} or newer";
                       exit 1
               fi
               build_m4_image_core ${MCU_SDK_IMX8QM_DEMO_PATH} MIMX8QM ${UBOOT_M4_BUILD_TYPE} ${MCU_SDK_IMX8QM_CMAKE_FILE} ${MCU_SDK_IMX8QM_EXTRA_CONFIG}
               build_m4_image_core ${MCU_SDK_IMX8QX_DEMO_PATH} MIMX8QX ${UBOOT_M4_BUILD_TYPE} ${MCU_SDK_IMX8QX_CMAKE_FILE} ${MCU_SDK_IMX8QX_EXTRA_CONFIG}
       }
else
       build_m4_image()
       {
               echo "android build without building M4 image"
       }
fi

build_imx_uboot()
{
       if [ `echo $2 | cut -d '-' -f1` = "imx8qm" ] && [ `echo $2 | cut -d '-' -f2` != "xen" ]; then
               MKIMAGE_PLATFORM=iMX8QM
               SCFW_PLATFORM=8qm
               ATF_PLATFORM=imx8qm
               REV=B0

               if [ `echo $2 | rev | cut -d '-' -f1` = "uuu" ]; then
                       FLASH_TARGET=flash_spl
               else
                       FLASH_TARGET=flash_spl
               fi

               cp ${FSL_PROPRIETARY_PATH}/imx-seco/firmware/seco/mx8qm*ahab-container.img ${IMX_MKIMAGE_PATH}/imx-mkimage/$MKIMAGE_PLATFORM/
               cp ${FSL_PROPRIETARY_PATH}/fsl-proprietary/mcu-sdk/imx8q/imx8qm_m4_0_default.bin ${IMX_MKIMAGE_PATH}/imx-mkimage/$MKIMAGE_PLATFORM/m4_image.bin
               cp ${FSL_PROPRIETARY_PATH}/fsl-proprietary/mcu-sdk/imx8q/imx8qm_m4_1_default.bin ${IMX_MKIMAGE_PATH}/imx-mkimage/$MKIMAGE_PLATFORM/m4_1_image.bin
               cp ${FSL_PROPRIETARY_PATH}/linux-firmware-imx/firmware/hdmi/cadence/hdmitxfw.bin ${IMX_MKIMAGE_PATH}/imx-mkimage/$MKIMAGE_PLATFORM/hdmitxfw.bin
               cp ${FSL_PROPRIETARY_PATH}/linux-firmware-imx/firmware/hdmi/cadence/hdmirxfw.bin ${IMX_MKIMAGE_PATH}/imx-mkimage/$MKIMAGE_PLATFORM/hdmirxfw.bin

       elif [ `echo $2 | cut -d '-' -f1` = "imx8qxp" ]; then
               MKIMAGE_PLATFORM=iMX8QX
               SCFW_PLATFORM=8qx
               ATF_PLATFORM=imx8qx
               if [ `echo $2 | cut -d '-' -f2` = "c0" ] || [ "`echo $2 | cut -d '-' -f3`" = "c0" ]; then
                       REV=C0
               else
                       REV=B0
               fi
               if [ `echo $2 | rev | cut -d '-' -f1` = "uuu" ]; then
                       FLASH_TARGET=flash_spl
               else
                       FLASH_TARGET=flash_spl
               fi
               cp ${FSL_PROPRIETARY_PATH}/imx-seco/firmware/seco/mx8qx*ahab-container.img ${IMX_MKIMAGE_PATH}/imx-mkimage/$MKIMAGE_PLATFORM/
               cp ${FSL_PROPRIETARY_PATH}/fsl-proprietary/mcu-sdk/imx8q/imx8qx_m4_default.bin ${IMX_MKIMAGE_PATH}/imx-mkimage/$MKIMAGE_PLATFORM/m4_image.bin
       fi
       cp  device/variscite/imx8q/som_mx8q/uboot-firmware/mx$SCFW_PLATFORM-var-som-scfw-tcm.bin ${IMX_MKIMAGE_PATH}/imx-mkimage/$MKIMAGE_PLATFORM/scfw_tcm.bin
       if [ -f ${IMX_MKIMAGE_PATH}/imx-mkimage/$MKIMAGE_PLATFORM/tee.bin ]; then
                       rm -f ${IMX_MKIMAGE_PATH}/imx-mkimage/$MKIMAGE_PLATFORM/tee.bin
       fi
       if [ "$2" != "imx8qm-xen" ]; then
               make -C ${IMX_PATH}/arm-trusted-firmware/ PLAT=$ATF_PLATFORM clean
               if [ "${PRODUCT_IMX_CAR}" = "true" -a `echo $2 | rev | cut -d '-' -f1` != "uuu" -o `echo $2 | cut -d '-' -f2` = "trusty" ]; then
                       make -C ${IMX_PATH}/arm-trusted-firmware/ CROSS_COMPILE="${ATF_CROSS_COMPILE}" PLAT=$ATF_PLATFORM bl31 SPD=trusty -B 1>/dev/null || exit 1
               else
                       make -C ${IMX_PATH}/arm-trusted-firmware/ CROSS_COMPILE="${ATF_CROSS_COMPILE}" PLAT=$ATF_PLATFORM bl31 -B 1>/dev/null || exit 1
               fi
               cp ${IMX_PATH}/arm-trusted-firmware/build/$ATF_PLATFORM/release/bl31.bin ${IMX_MKIMAGE_PATH}/imx-mkimage/$MKIMAGE_PLATFORM/bl31.bin
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
       else
               cp ${UBOOT_OUT}/u-boot.$1 ${IMX_MKIMAGE_PATH}/imx-mkimage/$MKIMAGE_PLATFORM/u-boot.bin
               cp ${UBOOT_OUT}/spl/u-boot-spl.bin ${UBOOT_COLLECTION}/spl-$2.bin
               cp ${UBOOT_OUT}/tools/mkimage  ${IMX_MKIMAGE_PATH}/imx-mkimage/$MKIMAGE_PLATFORM/mkimage_uboot

               make -C ${IMX_MKIMAGE_PATH}/imx-mkimage/ clean
               pwd_backup=${PWD}
               PWD=${PWD}/${IMX_MKIMAGE_PATH}/imx-mkimage/
               make -C ${IMX_MKIMAGE_PATH}/imx-mkimage/ SOC=$MKIMAGE_PLATFORM REV=$REV $FLASH_TARGET || exit 1
               PWD=${pwd_backup}
               cp ${IMX_MKIMAGE_PATH}/imx-mkimage/$MKIMAGE_PLATFORM/u-boot-xen-container.img ${UBOOT_COLLECTION}/bootloader-$2.img
       fi
}
