How to use the Variscite SD card creation script:
=================================================

This utility is provided on an "AS IS" basis.
This is the script we use to create our recovery SD card with Android images.
For machines with Android support, it is a part of a larger script we use to create our recovery SD card, which also includes Android.
It is a good example for using the output of the Yocto build to create a bootable SD card, and use it to flash the target NAND flash/eMMC.

Note:
Before running this script you need to bitbake fsl-image-gui.
Run below commands to create symbolic link from yocto to Android scripts
- Assuming your yocto and android is built under following paths
Yocto Base DIR : ~/var-fsl-yocto
Android Base DIR : ~/var_imx-android-10.0.0_2.5.0
$ export YOCTO_BSP_BUILD=~/var-fsl-yocto
$ export ANDROID_BSP_BUILD=~/var_imx-android-10.0.0_2.5.0/android_build/
$ ln -sf ${ANDROID_BSP_BUILD}/device/variscite/scripts/sh/var_mk_yocto_sdcard/var-create-yocto-sdcard-with-android.sh \
 ${YOCTO_BSP_BUILD}/sources/meta-variscite-imx/scripts/var_mk_yocto_sdcard/var-create-yocto-sdcard-with-android.sh
$ ln -sf ${ANDROID_BSP_BUILD}/device/variscite/scripts/sh/var_mk_yocto_sdcard/variscite_scripts/mx8_install_android.sh \
 ${YOCTO_BSP_BUILD}/sources/meta-variscite-imx/scripts/var_mk_yocto_sdcard/variscite_scripts/mx8_install_android.sh

$ cd ${YOCTO_BSP_BUILD}

For creating SDcard with only Yocto:
=================================
Usage:
sudo MACHINE=<imx6ul-var-dart|imx8mq-var-dart|imx8mm-var-dart|imx8qxp-var-som|imx8qm-var-som|imx8mn-var-som|imx8mp-var-dart> sources/meta-variscite-imx/scripts/var_mk_yocto_sdcard/var-create-yocto-sdcard.sh [options] /dev/sdX
(Change /dev/sdX to your device name)

options:
  -h            Display help message
  -s            Only show partition sizes to be written, without actually write them
  -a            Automatically set the rootfs partition size to fill the SD card
  -r            Select alternative rootfs for recovery images (default: build_x11/tmp/deploy/images/var-som-mx6/fsl-image-gui-var-som-mx6.*)

If you don't use the '-a' option, a default rootfs size of 3700MiB will be used.
The '-r' option allows you to create a bootable sdcard with an alternative image for the installation to NAND flash or eMMC.
Example: "-r tmp/deploy/images/var-som-mx6/fsl-image-qt5-var-som-mx6" -- selects the "Qt5 image with X11" recovery image


Once the script is done, use the SD card to boot, and then to flash your internal storage/s either use the icons,
or the following linux shell script:
install_yocto.sh

For creating SDcard with Yocto + Android:
=========================================
Usage:
sudo MACHINE=<imx6ul-var-dart|imx8mq-var-dart|imx8mm-var-dart|imx8qxp-var-som|imx8qm-var-som|imx8mn-var-som|imx8mp-var-dart> sources/meta-variscite-imx/scripts/var_mk_yocto_sdcard/var-create-yocto-sdcard-with-android.sh [options] /dev/sdX
(Change /dev/sdX to your device name)

options:
  -h            Display help message
  -s            Only show partition sizes to be written, without actually write them
  -a            Automatically set the rootfs partition size to fill the SD card
  -r            Select alternative rootfs for recovery images (default: build_x11/tmp/deploy/images/var-som-mx6/fsl-image-gui-var-som-mx6.*)

If you don't use the '-a' option, a default rootfs size of 3700MiB will be used.
The '-r' option allows you to create a bootable sdcard with an alternative image for the installation to NAND flash or eMMC.
Example: "-r tmp/deploy/images/var-som-mx6/fsl-image-qt5-var-som-mx6" -- selects the "Qt5 image with X11" recovery image


Once the script is done, use the SD card to boot, and then to flash your internal storage/s either use the icons(imx6/imx7),
or the following linux shell script:
install_android.sh
