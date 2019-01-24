#!/bin/bash

# android-tools-fsutils should be installed as
# "sudo apt-get install android-tools-fsutils"

# partition size in MB
BOOTLOAD_RESERVE=8
BOOT_ROM_SIZE=32
RECOVERY_ROM_SIZE=32
SYSTEM_ROM_SIZE=1536
CACHE_SIZE=512
VENDOR_SIZE=112
MISC_SIZE=4
DATAFOOTER_SIZE=2
METADATA_SIZE=2
PRESISTDATA_SIZE=1
FBMISC_SIZE=1

help() {

bn=`basename $0`
cat << EOF
usage $bn <option> device_node

options:
  -h				displays this help message
  -s				only get partition size
  -np 				not partition.
  -f soc_name			flash android image.
EOF

}

# parse command line
moreoptions=1
node="na"
soc_name=""
cal_only=0
flash_images=0
not_partition=0
not_format_fs=0
while [ "$moreoptions" = 1 -a $# -gt 0 ]; do
	case $1 in
	    -h) help; exit ;;
	    -s) cal_only=1 ;;
	    -f) flash_images=1 ; soc_name=$2; shift;;
	    -np) not_partition=1 ;;
	    -nf) not_format_fs=1 ;;
	    *)  moreoptions=0; node=$1 ;;
	esac
	[ "$moreoptions" = 0 ] && [ $# -gt 1 ] && help && exit
	[ "$moreoptions" = 1 ] && shift
done

if [ ! -e ${node} ]; then
	help
	exit
fi

imagesdir="out/target/product/var_mx6"
spl_file="SPL-var-imx6-sd"
bootloader_file="u-boot-var-imx6-sd.img"
bootimage_file="boot-${soc_name}.img"
recoveryimage_file="recovery-${soc_name}.img"
systemimage_file="system.img"
systemimage_raw_file="system_raw.img"
vendorimage_file="vendor.img"
vendorimage_raw_file="vendor_raw.img"

block=`basename $node`
part=""
if [[ $block == mmcblk* ]] ; then
	part="p"
fi

# Get total device size
seprate=100
total_size=`sfdisk -s ${node}`
total_size=`expr ${total_size} \/ 1024`
boot_rom_sizeb=`expr ${BOOT_ROM_SIZE} + ${BOOTLOAD_RESERVE}`
extend_size=`expr ${SYSTEM_ROM_SIZE} + ${CACHE_SIZE} + ${VENDOR_SIZE} + ${MISC_SIZE} + ${FBMISC_SIZE} + ${PRESISTDATA_SIZE} + ${DATAFOOTER_SIZE} + ${METADATA_SIZE} + ${seprate}`
data_size=`expr ${total_size} - ${boot_rom_sizeb} - ${RECOVERY_ROM_SIZE} - ${extend_size}`

# Echo partitions
cat << EOF
TOTAL            : ${total_size} MiB
U-BOOT		 : ${BOOTLOAD_RESERVE} MiB
BOOT             : ${BOOT_ROM_SIZE} MiB
RECOVERY         : ${RECOVERY_ROM_SIZE} MiB
SYSTEM           : ${SYSTEM_ROM_SIZE} MiB
CACHE            : ${CACHE_SIZE} MiB
MISC             : ${MISC_SIZE} MiB
DATAFOOTER       : ${DATAFOOTER_SIZE} MiB
METADATA         : ${METADATA_SIZE} MiB
PRESISTDATA      : ${PRESISTDATA_SIZE} MiB
VENDOR           : ${VENDOR_SIZE} MiB
USERDATA         : ${data_size} MiB
FBMISC           : ${FBMISC_SIZE} MiB
EOF

echo

if [[ $cal_only == 1 ]] ; then
    exit 0
fi

function check_images
{
	if [[ ! -b $node ]] ; then
		echo "ERROR: \"$node\" is not a block device"
		exit 1
	fi

	if [[ ! -f ${imagesdir}/${spl_file} ]] ; then
		echo "ERROR: SPL image does not exist"
		exit 1
	fi

	if [[ ! -f ${imagesdir}/${bootloader_file} ]] ; then
		echo "ERROR: U-Boot image does not exist"
		exit 1
	fi

	if [[ ! -f ${imagesdir}/${bootimage_file} ]] ; then
		echo "ERROR: boot image does not exist"
		exit 1
	fi

	if [[ ! -f ${imagesdir}/${recoveryimage_file} ]] ; then
		echo "ERROR: recovery image does not exist"
		exit 1
	fi

	if [[ ! -f ${imagesdir}/${systemimage_file} ]] ; then
		echo "ERROR: system image does not exist"
		exit 1
	fi

	if [[ ! -f ${imagesdir}/${vendorimage_file} ]] ; then
		echo "ERROR: system image does not exist"
		exit 1
	fi
}

function delete_device
{
	echo
	echo "Deleting current partitions"
	for ((i=0; i<=12; i++))
	do
		if [[ -e ${node}${part}${i} ]] ; then
			dd if=/dev/zero of=${node}${part}${i} bs=1024 count=1024 2> /dev/null || true
		fi
	done
	sync

	((echo d; echo 1; echo d; echo 2; echo d; echo 3; echo d; echo w) | fdisk $node &> /dev/null) || true
	sync

	sgdisk -Z $node
        sync

	dd if=/dev/zero of=$node bs=1M count=4
	sync; sleep 1
}

function create_parts
{
    echo "make gpt partition for android"

    sgdisk -n 1:${BOOTLOAD_RESERVE}M:+${BOOT_ROM_SIZE}M -c 1:"boot"        -t 1:8300  $node

    sgdisk -n 2:0:+${RECOVERY_ROM_SIZE}M                -c 2:"recovery"    -t 2:8300  $node

    sgdisk -n 3:0:+${SYSTEM_ROM_SIZE}M                  -c 3:"system"      -t 3:8300  $node

    sgdisk -n 4:0:+${CACHE_SIZE}M                       -c 4:"cache"       -t 4:8300  $node

    sgdisk -n 5:0:+${MISC_SIZE}M                        -c 5:"misc"        -t 5:8300  $node

    sgdisk -n 6:0:+${DATAFOOTER_SIZE}M                  -c 6:"datafooter"  -t 6:8300  $node

    sgdisk -n 7:0:+${METADATA_SIZE}M                    -c 7:"metadata"    -t 7:8300  $node

    sgdisk -n 8:0:+${PRESISTDATA_SIZE}M                 -c 8:"presistdata" -t 8:8300  $node

    sgdisk -n 9:0:+${VENDOR_SIZE}M                 	-c 9:"vendor"      -t 9:8300  $node

    sgdisk -n 10:0:+${data_size}M                       -c 10:"userdata"   -t 10:8300 $node

    sgdisk -n 11:0:+${FBMISC_SIZE}M                     -c 11:"fbmisc"     -t 11:0700 $node

    hdparm -z $node
    sync; sleep 3

    # backup the GPT table to last LBA.
    echo -e 'r\ne\nY\nw\nY\nY' |  gdisk $node
}

function format_parts
{
	echo
	echo "Formating Android partitions"
	mkfs.ext4 -F ${node}${part}10 -Ldata
	mkfs.ext4 -F ${node}${part}9 -Lvendor
	mkfs.ext4 -F ${node}${part}3 -Lsystem
	mkfs.ext4 -F ${node}${part}4 -Lcache
	mkfs.ext4 -F ${node}${part}5 -Ldevice
	sync; sleep 1
}

function install_bootloader
{
	echo
	echo "Installing booloader"

	dd if=${imagesdir}/${spl_file} of=$node bs=1k seek=1; sync

	dd if=${imagesdir}/${bootloader_file} of=$node bs=1k seek=69; sync
}

function install_android
{
	echo
	echo "Installing Android boot image: $bootimage_file"
	dd if=${imagesdir}/${bootimage_file} of=${node}${part}1 bs=1M conv=fsync
	sync

	echo
	echo "Installing Android recovery image: $recoveryimage_file"
	dd if=${imagesdir}/${recoveryimage_file} of=${node}${part}2 bs=1M conv=fsync
	sync

	echo
	echo "Installing Android system image: $systemimage_file"
	rm ${imagesdir}/${systemimage_raw_file} 2> /dev/null
	out/host/linux-x86/bin/simg2img ${imagesdir}/${systemimage_file} ${imagesdir}/${systemimage_raw_file}
	dd if=${imagesdir}/${systemimage_raw_file} of=${node}${part}3 bs=1M conv=fsync
	sync; sleep 1
	echo

	echo "Installing Android system image: $vendorimage_file"
	rm ${imagesdir}/${vendorimage_raw_file} 2> /dev/null
	out/host/linux-x86/bin/simg2img ${imagesdir}/${vendorimage_file} ${imagesdir}/${vendorimage_raw_file}
	dd if=${imagesdir}/${vendorimage_raw_file} of=${node}${part}9 bs=1M conv=fsync
	sync; sleep 1
}

umount ${node}${part}*  2> /dev/null || true

if [ "${not_partition}" -eq "0" ]; then
	delete_device
	create_parts
	format_parts
fi

if [ "${flash_images}" -eq "1" ]; then
	check_images
	install_android
	install_bootloader
fi

exit 0
