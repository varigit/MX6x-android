#
# SoC-specific compile-time definitions.
#

BOARD_SOC_TYPE := IMX6SX
BOARD_HAVE_VPU := false
HAVE_FSL_IMX_GPU2D := true
HAVE_FSL_IMX_GPU3D := true
HAVE_FSL_IMX_IPU := false
BOARD_KERNEL_BASE := 0x84800000
LOAD_KERNEL_ENTRY := 0x80008000
TARGET_KERNEL_DEFCONF := imx_v7_var_android_defconfig
-include external/fsl_imx_omx/codec_env.mk
TARGET_HAVE_IMX_GRALLOC := true
TARGET_HAVE_IMX_HWCOMPOSER = true
USE_OPENGL_RENDERER := true
TARGET_CPU_SMP := false

