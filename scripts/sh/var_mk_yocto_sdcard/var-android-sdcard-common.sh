#!/bin/bash
set -e

#### code common to Android sdcard scripts ####

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
	"imx95-var-dart")
		ANDROID_IMGS_PATH=${ANDROID_BUILD_ROOT}/out/target/product/dart_mx95
		;;
	*)
		help
		exit 1
esac

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

function do_copy_android
{
	cp ${ANDROID_IMGS_PATH}/spl-${MACHINE}-dual.bin	        ${ROOTFS_ANDROID_PATH}/
	cp ${ANDROID_IMGS_PATH}/bootloader-${MACHINE}-dual.img  ${ROOTFS_ANDROID_PATH}/
	cp ${ANDROID_IMGS_PATH}/boot.img			${ROOTFS_ANDROID_PATH}/
	cp ${ANDROID_IMGS_PATH}/init_boot.img                   ${ROOTFS_ANDROID_PATH}/
	cp ${ANDROID_IMGS_PATH}/dtbo-*.img			${ROOTFS_ANDROID_PATH}/
	cp ${ANDROID_IMGS_PATH}/vbmeta-*.img			${ROOTFS_ANDROID_PATH}/

	if [[ "${MACHINE}" = "imx8qm-var-som" ]]; then
		echo "Copying firmware images to /opt/images/"
		cp ${ANDROID_IMGS_PATH}/vendor/firmware/hdmitxfw.bin	${ROOTFS_ANDROID_PATH}/
		cp ${ANDROID_IMGS_PATH}/vendor/firmware/dpfw.bin	${ROOTFS_ANDROID_PATH}/
	fi

	if [ -e "${ANDROID_IMGS_PATH}/super.img" ]; then
		echo "Copying super image to /opt/images/"
		pv ${ANDROID_IMGS_PATH}/super.img >		${ROOTFS_ANDROID_PATH}/super.img
		sync | pv -t
	else
		echo "Copying system image to /opt/images/"
		pv ${ANDROID_IMGS_PATH}/system.img >		${ROOTFS_ANDROID_PATH}/system.img
		sync | pv -t
		echo "Copying vendor image to /opt/images/"
		pv ${ANDROID_IMGS_PATH}/vendor.img >		${ROOTFS_ANDROID_PATH}/vendor.img
		sync | pv -t
		echo "Copying product image to /opt/images/"
		pv ${ANDROID_IMGS_PATH}/product.img >		${ROOTFS_ANDROID_PATH}/product.img
		sync | pv -t
	fi
	if [ -e "${ANDROID_IMGS_PATH}/vendor_boot.img" ]; then
                echo "Copying vendor_boot image to /opt/images/"
                pv ${ANDROID_IMGS_PATH}/vendor_boot.img >       ${ROOTFS_ANDROID_PATH}/vendor_boot.img
                sync | pv -t
	fi

	if [[ "${MACHINE}" = "imx8mm-var-dart" ]]; then
		echo "Copying M4 demo images to /opt/images/"
		pv ${ANDROID_BUILD_ROOT}/device/variscite/imx8m/dart_mx8mm/cm_hello_world.bin.debug > \
				${ROOTFS_ANDROID_PATH}/cm_hello_world.bin
		pv ${ANDROID_BUILD_ROOT}/device/variscite/imx8m/dart_mx8mm/cm_rpmsg_lite_pingpong_rtos_linux_remote.bin.debug > \
				${ROOTFS_ANDROID_PATH}/cm_rpmsg_lite_pingpong_rtos_linux_remote.bin
		pv ${ANDROID_BUILD_ROOT}/device/variscite/imx8m/dart_mx8mm/cm_rpmsg_lite_str_echo_rtos_imxcm4.bin.debug > \
				${ROOTFS_ANDROID_PATH}/cm_rpmsg_lite_str_echo_rtos_imxcm4.bin
		sync | pv -t
	elif [[ "${MACHINE}" = "imx8mn-var-som" ]]; then
		echo "Copying M7 demo images to /opt/images/"
		pv ${ANDROID_BUILD_ROOT}/device/variscite/imx8m/som_mx8mn/cm_hello_world.bin.debug > \
				${ROOTFS_ANDROID_PATH}/cm_hello_world.bin
		pv ${ANDROID_BUILD_ROOT}/device/variscite/imx8m/som_mx8mn/cm_rpmsg_lite_pingpong_rtos_linux_remote.bin.debug > \
				${ROOTFS_ANDROID_PATH}/cm_rpmsg_lite_pingpong_rtos_linux_remote.bin
		pv ${ANDROID_BUILD_ROOT}/device/variscite/imx8m/som_mx8mn/cm_rpmsg_lite_str_echo_rtos.bin.debug > \
				${ROOTFS_ANDROID_PATH}/cm_rpmsg_lite_str_echo_rtos.bin
		sync | pv -t
	elif [[ "${MACHINE}" = "imx8mp-var-dart" ]]; then
		echo "Copying M7 demo images to /opt/images/"
		pv ${ANDROID_BUILD_ROOT}/device/variscite/imx8m/dart_mx8mp/cm_hello_world.bin.debug_dart > \
				${ROOTFS_ANDROID_PATH}/cm_hello_world.bin.debug_dart
		pv ${ANDROID_BUILD_ROOT}/device/variscite/imx8m/dart_mx8mp/cm_hello_world.bin.debug_som > \
				${ROOTFS_ANDROID_PATH}/cm_hello_world.bin.debug_som
		pv ${ANDROID_BUILD_ROOT}/device/variscite/imx8m/dart_mx8mp/cm_rpmsg_lite_pingpong_rtos_linux_remote.bin.debug_dart > \
				${ROOTFS_ANDROID_PATH}/cm_rpmsg_lite_pingpong_rtos_linux_remote.bin.debug_dart
		pv ${ANDROID_BUILD_ROOT}/device/variscite/imx8m/dart_mx8mp/cm_rpmsg_lite_pingpong_rtos_linux_remote.bin.debug_som > \
				${ROOTFS_ANDROID_PATH}/cm_rpmsg_lite_pingpong_rtos_linux_remote.bin.debug_som
		pv ${ANDROID_BUILD_ROOT}/device/variscite/imx8m/dart_mx8mp/cm_rpmsg_lite_str_echo_rtos.bin.debug_dart > \
				${ROOTFS_ANDROID_PATH}/cm_rpmsg_lite_str_echo_rtos.bin.debug_dart
		pv ${ANDROID_BUILD_ROOT}/device/variscite/imx8m/dart_mx8mp/cm_rpmsg_lite_str_echo_rtos.bin.debug_som > \
				${ROOTFS_ANDROID_PATH}/cm_rpmsg_lite_str_echo_rtos.bin.debug_som
		sync | pv -t
	fi

}

function copy_android
{
	echo
	echo "Copying Android images to /opt/images/"
	ROOTFS_ANDROID_PATH=${ROOTFS_MOUNT_DIR}/opt/images/Android
	mkdir -p ${ROOTFS_ANDROID_PATH}
	rm -rf ${ROOTFS_ANDROID_PATH}/*
	do_copy_android
	if [ -n ${ANDROID_BUILD_SUBDIR} ] ; then
		ANDROID_IMGS_PATH=${ANDROID_IMGS_PATH}/${ANDROID_BUILD_SUBDIR}
		ROOTFS_ANDROID_PATH=${ROOTFS_ANDROID_PATH}/${ANDROID_BUILD_SUBDIR}
		mkdir -p ${ROOTFS_ANDROID_PATH}
		do_copy_android
	fi
}

function copy_android_scripts
{
	echo
	echo "Copying Android script"
	cp ${ANDROID_SCRIPTS_PATH}/mx8_install_android.sh		${ROOTFS_MOUNT_DIR}/usr/bin/install_android.sh
}

