#!/bin/bash
set -e

#### Script version ####
SCRIPT_NAME=${0##*/}
readonly SCRIPT_VERSION="0.8"

#### Exports Variables ####
#### global variables ####
readonly ABSOLUTE_FILENAME=`readlink -e "$0"`
readonly ABSOLUTE_DIRECTORY=`dirname ${ABSOLUTE_FILENAME}`
readonly SCRIPT_POINT=`pwd`/sources/meta-variscite-sdk-imx/scripts

ANDROID_SCRIPTS_PATH=${SCRIPT_POINT}/var_mk_yocto_sdcard/variscite_scripts
HOME="$(getent passwd $SUDO_USER | cut -d: -f6)"
ANDROID_BUILD_ROOT=${HOME}/var_imx-android-14.0.0_1.0.0/android_build

TEMP_DIR=./var_tmp
ROOTFS_MOUNT_DIR=${TEMP_DIR}/rootfs

help() {
	bn=`basename $0`
	echo " Usage: MACHINE=<imx8mq-var-dart|imx8mm-var-dart|imx8qxp-var-som|imx8qxpb0-var-som|imx8qm-var-som|imx8mn-var-som|imx8mp-var-dart> $bn device_node"
	echo
}

source ${ABSOLUTE_DIRECTORY}/var-android-sdcard-common.sh

MACHINE=$MACHINE ${SCRIPT_POINT}/var_mk_yocto_sdcard/var-create-yocto-sdcard.sh "$@"

# Parse command line only to get ${node} and ${part}
moreoptions=1
node="na"
cal_only=0

while [ "$moreoptions" = 1 -a $# -gt 0 ]; do
	case $1 in
	    -h) ;;
	    -s) ;;
	    -a) ;;
	    -r) shift;
	    ;;
	    -n) shift;
	    ;;
	    *)  moreoptions=0; node=$1 ;;
	esac
	[ "$moreoptions" = 1 ] && shift
done

part=""
if [[ $node == *mmcblk* ]] || [[ $node == *loop* ]] ; then
	part="p"
fi

echo "========================================================"
echo "= Variscite recovery SD card creation script - Android ="
echo "========================================================"

mount_parts
copy_android
copy_android_scripts

echo
echo "Syncing"
sync | pv -t

unmount_parts

echo
echo "Done"

exit 0
