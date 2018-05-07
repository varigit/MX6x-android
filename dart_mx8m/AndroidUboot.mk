# uboot.imx in android combine scfw.bin and uboot.bin
MAKE += SHELL=/bin/bash

define build_uboot
	cp out/target/product/dart_mx8m/obj/BOOTLOADER_OBJ/u-boot-nodtb.$(strip $(1)) $(IMX_MKIMAGE_PATH)/imx-mkimage/iMX8M/.; \
	cp out/target/product/dart_mx8m/obj/BOOTLOADER_OBJ/spl/u-boot-spl.bin  $(IMX_MKIMAGE_PATH)/imx-mkimage/iMX8M/.; \
	cp out/target/product/dart_mx8m/obj/BOOTLOADER_OBJ/tools/mkimage  $(IMX_MKIMAGE_PATH)/imx-mkimage/iMX8M/mkimage_uboot; \
	cp out/target/product/dart_mx8m/obj/BOOTLOADER_OBJ/arch/arm/dts/imx8m-var-dart.dtb  $(IMX_MKIMAGE_PATH)/imx-mkimage/iMX8M/.; \
	cp $(FSL_PROPRIETARY_PATH)/fsl-proprietary/uboot-firmware/imx8m/signed_hdmi_imx8m.bin  $(IMX_MKIMAGE_PATH)/imx-mkimage/iMX8M/.; \
	cp $(FSL_PROPRIETARY_PATH)/fsl-proprietary/uboot-firmware/imx8m/lpddr4_pmu_train_1d_dmem.bin $(IMX_MKIMAGE_PATH)/imx-mkimage/iMX8M/.; \
	cp $(FSL_PROPRIETARY_PATH)/fsl-proprietary/uboot-firmware/imx8m/lpddr4_pmu_train_1d_imem.bin $(IMX_MKIMAGE_PATH)/imx-mkimage/iMX8M/.; \
	cp $(FSL_PROPRIETARY_PATH)/fsl-proprietary/uboot-firmware/imx8m/lpddr4_pmu_train_2d_dmem.bin $(IMX_MKIMAGE_PATH)/imx-mkimage/iMX8M/.; \
	cp $(FSL_PROPRIETARY_PATH)/fsl-proprietary/uboot-firmware/imx8m/lpddr4_pmu_train_2d_imem.bin $(IMX_MKIMAGE_PATH)/imx-mkimage/iMX8M/.; \
	cp $(FSL_PROPRIETARY_PATH)/fsl-proprietary/uboot-firmware/imx8m/bl31.bin $(IMX_MKIMAGE_PATH)/imx-mkimage/iMX8M/.; \
	$(MAKE) -C $(IMX_MKIMAGE_PATH)/imx-mkimage/ clean; \
	$(MAKE) -C $(IMX_MKIMAGE_PATH)/imx-mkimage/ SOC=iMX8M  flash_hdmi_spl_uboot; \
	cp $(IMX_MKIMAGE_PATH)/imx-mkimage/iMX8M/flash.bin $(PRODUCT_OUT)/u-boot-$(strip $(2)).imx;
endef


