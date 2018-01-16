#!/bin/bash

# android-tools-fsutils should be installed as
# "sudo apt-get install android-tools-fsutils"

# partition size in MB
help() {

bn=`basename $0`
cat << EOF
usage $bn <option> device_node

options:
  -h				displays this help message
  -np 				not partition.
  -nf				not format partition
  -f soc_name			flash android image.
EOF

}

# parse command line
moreoptions=1
node="na"
soc_name=""
flash_images=0
not_partition=0
not_format_fs=0
while [ "$moreoptions" = 1 -a $# -gt 0 ]; do
	case $1 in
	    -h) help; exit ;;
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
partition_file="partition-table.img"

block=`basename $node`
part=""
if [[ $block == mmcblk* ]] ; then
	part="p"
fi

function check_images
{
	if [[ ! -b $node ]] ; then
		echo "ERROR: \"$node\" is not a block device"
		exit 1
	fi

	if [[ ! -f ${imagesdir}/${partition_file} ]] ; then
		echo "ERROR: Partition image does not exist"
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
}

function delete_device
{
	echo
	echo "Deleting current partitions"
	for ((i=0; i<=10; i++))
	do
		if [[ -e ${node}${part}${i} ]] ; then
			dd if=/dev/zero of=${node}${part}${i} bs=1024 count=1024 2> /dev/null || true
		fi
	done
	sync

	((echo d; echo 1; echo d; echo 2; echo d; echo 3; echo d; echo w) | fdisk $node &> /dev/null) || true
	sync

	dd if=/dev/zero of=$node bs=1M count=4
	sync; sleep 1
}

function create_parts
{
    echo "make gpt partition for android"
    dd if=${imagesdir}/${partition_file} of=${node} conv=fsync
}

function format_parts
{
	echo
	echo "Formating Android partitions"
	mkfs.ext4 -F ${node}10 -L data
	mkfs.ext4 -F ${node}3 -Lsystem
	mkfs.ext4 -F ${node}4 -Lcache
	mkfs.ext4 -F ${node}5 -Ldevice
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
	dd if=${imagesdir}/${systemimage_raw_file} of=${node}${part}5 bs=1M conv=fsync
	sync; sleep 1
}

umount ${node}${part}*  2> /dev/null || true

if [ "${not_partition}" -eq "0" ]; then
	delete_device
	create_parts
	sleep 3
	for i in `cat /proc/mounts | grep "${node}" | awk '{print $2}'`; do umount $i; done
	hdparm -z ${node}

	# backup the GPT table to last LBA for sd card.
	echo -e 'r\ne\nY\nw\nY\nY' |  gdisk ${node}

	if [ "${not_format_fs}" -eq "0" ]; then
		format_parts
	fi
fi

if [ "${flash_images}" -eq "1" ]; then
	check_images
	install_bootloader
	install_android
fi

exit 0
