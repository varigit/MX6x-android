#!/bin/bash
set -e

#### Exports Variables ####
#### global variables ####
readonly ABSOLUTE_FILENAME=`readlink -e "$0"`
readonly ABSOLUTE_DIRECTORY=`dirname ${ABSOLUTE_FILENAME}`

ANDROID_SCRIPTS_PATH=${ABSOLUTE_DIRECTORY}/variscite_scripts
ANDROID_BUILD_ROOT=`pwd`
YOCTO_IMAGE_FILE_COMP=`readlink -e "$1"`
YOCTO_IMAGE_FILE=${YOCTO_IMAGE_FILE_COMP%.*}
YOCTO_IMAGE_DIRECTORY=`dirname ${YOCTO_IMAGE_FILE}`
NEW_YOCTO_IMAGE_FILE=${YOCTO_IMAGE_DIRECTORY}/$2.wic

TEMP_DIR=./var_tmp
ROOTFS_MOUNT_DIR=${TEMP_DIR}/rootfs

help() {
	bn=`basename $0`
	echo " Usage: MACHINE=<imx8mq-var-dart|imx8mm-var-dart|imx8qxp-var-som|imx8qxpb0-var-som|imx8qm-var-som|imx8mn-var-som|imx8mp-var-dart> $bn yocto_image.wic.zst [new_image_name]"
	echo
}

case $MACHINE in
	"imx8mq-var-dart")
		ANDROID_IMGS_PATH=${ANDROID_BUILD_ROOT}/out/target/product/dart_mx8mq
		;;
	"imx8mp-var-dart")
		ANDROID_IMGS_PATH=${ANDROID_BUILD_ROOT}/out/target/product/dart_mx8mp
		;;
	"imx8mm-var-dart")
		ANDROID_IMGS_PATH=${ANDROID_BUILD_ROOT}/out/target/product/dart_mx8mm
		;;
	"imx8qxp-var-som" | "imx8qxpb0-var-som")
		ANDROID_IMGS_PATH=${ANDROID_BUILD_ROOT}/out/target/product/som_mx8q
		;;
	"imx8qm-var-som")
		ANDROID_IMGS_PATH=${ANDROID_BUILD_ROOT}/out/target/product/som_mx8q
		;;
	"imx8mn-var-som")
		ANDROID_IMGS_PATH=${ANDROID_BUILD_ROOT}/out/target/product/som_mx8mn
		;;
	*)
		help
		exit 1
esac

echo "========================================================"
echo "= Variscite recovery SD card creation script - Android ="
echo "========================================================"

function uncompress_image
{
	zstd -d -f ${YOCTO_IMAGE_FILE_COMP}
}

function compress_image
{
	zstd --rm -f ${YOCTO_IMAGE_FILE}
}

function create_loop
{
	losetup -Pf ${YOCTO_IMAGE_FILE}
	node=`losetup -a |grep ${YOCTO_IMAGE_FILE} |cut -d : -f 1`
	part="p"
}

function destroy_loop
{
	losetup -d ${node}
	# rename file once disconnected from loop
	if [ -n $2 ] ; then
		mv ${YOCTO_IMAGE_FILE} ${NEW_YOCTO_IMAGE_FILE}
		YOCTO_IMAGE_FILE=${NEW_YOCTO_IMAGE_FILE}
	fi
}

function mount_parts
{
	mkdir -p ${ROOTFS_MOUNT_DIR}
	sync
	mount ${node}${part}1  ${ROOTFS_MOUNT_DIR}
}

function unmount_parts
{
	umount ${ROOTFS_MOUNT_DIR}
	rm -rf ${TEMP_DIR}
}

function copy_android
{
	echo
	echo "Copying Android images to /opt/images/"
	mkdir -p ${ROOTFS_MOUNT_DIR}/opt/images/Android
	rm -rf ${ROOTFS_MOUNT_DIR}/opt/images/Android/*

	cp ${ANDROID_IMGS_PATH}/spl-${MACHINE}-dual.bin	        ${ROOTFS_MOUNT_DIR}/opt/images/Android/
	cp ${ANDROID_IMGS_PATH}/bootloader-${MACHINE}-dual.img  ${ROOTFS_MOUNT_DIR}/opt/images/Android/
	cp ${ANDROID_IMGS_PATH}/boot.img			${ROOTFS_MOUNT_DIR}/opt/images/Android/
	cp ${ANDROID_IMGS_PATH}/init_boot.img                   ${ROOTFS_MOUNT_DIR}/opt/images/Android/
	cp ${ANDROID_IMGS_PATH}/dtbo-*.img			${ROOTFS_MOUNT_DIR}/opt/images/Android/
	cp ${ANDROID_IMGS_PATH}/vbmeta-*.img			${ROOTFS_MOUNT_DIR}/opt/images/Android/

	if [[ "${MACHINE}" = "imx8qm-var-som" ]]; then
		echo "Copying firmware images to /opt/images/"
		cp ${ANDROID_IMGS_PATH}/vendor/firmware/hdmitxfw.bin	${ROOTFS_MOUNT_DIR}/opt/images/Android/
		cp ${ANDROID_IMGS_PATH}/vendor/firmware/dpfw.bin	${ROOTFS_MOUNT_DIR}/opt/images/Android/
	fi

	if [ -e "${ANDROID_IMGS_PATH}/super.img" ]; then
		echo "Copying super image to /opt/images/"
		pv ${ANDROID_IMGS_PATH}/super.img >		${ROOTFS_MOUNT_DIR}/opt/images/Android/super.img
		sync | pv -t
	else
		echo "Copying system image to /opt/images/"
		pv ${ANDROID_IMGS_PATH}/system.img >		${ROOTFS_MOUNT_DIR}/opt/images/Android/system.img
		sync | pv -t
		echo "Copying vendor image to /opt/images/"
		pv ${ANDROID_IMGS_PATH}/vendor.img >		${ROOTFS_MOUNT_DIR}/opt/images/Android/vendor.img
		sync | pv -t
		echo "Copying product image to /opt/images/"
		pv ${ANDROID_IMGS_PATH}/product.img >		${ROOTFS_MOUNT_DIR}/opt/images/Android/product.img
		sync | pv -t
	fi
	if [ -e "${ANDROID_IMGS_PATH}/vendor_boot.img" ]; then
                echo "Copying vendor_boot image to /opt/images/"
                pv ${ANDROID_IMGS_PATH}/vendor_boot.img >       ${ROOTFS_MOUNT_DIR}/opt/images/Android/vendor_boot.img
                sync | pv -t
	fi

	if [[ "${MACHINE}" = "imx8mm-var-dart" ]]; then
		echo "Copying M4 demo images to /opt/images/"
		pv ${ANDROID_BUILD_ROOT}/device/variscite/imx8m/dart_mx8mm/cm_hello_world.bin.debug > \
				${ROOTFS_MOUNT_DIR}/opt/images/Android/cm_hello_world.bin
		pv ${ANDROID_BUILD_ROOT}/device/variscite/imx8m/dart_mx8mm/cm_rpmsg_lite_pingpong_rtos_linux_remote.bin.debug > \
				${ROOTFS_MOUNT_DIR}/opt/images/Android/cm_rpmsg_lite_pingpong_rtos_linux_remote.bin
		pv ${ANDROID_BUILD_ROOT}/device/variscite/imx8m/dart_mx8mm/cm_rpmsg_lite_str_echo_rtos_imxcm4.bin.debug > \
				${ROOTFS_MOUNT_DIR}/opt/images/Android/cm_rpmsg_lite_str_echo_rtos_imxcm4.bin
		sync | pv -t
	elif [[ "${MACHINE}" = "imx8mn-var-som" ]]; then
		echo "Copying M7 demo images to /opt/images/"
		pv ${ANDROID_BUILD_ROOT}/device/variscite/imx8m/som_mx8mn/cm_hello_world.bin.debug > \
				${ROOTFS_MOUNT_DIR}/opt/images/Android/cm_hello_world.bin
		pv ${ANDROID_BUILD_ROOT}/device/variscite/imx8m/som_mx8mn/cm_rpmsg_lite_pingpong_rtos_linux_remote.bin.debug > \
				${ROOTFS_MOUNT_DIR}/opt/images/Android/cm_rpmsg_lite_pingpong_rtos_linux_remote.bin
		pv ${ANDROID_BUILD_ROOT}/device/variscite/imx8m/som_mx8mn/cm_rpmsg_lite_str_echo_rtos.bin.debug > \
				${ROOTFS_MOUNT_DIR}/opt/images/Android/cm_rpmsg_lite_str_echo_rtos.bin
		sync | pv -t
	elif [[ "${MACHINE}" = "imx8mp-var-dart" ]]; then
		echo "Copying M7 demo images to /opt/images/"
		pv ${ANDROID_BUILD_ROOT}/device/variscite/imx8m/dart_mx8mp/cm_hello_world.bin.debug_dart > \
				${ROOTFS_MOUNT_DIR}/opt/images/Android/cm_hello_world.bin.debug_dart
		pv ${ANDROID_BUILD_ROOT}/device/variscite/imx8m/dart_mx8mp/cm_hello_world.bin.debug_som > \
				${ROOTFS_MOUNT_DIR}/opt/images/Android/cm_hello_world.bin.debug_som
		pv ${ANDROID_BUILD_ROOT}/device/variscite/imx8m/dart_mx8mp/cm_rpmsg_lite_pingpong_rtos_linux_remote.bin.debug_dart > \
				${ROOTFS_MOUNT_DIR}/opt/images/Android/cm_rpmsg_lite_pingpong_rtos_linux_remote.bin.debug_dart
		pv ${ANDROID_BUILD_ROOT}/device/variscite/imx8m/dart_mx8mp/cm_rpmsg_lite_pingpong_rtos_linux_remote.bin.debug_som > \
				${ROOTFS_MOUNT_DIR}/opt/images/Android/cm_rpmsg_lite_pingpong_rtos_linux_remote.bin.debug_som
		pv ${ANDROID_BUILD_ROOT}/device/variscite/imx8m/dart_mx8mp/cm_rpmsg_lite_str_echo_rtos.bin.debug_dart > \
				${ROOTFS_MOUNT_DIR}/opt/images/Android/cm_rpmsg_lite_str_echo_rtos.bin.debug_dart
		pv ${ANDROID_BUILD_ROOT}/device/variscite/imx8m/dart_mx8mp/cm_rpmsg_lite_str_echo_rtos.bin.debug_som > \
				${ROOTFS_MOUNT_DIR}/opt/images/Android/cm_rpmsg_lite_str_echo_rtos.bin.debug_som
		sync | pv -t
	fi

}

function copy_android_scripts
{
	echo
	echo "Copying Android script"
	cp ${ANDROID_SCRIPTS_PATH}/mx8_install_android.sh		${ROOTFS_MOUNT_DIR}/usr/bin/install_android.sh
}

uncompress_image
create_loop
mount_parts
copy_android
copy_android_scripts

echo
echo "Syncing"
sync | pv -t

unmount_parts
destroy_loop
compress_image

echo
echo "Done"

exit 0
