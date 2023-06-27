#!/bin/bash
# Meant to be called by install_android.sh
set -e

blue_underlined_bold_echo()
{
	echo -e "\e[34m\e[4m\e[1m$@\e[0m"
}

blue_bold_echo()
{
	echo -e "\e[34m\e[1m$@\e[0m"
}

red_bold_echo()
{
	echo -e "\e[31m\e[1m$@\e[0m"
}

# Partition sizes in MiB
BOOTLOAD_RESERVE=8
DTBO_ROM_SIZE=4
BOOT_ROM_SIZE=64
SYSTEM_ROM_SIZE=1792
MISC_SIZE=4
METADATA_SIZE=16
PRESISTDATA_SIZE=1
VENDOR_ROM_SIZE=512
PRODUCT_ROM_SIZE=1792
FBMISC_SIZE=1
VBMETA_SIZE=1
SUPER_ROM_SIZE=4096
VENDOR_BOOT_SIZE=64
FIRMWARE_SIZE=1
MCU_OS_BOOT_SIZE=6
mcu_image_offset=5120

help() {

	bn=`basename $0`
	echo " usage $bn <option> device_node"
	echo
	echo " options:"
	echo " -h			displays this help message"
	echo " -s			only get partition size"
	echo " -f soc_name		flash android image."
}

function rename_remoteproc_images {
	if [[ "$1" == *"imx8mp-var-som"* ]]; then
		cp ${imagesdir}/${mcu_os_demo_file_8mp_som}	${imagesdir}/${mcu_os_demo_file}
	elif [[ "$1" == *"imx8mp-var-dart"* ]]; then
		cp ${imagesdir}/${mcu_os_demo_file_8mp_dart}	${imagesdir}/${mcu_os_demo_file}
	elif [[ "$1" == *"imx8mq-var-dart"* ]]; then
		cp -ar device/variscite/imx8m/dart_mx8mq/*.bin.debug ${imagesdir}
		cp ${imagesdir}/${mcu_os_demo_file_8mq_dart}	${imagesdir}/${mcu_os_demo_file}
	fi
}

# Parse command line
moreoptions=1
node="na"
soc_name="showoptions"
cal_only=0

while [ "$moreoptions" = 1 -a $# -gt 0 ]; do
	case $1 in
		-h) help; exit ;;
		-s) cal_only=1 ;;
		-f) soc_name=$2; shift;;
		*)  moreoptions=0; node=$1 ;;
	esac
	[ "$moreoptions" = 0 ] && [ $# -gt 2 ] && help && exit
	[ "$moreoptions" = 1 ] && shift
done

sdshared=false
if [[ "${soc_name}" = *"mx8mm"* ]]; then
	imagesdir="out/target/product/dart_mx8mm"
elif [[ "${soc_name}" = *"mx8mn"* ]]; then
	imagesdir="out/target/product/som_mx8mn"
	sdshared=false
elif [[ "${soc_name}" = *"mx8mp"* ]]; then
	imagesdir="out/target/product/dart_mx8mp"
	sdshared=false
elif [[ "${soc_name}" = *"mx8mq"* ]]; then
	imagesdir="out/target/product/dart_mx8mq"
	sdshared=true
elif [[ "${soc_name}" = *"mx8qxpb0"* ]]; then
	imagesdir="out/target/product/som_mx8q"
	sdshared=true
	bootloader_file="u-boot-imx8qxpb0-var-som.imx"
	socname_dtbo_mismatch=true
elif [[ "${soc_name}" = *"mx8qx"* ]]; then
	imagesdir="out/target/product/som_mx8q"
	sdshared=true
	bootloader_file="u-boot-imx8qxp-var-som.imx"
elif [[ "${soc_name}" = *"mx8qm"* ]]; then
	imagesdir="out/target/product/som_mx8q"
fi

img_prefix="dtbo-"
img_search_str="ls ${imagesdir}/${img_prefix}*"
if [ "$sdshared" = true ] ; then
	img_search_str+=" | grep sd"
fi
img_list=()

# generate options list
for img in $(eval $img_search_str)
do
	img=$(basename $img .img)
	img=${img#${img_prefix}}
	img_list+=($img)
done

# check for dtb
if [[ $soc_name != "showoptions" ]] && [[ ! ${img_list[@]} =~ $soc_name ]] ; then
	if [ "$socname_dtbo_mismatch" != true ] ; then
		echo; red_bold_echo "ERROR: invalid dtb $soc_name"
	fi
	soc_name=showoptions
fi

if [[ $soc_name == "showoptions" ]] && [[ ${#img_list[@]} == 1 ]] ; then
	soc_name=${img_list[0]};
fi

if [[ $soc_name == "showoptions" ]] && [[ ${#img_list[@]} > 1 ]] ; then
	PS3='Please choose your configuration: '
	select opt in "${img_list[@]}"
	do
		if [[ -z "$opt" ]] ; then
			echo invalid option
			continue
		else
			soc_name=$opt
			break
		fi
	done
fi

dtboimage_file="dtbo-${soc_name}.img"
bootimage_file="boot.img"
vendor_bootimage_file="vendor_boot.img"
vbmeta_file="vbmeta-${soc_name}.img"
systemimage_file="system.img"
vendorimage_file="vendor.img"
productimage_file="product.img"
superimage_file="super.img"
mcu_os_demo_file="rpmsg_lite_pingpong_rtos_linux_remote.bin"
mcu_os_demo_file_8mp_dart="cm_rpmsg_lite_pingpong_rtos_linux_remote.bin.debug_dart"
mcu_os_demo_file_8mp_som="cm_rpmsg_lite_pingpong_rtos_linux_remote.bin.debug_som"
mcu_os_demo_file_8mq_dart="cm_rpmsg_lite_pingpong_rtos_linux_remote.bin.debug"

block=`basename $node`
part=""
if [[ $block == mmcblk* ]] || [[ $block == loop* ]]; then
	part="p"
fi

if [[ "${soc_name}" = *"mx8d"* ]]; then
	bootloader_offset=16
fi


if [[ "${soc_name}" = *"mx8mq"* ]]; then
	bootloader_offset=33
	if [[ "${soc_name}" = *"dp"* ]]; then
		bootloader_file="u-boot-imx8mq-var-dart-dp.imx"
	else
		bootloader_file="u-boot-imx8mq-var-dart.imx"
	fi
fi

if [[ "${soc_name}" = *"mx8mm"* ]]; then
	bootloader_offset=33
	bootloader_file="u-boot-imx8mm-var-dart.imx"
fi

if [[ "${soc_name}" = *"mx8mn"* ]]; then
	bootloader_offset=32
	bootloader_file="u-boot-imx8mn-var-som.imx"
fi

if [[ "${soc_name}" = *"mx8mp"* ]]; then
	bootloader_offset=32
	bootloader_file="u-boot-imx8mp-var-dart.imx"
fi

if [[ "${soc_name}" = *"mx8qx"* ]]; then
	bootloader_offset=32
fi

if [[ "${soc_name}" = *"mx8qm"* ]]; then
	bootloader_offset=32
	bootloader_file="u-boot-imx8qm.imx"
fi

echo "${soc_name} image dir is: ${imagesdir}"
echo "${soc_name} bootloader is: ${bootloader_file}"
echo "${soc_name} bootloader offset is: ${bootloader_offset}"

dynamic_img=false
dynamic_part="SYSTEM_A         : ${SYSTEM_ROM_SIZE} MiB
SYSTEM_B         : ${SYSTEM_ROM_SIZE} MiB
VENDOR_A         : ${VENDOR_ROM_SIZE} MiB
VENDOR_B         : ${VENDOR_ROM_SIZE} MiB
PRODUCT_A        : ${PRODUCT_ROM_SIZE} MiB
PRODUCT_B        : ${PRODUCT_ROM_SIZE} MiB"

if [[ -f ${imagesdir}/${superimage_file} ]] ; then
	dynamic_img=true
	dynamic_part="SUPER           : ${SUPER_ROM_SIZE} MiB"
fi

firmware=""
if [[ "${soc_name}" = *"mx8qm"* ]]; then
firmware="FIRMWARE	 : ${FIRMWARE_SIZE} MiB"
fi

# Get total device size
seprate=100
total_size=`sfdisk -s ${node}`
total_size=`expr ${total_size} \/ 1024`
boot_rom_sizeb=`expr ${BOOTLOAD_RESERVE} + ${MCU_OS_BOOT_SIZE} + ${DTBO_ROM_SIZE} \* 2 + ${BOOT_ROM_SIZE} \* 2 + ${VENDOR_BOOT_SIZE} \* 2`

if [[ "${dynamic_img}" = true ]]; then
	if [[ "${soc_name}" = *"mx8qm"* ]]; then
		extend_size=`expr ${SUPER_ROM_SIZE} + ${MISC_SIZE} + ${METADATA_SIZE} + ${PRESISTDATA_SIZE} + ${FBMISC_SIZE} + ${VBMETA_SIZE} \* 2 + ${seprate} + ${FIRMWARE_SIZE}`
	else
		extend_size=`expr ${SUPER_ROM_SIZE} + ${MISC_SIZE} + ${METADATA_SIZE} + ${PRESISTDATA_SIZE} + ${FBMISC_SIZE} + ${VBMETA_SIZE} \* 2 + ${seprate}`
	fi
else
	extend_size=`expr ${SYSTEM_ROM_SIZE} \* 2 + ${MISC_SIZE} + ${METADATA_SIZE} + ${PRESISTDATA_SIZE} + ${VENDOR_ROM_SIZE} \* 2 + ${PRODUCT_ROM_SIZE} \* 2 + ${FBMISC_SIZE} + ${VBMETA_SIZE} \* 2 + ${seprate}`
fi

data_size=`expr ${total_size} - ${boot_rom_sizeb} - ${extend_size}`

# Echo partitions
cat << EOF
TOTAL            : ${total_size} MiB
U-BOOT (on eMMC) : ${BOOTLOAD_RESERVE} MiB
DTBO_A           : ${DTBO_ROM_SIZE} MiB
DTBO_B           : ${DTBO_ROM_SIZE} MiB
BOOT_A           : ${BOOT_ROM_SIZE} MiB
BOOT_B           : ${BOOT_ROM_SIZE} MiB
VENDOR_BOOT_A    : ${VENDOR_BOOT_SIZE} MiB
VENDOR_BOOT_B    : ${VENDOR_BOOT_SIZE} MiB
MISC             : ${MISC_SIZE} MiB
METADATA         : ${METADATA_SIZE} MiB
PRESISTDATA      : ${PRESISTDATA_SIZE} MiB
$dynamic_part
USERDATA         : ${data_size} MiB
FBMISC           : ${FBMISC_SIZE} MiB
VBMETA_A         : ${VBMETA_SIZE} MiB
VBMETA_B         : ${VBMETA_SIZE} MiB
$firmware
MCU_OS         : ${MCU_OS_BOOT_SIZE} MiB
EOF

echo

if [[ $cal_only == 1 ]] ; then
exit 0
fi

function check_images
{
	if [[ ! -b $node ]] ; then
		red_bold_echo "ERROR: \"$node\" is not a block device"
		exit 1
	fi

	if [[ ! -f ${imagesdir}/${bootloader_file} ]] ; then
		red_bold_echo "ERROR: ${bootloader_file} image does not exist"
		exit 1
	fi

	if [[ ! -f ${imagesdir}/${dtboimage_file} ]] ; then
		red_bold_echo "ERROR: ${dtboimage_file} image does not exist"
		exit 1
	fi

	if [[ ! -f ${imagesdir}/${bootimage_file} ]] ; then
		red_bold_echo "ERROR: ${bootimage_file} image does not exist"
		exit 1
	fi

	if [[ ! -f ${imagesdir}/${vendor_bootimage_file} ]] ; then
		red_bold_echo "ERROR: ${vendor_bootimage_file} image does not exist"
		exit 1
	fi

	if [[ "${dynamic_img}" = true ]]; then
		if [[ ! -f ${imagesdir}/${superimage_file} ]] ; then
			red_bold_echo "ERROR: ${superimage_file} image does not exist"
			exit 1
		fi
	else
		if [[ ! -f ${imagesdir}/${systemimage_file} ]] ; then
			red_bold_echo "ERROR: ${systemimage_file} image does not exist"
			exit 1
		fi

		if [[ ! -f ${imagesdir}/${productimage_file} ]] ; then
			red_bold_echo "ERROR: ${productimage_file} image does not exist"
			exit 1
		fi

		if [[ ! -f ${imagesdir}/${vendorimage_file} ]] ; then
			red_bold_echo "ERROR: ${vendorimage_file} image does not exist"
			exit 1
		fi
	fi

	if [[ ! -f ${imagesdir}/${vbmeta_file} ]] ; then
		red_bold_echo "ERROR: ${vbmeta_file} image does not exist"
		exit 1
	fi

	rename_remoteproc_images ${soc_name}
	if [[ ! -f ${imagesdir}/${mcu_os_demo_file} ]] ; then
		red_bold_echo "ERROR: ${mcu_os_demo_file} image does not exist"
		exit 1
	fi
}

function delete_device
{
	echo
	blue_underlined_bold_echo "Deleting current partitions"
	for partition in `ls ${node}${part}* 2> /dev/null`
	do
		if [[ ${partition} = ${node} ]] ; then
			# skip base node
			continue
		fi
		if [[ ! -b ${partition} ]] ; then
			red_bold_echo "ERROR: \"${partition}\" is not a block device"
			exit 1
		fi
		dd if=/dev/zero of=${partition} bs=1M count=1 2> /dev/null || true
	done
	sync

	((echo d; echo 1; echo d; echo 2; echo d; echo 3; echo d; echo w) | fdisk $node &> /dev/null) || true
	sync

	sgdisk -Z $node
	sync

	dd if=/dev/zero of=$node bs=1M count=8
	sync; sleep 1
}

function create_parts
{
	echo
	blue_underlined_bold_echo "Creating Android partitions"

	MCU_OFFSET=`expr ${BOOTLOAD_RESERVE} + ${MCU_OS_BOOT_SIZE}`
	sgdisk -n 1:${MCU_OFFSET}M:+${DTBO_ROM_SIZE}M		-c 1:"dtbo_a"      -t 1:8300  $node
	sgdisk -n 2:0:+${DTBO_ROM_SIZE}M                    -c 2:"dtbo_b"      -t 2:8300  $node
	sgdisk -n 3:0:+${BOOT_ROM_SIZE}M                    -c 3:"boot_a"      -t 3:8300  $node
	sgdisk -n 4:0:+${BOOT_ROM_SIZE}M                    -c 4:"boot_b"      -t 4:8300  $node
	sgdisk -n 5:0:+${VENDOR_BOOT_SIZE}M                 -c 5:"vendor_boot_a"      -t 5:8300  $node
	sgdisk -n 6:0:+${VENDOR_BOOT_SIZE}M                 -c 6:"vendor_boot_b"      -t 6:8300  $node
	if [[ "${dynamic_img}" = false ]]; then
		sgdisk -n 5:0:+${SYSTEM_ROM_SIZE}M                  -c 5:"system_a"    -t 3:8300  $node
		sgdisk -n 6:0:+${SYSTEM_ROM_SIZE}M                  -c 6:"system_b"    -t 4:8300  $node
		sgdisk -n 7:0:+${MISC_SIZE}M                        -c 7:"misc"        -t 5:8300  $node
		sgdisk -n 8:0:+${METADATA_SIZE}M                    -c 8:"metadata"    -t 6:8300  $node
		sgdisk -n 9:0:+${PRESISTDATA_SIZE}M                 -c 9:"presistdata" -t 7:8300  $node
	else
		sgdisk -n 7:0:+${MISC_SIZE}M                        -c 7:"misc"        -t 7:8300  $node
		sgdisk -n 8:0:+${METADATA_SIZE}M                    -c 8:"metadata"    -t 8:8300  $node
		sgdisk -n 9:0:+${PRESISTDATA_SIZE}M                 -c 9:"presistdata" -t 9:8300  $node
	fi
	if [[ "${dynamic_img}" = false ]]; then
		sgdisk -n 10:0:+${VENDOR_ROM_SIZE}M                 -c 10:"vendor_a"   -t 8:8300  $node
		sgdisk -n 11:0:+${VENDOR_ROM_SIZE}M                 -c 11:"vendor_b"   -t 9:8300  $node
		sgdisk -n 12:0:+${PRODUCT_ROM_SIZE}M                -c 12:"product_a"  -t 10:8300 $node
		sgdisk -n 13:0:+${PRODUCT_ROM_SIZE}M                -c 13:"product_b"  -t 11:8300 $node
		sgdisk -n 14:0:+${data_size}M                       -c 14:"userdata"   -t 12:8300 $node
		sgdisk -n 15:0:+${FBMISC_SIZE}M                     -c 15:"fbmisc"     -t 13:8300 $node
		sgdisk -n 16:0:+${VBMETA_SIZE}M                     -c 16:"vbmeta_a"   -t 14:8300 $node
		sgdisk -n 17:0:+${VBMETA_SIZE}M                     -c 17:"vbmeta_b"   -t 15:8300 $node
	else
		sgdisk -n 10:0:+${SUPER_ROM_SIZE}M                  -c 10:"super"        -t 10:8300  $node
		sgdisk -n 11:0:+${data_size}M                       -c 11:"userdata"     -t 11:8300 $node
		sgdisk -n 12:0:+${FBMISC_SIZE}M                     -c 12:"fbmisc"       -t 12:8300 $node
		sgdisk -n 13:0:+${VBMETA_SIZE}M                     -c 13:"vbmeta_a"     -t 13:8300 $node
		sgdisk -n 14:0:+${VBMETA_SIZE}M                     -c 14:"vbmeta_b"     -t 14:8300 $node
		if [[ "${soc_name}" = *"mx8qm"* ]]; then
			sgdisk -n 13:0:+${FIRMWARE_SIZE}M	    -c 13:"firmware"   -t 11:8300 $node
		fi
	fi

	sync; sleep 2

	for i in `cat /proc/mounts | grep "${node}" | awk '{print $2}'`; do umount $i; done
	hdparm -z $node
	sync; sleep 3

	# backup the GPT table to last LBA.
	echo -e 'r\ne\nY\nw\nY\nY' |  gdisk $node
	sync; sleep 1
	sgdisk -p $node
}

function install_bootloader
{
	echo
	blue_underlined_bold_echo "Installing booloader"

	dd if=${imagesdir}/${bootloader_file} of=$node bs=1k seek=${bootloader_offset}; sync

	echo
	blue_underlined_bold_echo "Installing mcu demo image: $mcu_os_demo_file"
	
	dd if=${imagesdir}/${mcu_os_demo_file} of=${node} bs=1k seek=${mcu_image_offset} conv=fsync,nocreat
	sync
}

function format_android
{
	echo
	if [[ "${dynamic_img}" = false ]]; then
		blue_underlined_bold_echo "Erasing presistdata partition"
		dd if=/dev/zero of=${node}${part}9 bs=1M count=${PRESISTDATA_SIZE} conv=fsync,nocreat
		blue_underlined_bold_echo "Erasing fbmisc partition"
		dd if=/dev/zero of=${node}${part}15 bs=1M count=${FBMISC_SIZE} conv=fsync,nocreat
		blue_underlined_bold_echo "Erasing misc partition"
		dd if=/dev/zero of=${node}${part}7 bs=1M count=${MISC_SIZE} conv=fsync,nocreat
		blue_underlined_bold_echo "Erasing metadata partition"
		dd if=/dev/zero of=${node}${part}8 bs=1M count=${METADATA_SIZE} conv=fsync,nocreat
		blue_underlined_bold_echo "Formating userdata partition"
		mkfs.ext4 -F ${node}${part}14 -Luserdata
	else
		blue_underlined_bold_echo "Erasing presistdata partition"
		dd if=/dev/zero of=${node}${part}9 bs=1M count=${PRESISTDATA_SIZE} conv=fsync,nocreat
		mkfs.ext4 -F ${node}${part}9 -Lmetadata
		blue_underlined_bold_echo "Erasing fbmisc partition"
		dd if=/dev/zero of=${node}${part}12 bs=1M count=${FBMISC_SIZE} conv=fsync,nocreat
		blue_underlined_bold_echo "Erasing misc partition"
		dd if=/dev/zero of=${node}${part}7 bs=1M count=${MISC_SIZE} conv=fsync,nocreat
		blue_underlined_bold_echo "Erasing metadata partition"
		dd if=/dev/zero of=${node}${part}8 bs=1M count=${METADATA_SIZE} conv=fsync,nocreat
		blue_underlined_bold_echo "Formating userdata partition"
		mkfs.ext4 -F ${node}${part}11 -Luserdata

		if [[ "${soc_name}" = *"mx8qm"* ]]; then
			blue_underlined_bold_echo "Formating firmware partition"
			mkfs.ext4 -F ${node}${part}13 -Lfirmware
		fi
	fi
	sync; sleep 1
}

function install_android
{
	echo
	blue_underlined_bold_echo "Installing Android dtbo image: $dtboimage_file"
	dd if=${imagesdir}/${dtboimage_file} of=${node}${part}1 bs=1M
	dd if=${imagesdir}/${dtboimage_file} of=${node}${part}2 bs=1M
	sync

	echo
	blue_underlined_bold_echo "Installing Android boot image: $bootimage_file"
	dd if=${imagesdir}/${bootimage_file} of=${node}${part}3 bs=1M
	dd if=${imagesdir}/${bootimage_file} of=${node}${part}4 bs=1M
	sync

	echo
	blue_underlined_bold_echo "Installing Android vendor boot image: $vendor_bootimage_file"
	dd if=${imagesdir}/${vendor_bootimage_file} of=${node}${part}5 bs=1M
	dd if=${imagesdir}/${vendor_bootimage_file} of=${node}${part}6 bs=1M
	sync

	if [[ "${dynamic_img}" = false ]]; then
		echo
		blue_underlined_bold_echo "Installing Android system image: $systemimage_file"
		simg2img ${imagesdir}/${systemimage_file} ${node}${part}5
		simg2img ${imagesdir}/${systemimage_file} ${node}${part}6
		sync;

		echo
		blue_underlined_bold_echo "Installing Android vendor image: $vendorimage_file"
		simg2img ${imagesdir}/${vendorimage_file} ${node}${part}10
		simg2img ${imagesdir}/${vendorimage_file} ${node}${part}11
		sync;

		echo
		blue_underlined_bold_echo "Installing Android product image: $productimage_file"
		simg2img ${imagesdir}/${productimage_file} ${node}${part}12
		simg2img ${imagesdir}/${productimage_file} ${node}${part}13
		sync;

		echo
		blue_underlined_bold_echo "Installing Android vbmeta image: $vbmeta_file"
		dd if=${imagesdir}/${vbmeta_file} of=${node}${part}16 bs=1M
		dd if=${imagesdir}/${vbmeta_file} of=${node}${part}17 bs=1M
		sync;
	else
		echo
		blue_underlined_bold_echo "Installing Android super image: $superimage_file"
		simg2img ${imagesdir}/${superimage_file} ${node}${part}10
		sync;

		echo
		blue_underlined_bold_echo "Installing Android vbmeta image: $vbmeta_file"
		dd if=${imagesdir}/${vbmeta_file} of=${node}${part}13 bs=1M
		dd if=${imagesdir}/${vbmeta_file} of=${node}${part}14 bs=1M
		sync;

		if [[ "${soc_name}" = *"mx8qm"* ]]; then
			echo
			blue_underlined_bold_echo "Installing firmware image"
			mkdir -p /tmp/firmware_mnt
			mount ${node}${part}13 /tmp/firmware_mnt
			mkdir -p /tmp/firmware_mnt/firmware
			cp -ar ${imagesdir}/vendor/firmware/hdp /tmp/firmware_mnt/firmware
			sync;
			umount /tmp/firmware_mnt
			rm -rf /tmp/firmware_mnt
		fi
	fi

	sleep 1
}

function finish
{
	echo
	errors=0
	for partition in ${node}*
	do
		if [[ ! -b ${partition} ]] ; then
			red_bold_echo "ERROR: \"${partition}\" is not a block device"
			errors=$((errors+1))
		fi
	done

	if [[ ${errors} = 0 ]] ; then
		blue_bold_echo "Android installed successfully"
	else
		red_bold_echo "Android installation failed"
	fi
	exit ${errors}
}

check_images

umount ${node}${part}*  2> /dev/null || true

#Stop Udev for block devices while partitioning in progress
#/etc/init.d/udev stop

delete_device
create_parts
install_bootloader
format_android
install_android
finish

#Start Udev back before exit
#/etc/init.d/udev restart

