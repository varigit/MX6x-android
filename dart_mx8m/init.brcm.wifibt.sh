#!/vendor/bin/sh

#################################
# /etc/wifi/variscite-wifi.conf #
#################################

WIFI_VSEL_GPIO=4
WIFI_PWR_GPIO=8
WIFI_EN_GPIO=66
BT_BUF_GPIO=133
#BT_EN_GPIO=68
BT_EN_RFKILL=0
WIFI_MMC_HOST=30b50000.usdhc

######################################
# /etc/wifi/variscite-wifi-common.sh #
######################################

# Power up WIFI chip
wifi_up()
{
	# WIFI_PWR up
	echo 1 > /sys/class/gpio/gpio${WIFI_PWR_GPIO}/value
	usleep 10000

	# WLAN_EN up
	echo 1 > /sys/class/gpio/gpio${WIFI_EN_GPIO}/value

	# BT_EN up
	#echo 1 > /sys/class/gpio/gpio${BT_EN_GPIO}/value
	echo 1 > /sys/class/rfkill/rfkill${BT_EN_RFKILL}/state

	# BT_BUF up
	echo 0 > /sys/class/gpio/gpio${BT_BUF_GPIO}/value
	
	# Wait 150ms at least
	usleep 200000
	
	# BT_BUF down
	echo 1 > /sys/class/gpio/gpio${BT_BUF_GPIO}/value

	# BT_EN down
	#echo 0 > /sys/class/gpio/gpio${BT_EN_GPIO}/value
	echo 0 > /sys/class/rfkill/rfkill${BT_EN_RFKILL}/state
	
	# Bind WIFI device to MMC controller
	echo ${WIFI_MMC_HOST} > /sys/bus/platform/drivers/sdhci-esdhc-imx/bind
	
	# Load WIFI driver
	modprobe -d /vendor/lib/modules brcmfmac p2pon=1

	# Load Ethernet driver
	modprobe -d /vendor/lib/modules fec

	# BT_BUF up
	echo 0 > /sys/class/gpio/gpio${BT_BUF_GPIO}/value
}

# Power down WIFI chip
wifi_down()
{
	# Unload WIFI driver
	modprobe -d /vendor/lib/modules -r brcmfmac

	# Unload Ethernet driver
	modprobe -d /vendor/lib/modules -r fec

	# Unbind WIFI device from MMC controller
	echo ${WIFI_MMC_HOST} > /sys/bus/platform/drivers/sdhci-esdhc-imx/unbind

	# WLAN_EN down
	echo 0 > /sys/class/gpio/gpio${WIFI_EN_GPIO}/value

	# BT_BUF down
	echo 1 > /sys/class/gpio/gpio${BT_BUF_GPIO}/value

	# BT_EN down
	#echo 0 > /sys/class/gpio/gpio${BT_EN_GPIO}/value
	echo 0 > /sys/class/rfkill/rfkill${BT_EN_RFKILL}/state

	usleep 10000

	# WIFI power down
	echo 0 > /sys/class/gpio/gpio${WIFI_PWR_GPIO}/value
}

##################
# variscite-wifi #
##################

WIFI_SLEEP=5

wifi_setup()
{
	if [ ! -f /sys/class/gpio/gpio${WIFI_VSEL_GPIO}/direction ]; then
		echo ${WIFI_VSEL_GPIO} > /sys/class/gpio/export
		echo out > /sys/class/gpio/gpio${WIFI_VSEL_GPIO}/direction
	fi

	if [ ! -f /sys/class/gpio/gpio${WIFI_PWR_GPIO}/direction ]; then
		echo ${WIFI_PWR_GPIO} > /sys/class/gpio/export
		echo out > /sys/class/gpio/gpio${WIFI_PWR_GPIO}/direction
	fi

	if [ ! -f /sys/class/gpio/gpio${WIFI_EN_GPIO}/direction ]; then
		echo ${WIFI_EN_GPIO} > /sys/class/gpio/export
		echo out > /sys/class/gpio/gpio${WIFI_EN_GPIO}/direction
	fi

	if [ ! -f /sys/class/gpio/gpio${BT_BUF_GPIO}/direction ]; then
		echo ${BT_BUF_GPIO} > /sys/class/gpio/export
		echo out > /sys/class/gpio/gpio${BT_BUF_GPIO}/direction
	fi

	#if [ ! -f /sys/class/gpio/gpio${BT_EN_GPIO}/direction ]; then
	#	echo ${BT_EN_GPIO} > /sys/class/gpio/export
	#	echo out > /sys/class/gpio/gpio${BT_EN_GPIO}/direction
	#fi

	# WIFI_VSEL up
	echo 1 > /sys/class/gpio/gpio${WIFI_VSEL_GPIO}/value
	usleep 10000

	modprobe -d /vendor/lib/modules  brcmutil.ko
}

wifi_is_up()
{
	for i in `seq 1 20`; do
		[ -d /sys/class/net/wlan0 ] && return 0
		sleep 1
	done

	return 1
}

#################################################
#              Execution starts here            #
#################################################

# Exit if booting without wifi on DART-IMX8M
if ! grep -q WIFI /sys/devices/soc0/machine ; then
	echo "booting without BT/WIFI"
	# Load Ethernet driver and exit
	modprobe -d /vendor/lib/modules fec

	# set property even if there is no insmod config
	# as property value "1" is expected in early-boot trigger
	setprop sys.brcm.wifibt.completed 1
	setprop wlan.driver.status unloaded

	exit 0
fi

# Run initial setup sequence
wifi_setup

for i in `seq 1 3`; do

	# Down WIFI
	wifi_down

	# Wait enough time for discharge
	sleep ${WIFI_SLEEP}

	# Up WIFI
	wifi_up

	# Check that WIFI interface is up
	if wifi_is_up; then
		echo "WIFI startup success"

		# a property value "1" is expected in early-boot trigger
		setprop sys.brcm.wifibt.completed 1
		setprop wlan.driver.status ok

		exit 0
	fi
done

echo "WIFI startup failed"

# set property even if there is no insmod config
# as property value "1" is expected in early-boot trigger
setprop sys.brcm.wifibt.completed 1
setprop wlan.driver.status unloaded

exit 1
