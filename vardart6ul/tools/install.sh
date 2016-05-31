# if needed, carefully change to custom build folder
export BUILD_FOLDER=~/var_brillo_m10_build

echo "Cloning u-boot..."
cd $BUILD_FOLDER
mkdir -p bootable/bootloader
cd bootable/bootloader
git clone https://github.com/varigit/uboot-imx.git -b imx_v2015.04_brillo-var01

echo "Cloning kernel..."
cd $BUILD_FOLDER
mkdir -p hardware/bsp/kernel/variscite
cd hardware/bsp/kernel/variscite
git clone https://github.com/varigit/linux-2.6-imx.git -b imx_3.14.52_brillo-var01 kernel_imx

echo "Fixing gator conflict with original NXP kernel..."
mv $BUILD_FOLDER/hardware/bsp/kernel/variscite/kernel_imx/tools/gator/daemon/Android.mk $BUILD_FOLDER/hardware/bsp/kernel/variscite/kernel_imx/tools/gator/daemon/__Android.mk__

echo "Allow building custom wifi support..."
cd $BUILD_FOLDER/hardware/bsp/freescale
patch -p1 < $BUILD_FOLDER/device/variscite/vardart6ul/tools/patches/hardware_bsp_freescale.patch

echo "Add vardart6ul support to brunch..."
cd $BUILD_FOLDER/tools/bdk
patch -p1 < $BUILD_FOLDER/device/variscite/vardart6ul/tools/patches/tools_bdk.patch

cd $BUILD_FOLDER
