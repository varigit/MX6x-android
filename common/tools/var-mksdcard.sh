#!/bin/bash

# android-tools-fsutils should be installed as
# "sudo apt-get install android-tools-fsutils"

# partition size in MB
BOOTLOAD_RESERVE=4
BOOT_ROM_SIZE=16
SYSTEM_ROM_SIZE=512
CACHE_SIZE=512
RECOVERY_ROM_SIZE=16
DEVICE_SIZE=8
MISC_SIZE=6
DATAFOOTER_SIZE=2

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
while [ "$moreoptions" = 1 -a $# -gt 0 ]; do
	case $1 in
	    -h) help; exit ;;
	    -s) cal_only=1 ;;
	    -f) flash_images=1 ; soc_name=$2; shift;;
	    -np) not_partition=1 ;;
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
block=`basename $node`
part=""
if [[ $block == mmcblk* ]] ; then
	part="p"
fi

# call sfdisk to create partition table
# get total card size
seprate=40
total_size=`sfdisk -s ${node}`
total_size=`expr ${total_size} / 1024`
echo "TOTAL SIZE ${total_size}MB"
boot_rom_sizeb=`expr ${BOOT_ROM_SIZE} + ${BOOTLOAD_RESERVE}`
extend_size=`expr ${SYSTEM_ROM_SIZE} + ${CACHE_SIZE} + ${DEVICE_SIZE} + ${MISC_SIZE} + ${DATAFOOTER_SIZE} + ${seprate}`
data_size=`expr ${total_size} - ${boot_rom_sizeb} - ${RECOVERY_ROM_SIZE} - ${extend_size}`

# Echo partitions
cat << EOF
U-BOOT : ${BOOTLOAD_RESERVE}MB
BOOT   : ${BOOT_ROM_SIZE}MB
RECOVERY: ${RECOVERY_ROM_SIZE}MB
SYSTEM : ${SYSTEM_ROM_SIZE}MB
CACHE  : ${CACHE_SIZE}MB
DATA   : ${data_size}MB
MISC   : ${MISC_SIZE}MB
DEVICE : ${DEVICE_SIZE}MB
DATAFOOTER : ${DATAFOOTER_SIZE}MB
EOF

if [ "${cal_only}" -eq "1" ]; then
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
	sync
}

function create_parts
{
	echo
	echo "Creating Android partitions"

	SECT_SIZE_BYTES=`cat /sys/block/${block}/queue/hw_sector_size`
	BOOTLOAD_RESERVE_sect=`expr $BOOTLOAD_RESERVE \* 1024 \* 1024 \/ $SECT_SIZE_BYTES`
	boot_rom_sizeb_sect=`expr $boot_rom_sizeb \* 1024 \* 1024 \/ $SECT_SIZE_BYTES`
	RECOVERY_ROM_SIZE_sect=`expr $RECOVERY_ROM_SIZE \* 1024 \* 1024 \/ $SECT_SIZE_BYTES`
	extend_size_sect=`expr $extend_size \* 1024 \* 1024 \/ $SECT_SIZE_BYTES`
	data_size_sect=`expr $data_size \* 1024 \* 1024 \/ $SECT_SIZE_BYTES`
	SYSTEM_ROM_SIZE_sect=`expr $SYSTEM_ROM_SIZE \* 1024 \* 1024 \/ $SECT_SIZE_BYTES`
	CACHE_SIZE_sect=`expr $CACHE_SIZE \* 1024 \* 1024 \/ $SECT_SIZE_BYTES`
	DEVICE_SIZE_sect=`expr $DEVICE_SIZE \* 1024 \* 1024 \/ $SECT_SIZE_BYTES`
	MISC_SIZE_sect=`expr $MISC_SIZE \* 1024 \* 1024 \/ $SECT_SIZE_BYTES`
	DATAFOOTER_SIZE_sect=`expr $DATAFOOTER_SIZE \* 1024 \* 1024 \/ $SECT_SIZE_BYTES`

sfdisk --force -uS ${node} &> /dev/null << EOF
,${boot_rom_sizeb_sect},83
,${RECOVERY_ROM_SIZE_sect},83
,${extend_size_sect},5
,${data_size_sect},83
,${SYSTEM_ROM_SIZE_sect},83
,${CACHE_SIZE_sect},83
,${DEVICE_SIZE_sect},83
,${MISC_SIZE_sect},83
,${DATAFOOTER_SIZE_sect},83
EOF

	sync; sleep 1

	# Adjust the partition reserve for bootloader.
	((echo d; echo 1; echo w) | fdisk $node &> /dev/null)
	sync; sleep 1
	((echo n; echo p; echo $BOOTLOAD_RESERVE_sect; echo; echo w) | fdisk -u $node &> /dev/null)
	sync; sleep 1

	fdisk -u -l $node
}

function format_android
{
	echo
	echo "Formating Android partitions"
	mkfs.ext4 ${node}${part}4 -Ldata
	mkfs.ext4 ${node}${part}5 -Lsystem
	mkfs.ext4 ${node}${part}6 -Lcache
	mkfs.ext4 ${node}${part}7 -Ldevice
	sync
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
	dd if=${imagesdir}/${bootimage_file} of=${node}${part}1
	sync

	echo
	echo "Installing Android recovery image: $recoveryimage_file"
	dd if=${imagesdir}/${recoveryimage_file} of=${node}${part}2
	sync

	echo
	echo "Installing Android system image: $systemimage_file"
	out/host/linux-x86/bin/simg2img ${imagesdir}/${systemimage_file} ${imagesdir}/${systemimage_raw_file}
	dd if=${imagesdir}/${systemimage_raw_file} of=${node}${part}5
	rm ${imagesdir}/${systemimage_raw_file}
	sync; sleep 1
}

check_images

umount ${node}${part}*  2> /dev/null || true

if [ "${not_partition}" -eq "0" ]; then
	delete_device
	create_parts
	format_android
fi

if [ "${flash_images}" -eq "1" ]; then
	install_bootloader
	install_android
fi

exit 0
