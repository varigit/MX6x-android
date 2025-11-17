#!/bin/bash
set -e

help() {
	bn=`basename $0`
	echo "Usage: MACHINE=<imx8mq-var-dart|imx8mm-var-dart|imx8qxp-var-som|imx8qxpb0-var-som|imx8qm-var-som|imx8mn-var-som|imx8mp-var-dart|imx95-var-dart> $bn yocto_image.wic.zst [new_image_name]"
	echo "Launch from Android build root directory or set variable ANDROID_BUILD_ROOT to path"
	echo
}

if [ -z $1 ] ; then
	help
fi

#### Exports Variables ####
#### global variables ####
readonly ABSOLUTE_FILENAME=`readlink -e "$0"`
readonly ABSOLUTE_DIRECTORY=`dirname ${ABSOLUTE_FILENAME}`

ANDROID_SCRIPTS_PATH=${ABSOLUTE_DIRECTORY}/variscite_scripts
if [ -z "${ANDROID_BUILD_ROOT}" ] ; then
	ANDROID_BUILD_ROOT=`pwd`
fi
YOCTO_IMAGE_FILE_COMP=`readlink -e "$1"`
YOCTO_IMAGE_FILE=${YOCTO_IMAGE_FILE_COMP%.*}
YOCTO_IMAGE_DIRECTORY=`dirname ${YOCTO_IMAGE_FILE}`
NEW_YOCTO_IMAGE_FILE=${YOCTO_IMAGE_DIRECTORY}/$2.wic

TEMP_DIR=./var_tmp
ROOTFS_MOUNT_DIR=${TEMP_DIR}/rootfs

source ${ABSOLUTE_DIRECTORY}/var-android-sdcard-common.sh

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
	node=`losetup -a |grep -v "deleted" |grep ${YOCTO_IMAGE_FILE} |cut -d : -f 1`
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
