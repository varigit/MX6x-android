#!/bin/bash

# partition size in MB
BOOTLOAD_RESERVE=8
BOOT_ROM_SIZE=16
SYSTEM_ROM_SIZE=512
CACHE_SIZE=512
RECOVERY_ROM_SIZE=16
BOOT_ROM_B_SIZE=16
SYSTEM_ROM_B_SIZE=512
MISC_SIZE=8

help() {

bn=`basename $0`
cat << EOF
usage $bn <option> device_node

options:
  -h				displays this help message
  -s				only get partition size
  -np 				not partition.
  -f   				flash brillo image.
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
spl_file="SPL"
bootloader_file="u-boot.img"
bootimage_file="boot.img"
systemimage_file="system_raw.img"
recoveryimage_file="boot.img"

while [ "$moreoptions" = 1 -a $# -gt 0 ]; do
	case $1 in
	    -h) help; exit ;;
	    -s) cal_only=1 ;;
	    -f) flash_images=1 ;;
	    -np) not_partition=1 ;;
	    -nf) not_format_fs=1 ;;
	    *)  moreoptions=0; node=$1 ;;
	esac
	[ "$moreoptions" = 0 ] && [ $# -gt 1 ] && help && exit
	[ "$moreoptions" = 1 ] && shift
done

if [ "${node}" = "/dev/sda" ]; then
        echo "====== dangous!"
        exit
fi

if [ ! -e ${node} ]; then
	echo "no such node ${node}"
	help
	exit
fi

part=""
echo ${node} | grep mmcblk > /dev/null
if [ "$?" -eq "0" ]; then
	part="p"
fi

# call sfdisk to create partition table
# get total card size
seprate=40
total_size=`sfdisk -s ${node}`
total_size=`expr ${total_size} / 1024`
boot_rom_sizeb=`expr ${BOOT_ROM_SIZE} + ${BOOTLOAD_RESERVE}`
extend_size=`expr ${SYSTEM_ROM_SIZE} + ${CACHE_SIZE} + ${BOOT_ROM_B_SIZE} + ${SYSTEM_ROM_B_SIZE} + ${MISC_SIZE} + ${seprate}`
data_size=`expr ${total_size} - ${boot_rom_sizeb} - ${RECOVERY_ROM_SIZE} - ${extend_size} + ${seprate}`

echo "total_size $total_size"
echo "boot_rom_sizeb $boot_rom_sizeb"
echo "extend_size $extend_size"
echo "data_size $data_size"

# create partitions
if [ "${cal_only}" -eq "1" ]; then
cat << EOF
BOOT   : ${boot_rom_sizeb}MB
RECOVERY: ${RECOVERY_ROM_SIZE}MB
SYSTEM : ${SYSTEM_ROM_SIZE}MB
CACHE  : ${CACHE_SIZE}MB
DATA   : ${data_size}MB
BOOT_B : ${BOOT_ROM_B_SIZE}MB
SYSTEM_B : ${SYSTEM_ROM_B_SIZE}MB
MISC : ${MISC_SIZE}MB
EOF
exit
fi

function umount_brillo
{
    echo "unmountig brillo partitions"
    umount ${node}${part}9
    umount ${node}${part}8
    umount ${node}${part}7
    umount ${node}${part}6
    umount ${node}${part}5
    umount ${node}${part}4
    umount ${node}${part}3
    umount ${node}${part}2
    umount ${node}${part}1
}

function format_brillo
{
    echo "formatting brillo partitions"
    mkfs.ext4 ${node}${part}4 -Ldata
    mkfs.ext4 ${node}${part}5 -Lsystem_a
    mkfs.ext4 ${node}${part}6 -Lcache
    mkfs.ext4 ${node}${part}8 -Lsystem_b
    mkfs.ext4 ${node}${part}9 -Lmisc
}

function flash_brillo
{
if [ "${flash_images}" -eq "1" ]; then
    echo "flashing brillo images..."
    echo "SPL: ${spl_file}"
    echo "bootloader: ${bootloader_file}"
    echo "boot image: ${bootimage_file}"
    echo "recovery image: ${recoveryimage_file}"
    echo "system image: ${systemimage_file}"

    dd if=/dev/zero of=${node} bs=1k seek=384 count=129
    dd if=${spl_file} of=${node} bs=1k seek=1
    dd if=${bootloader_file} of=${node} bs=1k seek=69
    dd if=${bootimage_file} of=${node}${part}1
    dd if=${recoveryimage_file} of=${node}${part}2
    dd if=${systemimage_file} of=${node}${part}5
    dd if=${bootimage_file} of=${node}${part}7
    dd if=${systemimage_file} of=${node}${part}8
    sync
fi
}

if [[ "${not_partition}" -eq "1" && "${flash_images}" -eq "1" ]] ; then
    flash_brillo
    exit
fi

umount_brillo

sfdisk --force -uM ${node} << EOF
,${boot_rom_sizeb},83
,${RECOVERY_ROM_SIZE},83
,${extend_size},5
,${data_size},83
,${SYSTEM_ROM_SIZE},83
,${CACHE_SIZE},83
,${BOOT_ROM_B_SIZE},83
,${SYSTEM_ROM_B_SIZE},83
,${MISC_SIZE},83
EOF

# adjust the partition reserve for bootloader.
# if you don't put the uboot on same device, you can remove the BOOTLOADER_ERSERVE
# to have 8M space.
# the minimal sylinder for some card is 4M, maybe some was 8M
# just 8M for some big eMMC 's sylinder
sfdisk --force -uM ${node} -N1 << EOF
${BOOTLOAD_RESERVE},${BOOT_ROM_SIZE},83
EOF

sleep 10
umount_brillo

# format the SDCARD/DATA/CACHE partition
format_brillo
flash_brillo

