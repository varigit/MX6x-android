#!/bin/bash
# Meant to be called by install_android.sh
set -e

. /usr/bin/echos.sh

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
som=""
sdshared=false
img_list=()
if grep -q "i.MX8MM" /sys/devices/soc0/soc_id; then
	node=/dev/mmcblk2
	som="imx8mm"
elif grep -q "i.MX8MN" /sys/devices/soc0/soc_id; then
	node=/dev/mmcblk2
	som="imx8mn"
elif grep -q "i.MX8MP" /sys/devices/soc0/soc_id; then
	node=/dev/mmcblk2
	som="imx8mp"
elif grep -q "i.MX8M" /sys/devices/soc0/soc_id; then
	node=/dev/mmcblk0
	sdshared=true
	som="imx8mq"
elif grep -q "i.MX8QXP" /sys/devices/soc0/soc_id; then
	node=/dev/mmcblk0
	sdshared=true
	som="imx8x"
elif grep -q "i.MX8QM" /sys/devices/soc0/soc_id; then
	node=/dev/mmcblk0
	som="imx8qm"
else
	red_bold_echo "ERROR: Unsupported board"
	exit 1
fi

function add_imx8mp_menu() {
	img_list+=("dtbo-imx8mp-var-dart-dt8mcustomboard-legacy-basler-isp0.img (DART-MX8M-PLUS on DT8MCustomBoard 1.x, with LVDS and Basler VCAM-AR0821B camera support)")
	img_list+=("dtbo-imx8mp-var-dart-dt8mcustomboard-legacy-hdmi.img        (DART-MX8M-PLUS on DT8MCustomBoard 1.x, with HDMI support)")
	img_list+=("dtbo-imx8mp-var-dart-dt8mcustomboard-legacy-m7.img          (DART-MX8M-PLUS on DT8MCustomBoard 1.x, with LVDS and M7 support)")
	img_list+=("dtbo-imx8mp-var-dart-dt8mcustomboard-legacy.img             (DART-MX8M-PLUS on DT8MCustomBoard 1.x, with LVDS support)")
	img_list+=("dtbo-imx8mp-var-dart-dt8mcustomboard-basler-isp0.img        (DART-MX8M-PLUS on DT8MCustomBoard 2.x and above, with LVDS and Basler VCAM-AR0821B camera support)")
	img_list+=("dtbo-imx8mp-var-dart-dt8mcustomboard-hdmi.img               (DART-MX8M-PLUS on DT8MCustomBoard 2.x and above, with HDMI support)")
	img_list+=("dtbo-imx8mp-var-dart-dt8mcustomboard-m7.img                 (DART-MX8M-PLUS on DT8MCustomBoard 2.x and above, with LVDS and M7 support)")
	img_list+=("dtbo-imx8mp-var-dart-dt8mcustomboard.img                    (DART-MX8M-PLUS on DT8MCustomBoard 2.x and above, with LVDS support)")
	img_list+=("dtbo-imx8mp-var-som-symphony-2nd-ov5640-m7.img              (VAR-SOM-MX8M-PLUS on Symphony-Board, with LVDS, 2nd OV5640 and M7 support)")
	img_list+=("dtbo-imx8mp-var-som-symphony-2nd-ov5640.img                 (VAR-SOM-MX8M-PLUS on Symphony-Board, with LVDS and 2nd OV5640 support)")
	img_list+=("dtbo-imx8mp-var-som-symphony-basler-isp0.img                (VAR-SOM-MX8M-PLUS on Symphony-Board, with LVDS and Basler VCAM-AR0821B camera support)")
	img_list+=("dtbo-imx8mp-var-som-symphony-hdmi.img                       (VAR-SOM-MX8M-PLUS on Symphony-Board, with HDMI support)")
	img_list+=("dtbo-imx8mp-var-som-symphony-m7.img                         (VAR-SOM-MX8M-PLUS on Symphony-Board, with LVDS and M7 support)")
	img_list+=("dtbo-imx8mp-var-som-symphony.img                            (VAR-SOM-MX8M-PLUS on Symphony-Board, with LVDS support)")
}

function add_imx8mm_menu() {
	img_list+=("dtbo-imx8mm-var-dart-dt8mcustomboard-legacy-m4.img (DART-MX8M-MINI on DT8MCustomBoard 1.x, with M4 support)")
	img_list+=("dtbo-imx8mm-var-dart-dt8mcustomboard-legacy.img    (DART-MX8M-MINI on DT8MCustomBoard 1.x)")
	img_list+=("dtbo-imx8mm-var-dart-dt8mcustomboard-m4.img        (DART-MX8M-MINI on DT8MCustomBoard 2.x and above, with M4 support)")
	img_list+=("dtbo-imx8mm-var-dart-dt8mcustomboard.img           (DART-MX8M-MINI on DT8MCustomBoard 2.x and above)")
	img_list+=("dtbo-imx8mm-var-som-symphony-legacy-m4.img         (VAR-SOM-MX8M-MINI on Symphony-Board V1.4 and below, with M4 support)")
	img_list+=("dtbo-imx8mm-var-som-symphony-legacy.img            (VAR-SOM-MX8M-MINI on Symphony-Board V1.4 and below)")
	img_list+=("dtbo-imx8mm-var-som-symphony-m4.img                (VAR-SOM-MX8M-MINI on Symphony-Board V1.4A and above, with M4 support)")
	img_list+=("dtbo-imx8mm-var-som-symphony.img                   (VAR-SOM-MX8M-MINI on Symphony-Board V1.4A and above)")
}

function add_imx8mq_menu() {
	img_list+=("dtbo-imx8mq-var-dart-dt8mcustomboard-legacy-m4-wifi-dp.img        (DART-MX8M on DT8MCustomBoard 1.x, with Display Port, WiFi and M4 support)")
	img_list+=("dtbo-imx8mq-var-dart-dt8mcustomboard-legacy-m4-wifi-hdmi.img      (DART-MX8M on DT8MCustomBoard 1.x, with HDMI, WiFi and M4 support)")
	img_list+=("dtbo-imx8mq-var-dart-dt8mcustomboard-legacy-m4-wifi-lvds-dp.img   (DART-MX8M on DT8MCustomBoard 1.x, with LVDS, Display Port, WiFi and M4 support)")
	img_list+=("dtbo-imx8mq-var-dart-dt8mcustomboard-legacy-m4-wifi-lvds-hdmi.img (DART-MX8M on DT8MCustomBoard 1.x, with LVDS, HDMI, WiFi and M4 support)")
	img_list+=("dtbo-imx8mq-var-dart-dt8mcustomboard-legacy-m4-wifi-lvds.img      (DART-MX8M on DT8MCustomBoard 1.x, with LVDS, WiFi and M4 support)")
	img_list+=("dtbo-imx8mq-var-dart-dt8mcustomboard-legacy-wifi-dp.img           (DART-MX8M on DT8MCustomBoard 1.x, with Display Port and WiFi support)")
	img_list+=("dtbo-imx8mq-var-dart-dt8mcustomboard-legacy-wifi-hdmi.img         (DART-MX8M on DT8MCustomBoard 1.x, with HDMI and WiFi support)")
	img_list+=("dtbo-imx8mq-var-dart-dt8mcustomboard-legacy-wifi-lvds-dp.img      (DART-MX8M on DT8MCustomBoard 1.x, with LVDS, Display Port and WiFi support)")
	img_list+=("dtbo-imx8mq-var-dart-dt8mcustomboard-legacy-wifi-lvds-hdmi.img    (DART-MX8M on DT8MCustomBoard 1.x, with LVDS, HDMI and WiFi support)")
	img_list+=("dtbo-imx8mq-var-dart-dt8mcustomboard-legacy-wifi-lvds.img         (DART-MX8M on DT8MCustomBoard 1.x, with LVDS and WiFi support)")
	img_list+=("dtbo-imx8mq-var-dart-dt8mcustomboard-m4-wifi-hdmi.img             (DART-MX8M on DT8MCustomBoard 2.x and above, with HDMI, WiFi and M4 support)")
	img_list+=("dtbo-imx8mq-var-dart-dt8mcustomboard-m4-wifi-lvds-hdmi.img        (DART-MX8M on DT8MCustomBoard 2.x and above, with LVDS, HDMI, WiFi and M4 support)")
	img_list+=("dtbo-imx8mq-var-dart-dt8mcustomboard-m4-wifi-lvds.img             (DART-MX8M on DT8MCustomBoard 2.x and above, with LVDS, WiFi and M4 support)")
	img_list+=("dtbo-imx8mq-var-dart-dt8mcustomboard-wifi-hdmi.img                (DART-MX8M on DT8MCustomBoard 2.x and above, with HDMI and WiFi support)")
	img_list+=("dtbo-imx8mq-var-dart-dt8mcustomboard-wifi-lvds-hdmi.img           (DART-MX8M on DT8MCustomBoard 2.x and above, with LVDS, HDMI and WiFi support)")
	img_list+=("dtbo-imx8mq-var-dart-dt8mcustomboard-wifi-lvds.img                (DART-MX8M on DT8MCustomBoard 2.x and above, with LVDS and WiFi support)")
}

function add_imx8x_menu() {
	img_list+=("dtbo-imx8qxp-var-som-symphony-wifi-m4.img (VAR-SOM-MX8QXP on Symphony-Board, with LVDS, WiFi and M4 support)")
	img_list+=("dtbo-imx8qxp-var-som-symphony-wifi.img    (VAR-SOM-MX8QXP on Symphony-Board, with LVDS and WiFi support)")
}

function add_imx8qm_menu() {
	img_list+=("dtbo-imx8qp-var-som-lvds-m4.img   (VAR-SOM-MX8 with i.MX8QP on Symphony-Board, with LVDS and M4 support)")
	img_list+=("dtbo-imx8qp-var-som-lvds.img      (VAR-SOM-MX8 with i.MX8QP on Symphony-Board, with LVDS support)")
	img_list+=("dtbo-imx8qp-var-som-hdmi-m4.img   (VAR-SOM-MX8 with i.MX8QP on Symphony-Board, with HDMI and M4 support)")
	img_list+=("dtbo-imx8qp-var-som-hdmi.img      (VAR-SOM-MX8 with i.MX8QP on Symphony-Board, with HDMI support)")
	img_list+=("dtbo-imx8qp-var-som-dp-m4.img     (VAR-SOM-MX8 with i.MX8QP on Symphony-Board, with Display Port and M4 support)")
	img_list+=("dtbo-imx8qp-var-som-dp.img        (VAR-SOM-MX8 with i.MX8QP on Symphony-Board, with Display Port support)")
	img_list+=("dtbo-imx8qm-var-som-lvds-m4.img   (VAR-SOM-MX8 with i.MX8QM on Symphony-Board, with LVDS and M4 support)")
	img_list+=("dtbo-imx8qm-var-som-lvds.img      (VAR-SOM-MX8 with i.MX8QM on Symphony-Board, with LVDS support)")
	img_list+=("dtbo-imx8qm-var-som-hdmi-m4.img   (VAR-SOM-MX8 with i.MX8QM on Symphony-Board, with HDMI and M4 support)")
	img_list+=("dtbo-imx8qm-var-som-hdmi.img      (VAR-SOM-MX8 with i.MX8QM on Symphony-Board, with HDMI support)")
	img_list+=("dtbo-imx8qm-var-som-dp-m4.img     (VAR-SOM-MX8 with i.MX8QM on Symphony-Board, with Display port and M4 support)")
	img_list+=("dtbo-imx8qm-var-som-dp.img        (VAR-SOM-MX8 with i.MX8QM on Symphony-Board, with Display port support)")
	img_list+=("dtbo-imx8qp-var-spear-dp-m4.img   (SPEAR-MX8 with i.MX8QP on SP8CustomBoard, with Display Port and M4 support)")
	img_list+=("dtbo-imx8qp-var-spear.img         (SPEAR-MX8 with i.MX8QP on SP8CustomBoard, with Display Port)")
	img_list+=("dtbo-imx8qp-var-spear-lvds-m4.img (SPEAR-MX8 with i.MX8QP on SP8CustomBoard, with LVDS and M4 support)")
	img_list+=("dtbo-imx8qp-var-spear-lvds.img    (SPEAR-MX8 with i.MX8QP on SP8CustomBoard, with LVDS support)")
	img_list+=("dtbo-imx8qp-var-spear-hdmi-m4.img (SPEAR-MX8 with i.MX8QP on SP8CustomBoard, with HDMI and M4 support)")
	img_list+=("dtbo-imx8qp-var-spear-hdmi.img    (SPEAR-MX8 with i.MX8QP on SP8CustomBoard, with HDMI support)")
	img_list+=("dtbo-imx8qm-var-spear-lvds.img    (SPEAR-MX8 with i.MX8QM on SP8CustomBoard, with LVDS support)")
	img_list+=("dtbo-imx8qm-var-spear-lvds-m4.img (SPEAR-MX8 with i.MX8QM on SP8CustomBoard, with LVDS and M4 support)")
	img_list+=("dtbo-imx8qm-var-spear-hdmi-m4.img (SPEAR-MX8 with i.MX8QM on SP8CustomBoard, with HDMI and M4 support)")
	img_list+=("dtbo-imx8qm-var-spear-hdmi.img    (SPEAR-MX8 with i.MX8QM on SP8CustomBoard, with HDMI support)")
	img_list+=("dtbo-imx8qm-var-spear-dp-m4.img   (SPEAR-MX8 with i.MX8QM on SP8CustomBoard, with Display Port and M4 support)")
	img_list+=("dtbo-imx8qm-var-spear-dp.img      (SPEAR-MX8 with i.MX8QM on SP8CustomBoard, with Display Port)")
}

function add_imx8mn_menu() {
	img_list+=("dtbo-imx8mn-var-som-symphony-m7.img        (VAR-SOM-MX8M-NANO on Symphony-Board with M7 support)")
	img_list+=("dtbo-imx8mn-var-som-symphony.img           (VAR-SOM-MX8M-NANO on Symphony-Board)")
}

imagesdir="/opt/images/Android"
soc_name="showoptions"

function help() {

	bn=`basename $0`
	echo " usage $bn <option>"
	echo
	echo " options:"
	echo " -h			displays this help message"
	echo " -f soc_name		flash android image [optional]."
}

function rename_remoteproc_images {
	if [[ "$1" == *"imx8mp-var-som"* ]]; then
		cp ${imagesdir}/${mcu_os_demo_file_8mp_som}	${imagesdir}/${mcu_os_demo_file}
	elif [[ "$1" == *"imx8mp-var-dart"* ]]; then
		cp ${imagesdir}/${mcu_os_demo_file_8mp_dart}	${imagesdir}/${mcu_os_demo_file}
	fi	
}

moreoptions=1
while [ "$moreoptions" = 1 -a $# -gt 0 ]; do
	case $1 in
		-h) help; exit ;;
		-f) soc_name=$2; shift ;;
		*)  moreoptions=0 ;;
	esac
	[ "$moreoptions" = 0 ] && [ $# -gt 2 ] && help && exit
	[ "$moreoptions" = 1 ] && shift
done

#Prepare the menu based on SOM
case $som in
	"imx8mp")
		add_imx8mp_menu;;
	"imx8mm")
		add_imx8mm_menu;;
	"imx8qm")
		add_imx8qm_menu;;
	"imx8x")
		add_imx8x_menu;;
	"imx8mq")
		add_imx8mq_menu;;
	"imx8mn")
		add_imx8mn_menu;;
	*)
		echo "Invalid SOM"; exit;;
esac

min=0
max=$(( ${#img_list[@]} -1 ))
img_prefix="dtbo-"
while [[ min -lt max ]]
do
    # Swap current first and last elements
    x="${img_list[$min]}"
    img_list[$min]="${img_list[$max]}"
    img_list[$max]="$x"

    # Move closer
    (( min++, max-- ))
done

# check for dtb
if [[ $soc_name != "showoptions" ]] && [[ ! ${img_list[@]} =~ $soc_name ]] ; then
	echo; red_bold_echo "ERROR: invalid dtb $soc_name"
	soc_name=showoptions
fi

if [[ $soc_name == "showoptions" ]] && [[ ${#img_list[@]} == 1 ]] ; then
	soc_name=${img_list[0]};
fi

if [[ $soc_name == "showoptions" ]] && [[ ${#img_list[@]} > 1 ]] ; then
	PS3='Please choose the correct dtbo image for your board configuration: '
	COLUMNS=20
	select opt in "${img_list[@]}"
	do
		if [[ -z "$opt" ]] ; then
			echo invalid option
			continue
		else
			if grep -q "i.MX8MM\|i.MX8MN\|i.MX8MQ\|i.MX8MP\|i.MX8QM\|i.MX8QP\|i.MX8QXP" /sys/devices/soc0/soc_id; then
				soc_name=`echo $opt | cut -d "." -f1`
				soc_name=`echo ${soc_name} | sed "s/${img_prefix}//"`
			else
				soc_name=$opt
			fi
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

block=`basename $node`
part=""
if [[ $block == mmcblk* ]] ; then
	part="p"
fi

if [[ "${soc_name}" = *"mx8d"* ]]; then
	bootloader_offset=16
fi

bootloader_file="u-boot-var-imx6-sd.img"
bootloader_offset=1

if [[ "${soc_name}" = *"mx8mq"* ]]; then
	bootloader_offset=33
	if [[ "${soc_name}" = *"dp"* ]]; then
		bootloader_file="u-boot-imx8mq-var-dart-dp.imx"
	else
		bootloader_file="u-boot-imx8mq-var-dart.imx"
	fi
	mcu_os_demo_file="cm_rpmsg_lite_pingpong_rtos_linux_remote.bin"
fi

if [[ "${soc_name}" = *"mx8mm"* ]]; then
	bootloader_offset=33
	bootloader_file="u-boot-imx8mm-var-dart.imx"
fi

if [[ "${soc_name}" = *"mx8mp"* ]]; then
	bootloader_offset=32
	bootloader_file="u-boot-imx8mp-var-dart.imx"
fi


if [[ "${soc_name}" = *"mx8qx"* ]]; then
	bootloader_offset=32
	if [[ -f "${imagesdir}/u-boot-imx8qxpb0-var-som.imx" ]]; then
		bootloader_file="u-boot-imx8qxpb0-var-som.imx"
	elif [[ -f "${imagesdir}/u-boot-imx8qxp-var-som.imx" ]]; then
		bootloader_file="u-boot-imx8qxp-var-som.imx"
	else
		echo; red_bold_echo "ERROR: no bootloader image present"
	fi
	mcu_os_demo_file="cm_rpmsg_lite_pingpong_rtos_linux_remote.bin"
fi

if [[ "${soc_name}" = *"mx8qm"* ]] || [[ "${soc_name}" = *"mx8qp"* ]]; then
	bootloader_offset=32
	bootloader_file="u-boot-imx8qm-var-som.imx"

	mcu_os_demo_file="cm_rpmsg_lite_pingpong_rtos_linux_remote_m40.bin"
fi

if [[ "${soc_name}" = *"mx8mn"* ]]; then
       bootloader_offset=32
       bootloader_file="u-boot-imx8mn-var-som.imx"
       mcu_os_demo_file="cm_rpmsg_lite_pingpong_rtos_linux_remote.bin"
fi

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
if [[ "${soc_name}" = *"mx8qm"* ]] || [[ "${soc_name}" = *"mx8qp"* ]]; then
firmware="FIRMWARE	 : ${FIRMWARE_SIZE} MiB"
fi

# Get total device size
seprate=100
total_size=`sfdisk -s ${node}`
total_size=`expr ${total_size} \/ 1024`
boot_rom_sizeb=`expr ${BOOTLOAD_RESERVE} + ${MCU_OS_BOOT_SIZE} + ${DTBO_ROM_SIZE} \* 2 + ${BOOT_ROM_SIZE} \* 2 + ${VENDOR_BOOT_SIZE} \* 2`

if [[ "${dynamic_img}" = true ]]; then
	if [[ "${soc_name}" = *"mx8qm"* ]] || [[ "${soc_name}" = *"mx8qp"* ]]; then
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
		if [[ "${soc_name}" = *"mx8qm"* ]] || [[ "${soc_name}" = *"mx8qp"* ]]; then
			sgdisk -n 15:0:+${FIRMWARE_SIZE}M	      -c 15:"firmware"	    -t 15:8300 $node
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
	
	dd if=${imagesdir}/${mcu_os_demo_file} of=${node} bs=1k seek=${mcu_image_offset} conv=fsync
	sync
}

function format_android
{
	echo
	if [[ "${dynamic_img}" = false ]]; then
		blue_underlined_bold_echo "Erasing presistdata partition"
		dd if=/dev/zero of=${node}${part}9 bs=1M count=${PRESISTDATA_SIZE} conv=fsync
		blue_underlined_bold_echo "Erasing fbmisc partition"
		dd if=/dev/zero of=${node}${part}15 bs=1M count=${FBMISC_SIZE} conv=fsync
		blue_underlined_bold_echo "Erasing misc partition"
		dd if=/dev/zero of=${node}${part}7 bs=1M count=${MISC_SIZE} conv=fsync
		blue_underlined_bold_echo "Erasing metadata partition"
		dd if=/dev/zero of=${node}${part}8 bs=1M count=${METADATA_SIZE} conv=fsync
		blue_underlined_bold_echo "Formating userdata partition"
		mkfs.ext4 -F ${node}${part}14 -Ldata
	else
		blue_underlined_bold_echo "Erasing presistdata partition"
		dd if=/dev/zero of=${node}${part}9 bs=1M count=${PRESISTDATA_SIZE} conv=fsync
		mkfs.ext4 -F ${node}${part}9 -Lmetadata
		blue_underlined_bold_echo "Erasing fbmisc partition"
		dd if=/dev/zero of=${node}${part}12 bs=1M count=${FBMISC_SIZE} conv=fsync
		blue_underlined_bold_echo "Erasing misc partition"
		dd if=/dev/zero of=${node}${part}7 bs=1M count=${MISC_SIZE} conv=fsync
		blue_underlined_bold_echo "Erasing metadata partition"
		dd if=/dev/zero of=${node}${part}8 bs=1M count=${METADATA_SIZE} conv=fsync
		blue_underlined_bold_echo "Formating userdata partition"
		mkfs.ext4 -F ${node}${part}11 -Ldata

		if [[ "${soc_name}" = *"mx8qm"* ]] || [[ "${soc_name}" = *"mx8qp"* ]]; then
			blue_underlined_bold_echo "Formating firmware partition"
			mkfs.ext4 -F ${node}${part}15 -Lfirmware
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

		if [[ "${soc_name}" = *"mx8qm"* ]] || [[ "${soc_name}" = *"mx8qp"* ]]; then
			echo
			blue_underlined_bold_echo "Installing firmware image"
			mkdir -p /tmp/firmware_mnt
			mount ${node}${part}15 /tmp/firmware_mnt
			mkdir -p /tmp/firmware_mnt/firmware/hdp
			cp ${imagesdir}/*.bin /tmp/firmware_mnt/firmware/hdp
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
	for partition in ${node}${part}*
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

stop_udev()
{
        if [ -f /lib/systemd/system/systemd-udevd.service ]; then
                systemctl -q stop \
                        systemd-udevd-kernel.socket \
                        systemd-udevd-control.socket \
                        systemd-udevd
        fi
}

start_udev()
{
        if [ -f /lib/systemd/system/systemd-udevd.service ]; then
                systemctl -q start \
                        systemd-udevd-kernel.socket \
                        systemd-udevd-control.socket \
                        systemd-udevd
        fi
}

check_images

umount ${node}${part}*  2> /dev/null || true

stop_udev
delete_device
create_parts
install_bootloader
format_android
install_android
start_udev
finish
