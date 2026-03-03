#!/bin/bash
# Meant to compile and build SCFW binary

set -e

readonly PRE_BUILTS_GCC_PATH=${ANDROID_BUILD_TOP}/prebuilts/gcc/linux-x86/aarch64
readonly SCFW_PATH=${PRE_BUILTS_GCC_PATH}/imx-sc-firmware/src
readonly SCFW_BIN_DIR=${ANDROID_BUILD_TOP}/device/variscite/imx8q/som_mx8q/uboot-firmware
TARGET=${1}

if [[ ${TARGET} == "som_mx8qx" ]]; then
	SC_MX8_FAMILY="qx"
elif [[ ${TARGET} == "som_mx8qm" ]]; then
	SC_MX8_FAMILY="qm"
else
	echo "ERROR: scfw_build.sh: unsupported target ${TARGET}"
	exit 1
fi

SCFW_BIN_FILE=${SCFW_BIN_DIR}/mx8${SC_MX8_FAMILY}-var-som-scfw-tcm.bin

if [[ ! -f ${SCFW_BIN_FILE} ]] ; then
	cd ${SCFW_PATH}/scfw_export_mx8${SC_MX8_FAMILY}_b0
	export TOOLS=${PRE_BUILTS_GCC_PATH}
	make clean-${SC_MX8_FAMILY}
	make ${SC_MX8_FAMILY} R=B0 B=var_som V=1
	cp ${SCFW_PATH}/scfw_export_mx8${SC_MX8_FAMILY}_b0/build_mx8${SC_MX8_FAMILY}_b0/scfw_tcm.bin ${SCFW_BIN_FILE}
	cd -
fi
