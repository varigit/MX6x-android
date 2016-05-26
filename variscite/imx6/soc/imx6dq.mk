#
# SoC-specific compile-time definitions.
#

BOARD_SOC_TYPE := IMX6DQ
BOARD_HAVE_VPU := true
HAVE_FSL_IMX_GPU2D := true
HAVE_FSL_IMX_GPU3D := true
HAVE_FSL_IMX_IPU := true
BOARD_KERNEL_BASE := 0x14000000
LOAD_KERNEL_ENTRY := 0x10008000
TARGET_KERNEL_DEFCONF := imx_v7_var_android_defconfig
-include external/fsl_vpu_omx/codec_env.mk
-include external/fsl_imx_omx/codec_env.mk
TARGET_HAVE_IMX_GRALLOC := true
TARGET_HAVE_IMX_HWCOMPOSER = true
TARGET_HAVE_VIV_HWCOMPOSER = true
MAX_VIRTUAL_DISPLAY_DIMENSION_W = 1280
MAX_VIRTUAL_DISPLAY_DIMENSION_H = 720
USE_OPENGL_RENDERER := true
TARGET_CPU_SMP := true

