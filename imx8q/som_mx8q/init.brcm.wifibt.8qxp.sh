#!/vendor/bin/sh

#################################
# /etc/wifi/variscite-wifi.conf #
#################################

WIFI_3V3_GPIO=112
WIFI_1V8_GPIO=109
WIFI_EN_GPIO=105
BT_BUF_GPIO=61
#BT_EN_GPIO=106
BT_EN_RFKILL=0
WIFI_MMC_HOST=5b020000.usdhc

######################################
# /etc/wifi/variscite-wifi-common.sh #
######################################

# Setup WIFI control GPIOs
wifi_pre_up()
{
	if [ ! -d /sys/class/gpio/gpio${WIFI_3V3_GPIO} ]; then
		echo ${WIFI_3V3_GPIO} > /sys/class/gpio/export
		echo out > /sys/class/gpio/gpio${WIFI_3V3_GPIO}/direction
	fi

	if [ ! -d /sys/class/gpio/gpio${WIFI_1V8_GPIO} ]; then
		echo ${WIFI_1V8_GPIO} > /sys/class/gpio/export
		echo out > /sys/class/gpio/gpio${WIFI_1V8_GPIO}/direction
	fi

	if [ ! -d /sys/class/gpio/gpio${WIFI_EN_GPIO} ]; then
		echo ${WIFI_EN_GPIO} > /sys/class/gpio/export
		echo out > /sys/class/gpio/gpio${WIFI_EN_GPIO}/direction
	fi

	if [ ! -d /sys/class/gpio/gpio${BT_BUF_GPIO} ]; then
		echo ${BT_BUF_GPIO} > /sys/class/gpio/export
		echo out > /sys/class/gpio/gpio${BT_BUF_GPIO}/direction
	fi

	#if [ ! -d /sys/class/gpio/gpio${BT_EN_GPIO} ]; then
	#	echo ${BT_EN_GPIO} > /sys/class/gpio/export
	#	echo out > /sys/class/gpio/gpio${BT_EN_GPIO}/direction
	#fi
}

# Power up WIFI chip
wifi_up()
{
	# Unbind WIFI device from MMC controller
	if [ -e /sys/bus/platform/drivers/sdhci-esdhc-imx/${WIFI_MMC_HOST} ]; then
		echo ${WIFI_MMC_HOST} > /sys/bus/platform/drivers/sdhci-esdhc-imx/unbind
	fi

	# WIFI_3V3 up
	echo 1 > /sys/class/gpio/gpio${WIFI_3V3_GPIO}/value
	usleep 10000

	# WIFI_1V8 up
	echo 0 > /sys/class/gpio/gpio${WIFI_1V8_GPIO}/value
	usleep 10000

	# WLAN_EN up
	echo 1 > /sys/class/gpio/gpio${WIFI_EN_GPIO}/value

	# BT_EN up
	#echo 1 > /sys/class/gpio/gpio${BT_EN_GPIO}/value
	echo 1 > /sys/class/rfkill/rfkill${BT_EN_RFKILL}/state

	# BT_BUF up
	echo 0 > /sys/class/gpio/gpio${BT_BUF_GPIO}/value
	
	# Wait at least 150ms
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
}

# Power down WIFI chip
wifi_down()
{
	# Unload WIFI driver
	modprobe -d /vendor/lib/modules -r brcmfmac

	# Unbind WIFI device from MMC controller
	if [ -e /sys/bus/platform/drivers/sdhci-esdhc-imx/${WIFI_MMC_HOST} ]; then
		echo ${WIFI_MMC_HOST} > /sys/bus/platform/drivers/sdhci-esdhc-imx/unbind
	fi

	# WIFI_EN down
	echo 0 > /sys/class/gpio/gpio${WIFI_EN_GPIO}/value

	# BT_BUF down
	echo 1 > /sys/class/gpio/gpio${BT_BUF_GPIO}/value

	# BT_EN down
	#echo 0 > /sys/class/gpio/gpio${BT_EN_GPIO}/value
	echo 0 > /sys/class/rfkill/rfkill${BT_EN_RFKILL}/state

	usleep 10000

	# WIFI_1V8 down
	echo 1 > /sys/class/gpio/gpio${WIFI_1V8_GPIO}/value

	# WIFI_3V3 down
	echo 0 > /sys/class/gpio/gpio${WIFI_3V3_GPIO}/value
}

# Return true if SOM has WIFI module assembled
wifi_is_available()
{
	# Read SOM options EEPROM field
	opt=$(i2cget -f -y 0x0 0x52 0x20)

	# Check WIFI bit in SOM options
	if [ $((opt & 0x1)) -eq 1 ]; then
		return 0
	else
		return 1
	fi
}

# Return true if WIFI should not be started
wifi_should_not_be_started()
{
	# Do not enable WIFI if it's not available
	if ! wifi_is_available; then
		return 0
	fi

	# Do not enable WIFI if it is already up
	[ -d /sys/class/net/wlan0 ] && return 0

	# Do not enable WIFI if booting from eMMC without WIFI
	if ! grep -q WIFI /sys/devices/soc0/machine; then
		return 0
	fi

	return 1
}

# Return true if WIFI should not be stopped
wifi_should_not_be_stopped()
{
	# Do not stop WIFI if it's not available
	if ! wifi_is_available; then
		return 0
	fi

	# Do not stop WIFI if booting from eMMC without WIFI
	if ! grep -q WIFI /sys/devices/soc0/machine; then
		return 0
	fi

	return 1
}

##################
# variscite-wifi #
##################

# Return true if WIFI interface exists
wifi_interface_exists()
{
	for i in $(seq 1 20); do
		[ -d /sys/class/net/wlan0 ] && return 0
		sleep 1
	done

	return 1
}

# Start WIFI hardware
wifi_start()
{
	# Exit if WIFI should not be started
	wifi_should_not_be_started && return 0

	# Setup WIFI control GPIOs
	wifi_pre_up

	# Try starting WIFI hardware
	for i in $(seq 1 3); do
		# Up WIFI
		wifi_up

		# Exit if WIFI interface exists
		wifi_interface_exists && return 0

		# Down WIFI
		wifi_down

		# Wait enough time for discharge
		sleep 5
	done

	return 1
}

# Stop WIFI hardware
# Note that on DART-MX8M this also stops Ethernet
wifi_stop()
{
	# Exit if WIFI should not be stopped
	wifi_should_not_be_stopped && return 0

	wifi_down
}

#################################################
#              Execution starts here            #
#################################################

# always load Ethernet driver
modprobe -d /vendor/lib/modules fec

wifi_start

# BT_BUF up
echo 0 > /sys/class/gpio/gpio${BT_BUF_GPIO}/value

# always set property even if wifi failed
# as property value "1" is expected in early-boot trigger
setprop sys.brcm.wifibt.completed 1

exit 0
