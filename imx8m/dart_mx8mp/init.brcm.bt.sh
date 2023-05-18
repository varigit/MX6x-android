#!/vendor/bin/sh

#################################
# /etc/wifi/variscite-wifi.conf #
#################################

#BT_EN_GPIO=68
BT_EN_RFKILL=0
BT_EN_GPIO=38
BT_EN_GPIO_SOM=41

WIFI_PWR_GPIO=40
WIFI_PWR_GPIO_SOM=51

WIFI_EN_GPIO=39
WIFI_EN_GPIO_SOM=40

BT_BUF_GPIO=41
BT_BUF_GPIO_SOM=4

WIFI_MMC_HOST=30b40000.mmc
WIFI_SDIO_ID_FILE=/sys/bus/mmc/devices/mmc0:0001/mmc0:0001:1/device
WIFI_5G_SDIO_ID=0x4339

# Return true if board is VAR-SOM-MX8M-PLUS
board_is_var_som_mx8m_plus()
{
	grep -q VAR-SOM-MX8M-PLUS /sys/devices/soc0/machine
}

# Configure VAR-SOM-MX8M-PLUS WIFI/BT pins
config_pins()
{
	if board_is_var_som_mx8m_plus; then
		WIFI_PWR_GPIO=${WIFI_PWR_GPIO_SOM}
		WIFI_EN_GPIO=${WIFI_EN_GPIO_SOM}
		BT_BUF_GPIO=${BT_BUF_GPIO_SOM}
		BT_EN_GPIO=${BT_EN_GPIO_SOM}
	fi
}

bt_start()
{
	if [ ! -d /sys/class/gpio/gpio${BT_EN_GPIO} ]; then
		echo ${BT_EN_GPIO} >/sys/class/gpio/export
		echo "out" > /sys/class/gpio/gpio${BT_EN_GPIO}/direction
	fi

	echo 0 > /sys/class/gpio/gpio${BT_EN_GPIO}/value
	sleep 1
	echo 1 > /sys/class/gpio/gpio${BT_EN_GPIO}/value

	if [ ! -d /sys/class/gpio/gpio${BT_BUF_GPIO} ]; then
			echo ${BT_BUF_GPIO} >/sys/class/gpio/export
			echo "out" > /sys/class/gpio/gpio${BT_BUF_GPIO}/direction
	fi
	echo 0 > /sys/class/gpio/gpio${BT_BUF_GPIO}/value
	setprop sys.brcm.bt.completed 1
}


bt_down() {

	if [ ! -d /sys/class/gpio/gpio${BT_BUF_GPIO} ]; then
			echo ${BT_BUF_GPIO} >/sys/class/gpio/export
			echo "out" > /sys/class/gpio/gpio${BT_BUF_GPIO}/direction
	fi
	echo 1 > /sys/class/gpio/gpio${BT_BUF_GPIO}/value
	if [ ! -d /sys/class/gpio/gpio${BT_EN_GPIO} ]; then
		echo ${BT_EN_GPIO} >/sys/class/gpio/export
		echo "out" > /sys/class/gpio/gpio${BT_EN_GPIO}/direction
	fi

	echo 0 > /sys/class/gpio/gpio${BT_EN_GPIO}/value
}
#################################################
#              Execution starts here            #
#################################################

config_pins
bt_start

exit 0
