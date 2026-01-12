#!/usr/bin/env bash
set -e

usage() {
  cat <<'EOF'
var-create-release-package.sh - Build and stage Android artifacts

USAGE:
  MACHINE=<machine> ./var-create-release-package.sh --target iw91x|lwb|both [--variant userdebug|user] [--jobs N]
  ./var-create-release-package.sh --help

REQUIRED:
  MACHINE must be one of:
    imx8mq-var-dart
    imx8mm-var-dart
    imx8qxp-var-som
    imx8qxpb0-var-som
    imx8qm-var-som
    imx8mn-var-som
    imx8mp-var-dart

TARGET:
  --target iw91x   Build only iw91x -> android-artifacts/android/              (DEFAULT)
  --target lwb       Build only LWB     -> android-artifacts/android/ (when used alone)
                                          or -> android-artifacts/android/lwb/ (when used with 'both')
  --target both      Build both

OPTIONS:
  --variant V   userdebug|user (iw91x: userdebug)
  --jobs N      Parallel jobs for imx-make.sh (iw91x: 8)

EXAMPLES:
  MACHINE=imx8mp-var-dart ./var-create-release-package.sh --target both --jobs 16
  MACHINE=imx8mp-var-dart ./var-create-release-package.sh --target lwb
  MACHINE=imx8mp-var-dart ./var-create-release-package.sh --target iw91x
EOF
}

TARGET="iw91x"     # iw91x|lwb|both
VARIANT="userdebug"
JOBS="8"

while [ $# -gt 0 ]; do
  case "$1" in
    --target) TARGET="$2"; shift 2 ;;
    --variant) VARIANT="$2"; shift 2 ;;
    --jobs) JOBS="$2"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "ERROR: unknown arg: $1"; usage; exit 1 ;;
  esac
done

[ -n "${MACHINE:-}" ] || { echo "ERROR: MACHINE is required"; usage; exit 1; }

case "${VARIANT}" in userdebug|user) ;; *) echo "ERROR: invalid --variant '${VARIANT}'"; exit 1 ;; esac
case "${TARGET}" in iw91x|lwb|both) ;; *) echo "ERROR: invalid --target '${TARGET}'"; exit 1 ;; esac

ANDROID_BUILD_ROOT="${ANDROID_BUILD_ROOT:-$(pwd)}"

SCRIPT_DIR="$(cd -- "$(dirname -- "$0")" && pwd)"
ART_ROOT="${SCRIPT_DIR}/android-artifacts"
ART_ANDROID_DEFAULT="${ART_ROOT}/android"
ART_ANDROID_LWB="${ART_ROOT}/android/lwb"
ART_SCRIPTS="${ART_ROOT}/scripts"

if [ "${TARGET}" = "lwb" ]; then
  LWB_DEST="${ART_ANDROID_DEFAULT}"
else
  LWB_DEST="${ART_ANDROID_LWB}"
fi

INSTALL_SCRIPT_DIR="${SCRIPT_DIR}/var_mk_yocto_sdcard/variscite_scripts/"

PRODUCT=""
case "$MACHINE" in
  imx8mq-var-dart) PRODUCT="dart_mx8mq" ;;
  imx8mp-var-dart) PRODUCT="dart_mx8mp" ;;
  imx8mm-var-dart) PRODUCT="dart_mx8mm" ;;
  imx8qxp-var-som|imx8qxpb0-var-som|imx8qm-var-som) PRODUCT="som_mx8q" ;;
  imx8mn-var-som) PRODUCT="som_mx8mn" ;;
  *) echo "ERROR: unsupported MACHINE: $MACHINE"; usage; exit 1 ;;
esac

OUTDIR="${ANDROID_BUILD_ROOT}/out/target/product/${PRODUCT}"
LUNCH_TARGET="${PRODUCT}-var_stable-${VARIANT}"
MAKE="${ANDROID_BUILD_ROOT}/imx-make.sh"

copy_glob() {
  src_glob="$1"
  dst_dir="$2"
  ( shopt -s nullglob
    matches=( $src_glob )
    if [ ${#matches[@]} -eq 0 ]; then
      echo "WARN: no matches for: $src_glob"
      return 0
    fi
    mkdir -p "$dst_dir"
    cp -a "${matches[@]}" "$dst_dir/"
  )
}

copy_file() {
  src="$1"
  dst_dir="$2"
  dst_file_name="$3"   # opcional

  if [ -e "$src" ]; then
    mkdir -p "$dst_dir"

    if [ -n "$dst_file_name" ]; then
      cp -a "$src" "$dst_dir/$dst_file_name"
    else
      cp -a "$src" "$dst_dir/"
    fi
  else
    echo "WARN: missing: $src"
  fi
}

clean_product_outdir() {
  echo "Cleaning product outdir: ${OUTDIR}"
  rm -rf "${OUTDIR}"
}

run_build() {
  label="$1"
  extra_env="$2"

  echo "=== BUILD ${MACHINE} ${label} : lunch ${LUNCH_TARGET} jobs=${JOBS} env='${extra_env}' ==="

  [ -f "${ANDROID_BUILD_ROOT}/build/envsetup.sh" ] || { echo "ERROR: build/envsetup.sh not found under ANDROID_BUILD_ROOT"; exit 1; }
  [ -x "${MAKE}" ] || { echo "ERROR: imx-make.sh not found/executable at: ${MAKE}"; exit 1; }

  clean_product_outdir

  (
    cd "${ANDROID_BUILD_ROOT}"
    # shellcheck disable=SC1091
    source build/envsetup.sh
    lunch "${LUNCH_TARGET}"

    if [ -n "${extra_env}" ]; then
      env ${extra_env} ./imx-make.sh -j"${JOBS}"
    else
      ./imx-make.sh -j"${JOBS}"
    fi
  )
}

copy_artifacts_for_machine() {
  dest="$1"
  echo "=== COPY ${MACHINE} -> ${dest} ==="

  [ -d "${OUTDIR}" ] || { echo "ERROR: output dir not found: ${OUTDIR}"; exit 1; }

  copy_file "${OUTDIR}/spl-${MACHINE}-dual.bin"               "${dest}"
  copy_file "${OUTDIR}/bootloader-${MACHINE}-dual.img"        "${dest}"
  copy_file "${OUTDIR}/boot.img"                              "${dest}"
  copy_file "${OUTDIR}/init_boot.img"                         "${dest}"
  copy_glob "${OUTDIR}/dtbo-*.img"                            "${dest}"
  copy_glob "${OUTDIR}/vbmeta-*.img"                          "${dest}"

  if [ "${MACHINE}" = "imx8qm-var-som" ]; then
    copy_file "${OUTDIR}/vendor/firmware/hdmitxfw.bin"        "${dest}"
    copy_file "${OUTDIR}/vendor/firmware/dpfw.bin"            "${dest}"
  fi

  if [ -e "${OUTDIR}/super.img" ]; then
    copy_file "${OUTDIR}/super.img"                           "${dest}"
  else
    copy_file "${OUTDIR}/system.img"                          "${dest}"
    copy_file "${OUTDIR}/vendor.img"                          "${dest}"
    copy_file "${OUTDIR}/product.img"                         "${dest}"
  fi

  copy_file "${OUTDIR}/vendor_boot.img"                       "${dest}"

  if [ "${MACHINE}" = "imx8mm-var-dart" ]; then
    copy_file "${ANDROID_BUILD_ROOT}/device/variscite/imx8m/dart_mx8mm/cm_hello_world.bin.debug" "${dest}" "cm_hello_world.bin.debug"
    copy_file "${ANDROID_BUILD_ROOT}/device/variscite/imx8m/dart_mx8mm/cm_rpmsg_lite_pingpong_rtos_linux_remote.bin.debug" "${dest}" "cm_rpmsg_lite_pingpong_rtos_linux_remote.bin"
    copy_file "${ANDROID_BUILD_ROOT}/device/variscite/imx8m/dart_mx8mm/cm_rpmsg_lite_str_echo_rtos_imxcm4.bin.debug" "${dest}" "cm_rpmsg_lite_str_echo_rtos_imxcm4.bin"
  elif [ "${MACHINE}" = "imx8mn-var-som" ]; then
    copy_file "${ANDROID_BUILD_ROOT}/device/variscite/imx8m/som_mx8mn/cm_hello_world.bin.debug" "${dest}" "cm_hello_world.bin"
    copy_file "${ANDROID_BUILD_ROOT}/device/variscite/imx8m/som_mx8mn/cm_rpmsg_lite_pingpong_rtos_linux_remote.bin.debug" "${dest}" "cm_rpmsg_lite_pingpong_rtos_linux_remote.bin"
    copy_file "${ANDROID_BUILD_ROOT}/device/variscite/imx8m/som_mx8mn/cm_rpmsg_lite_str_echo_rtos.bin.debug" "${dest}" "cm_rpmsg_lite_str_echo_rtos.bin"
  elif [ "${MACHINE}" = "imx8mp-var-dart" ]; then
      copy_file "${ANDROID_BUILD_ROOT}/device/variscite/imx8m/dart_mx8mp/cm_hello_world.bin.debug_som" "${dest}"
      copy_file "${ANDROID_BUILD_ROOT}/device/variscite/imx8m/dart_mx8mp/cm_rpmsg_lite_pingpong_rtos_linux_remote.bin.debug_som" "${dest}"
      copy_file "${ANDROID_BUILD_ROOT}/device/variscite/imx8m/dart_mx8mp/cm_rpmsg_lite_str_echo_rtos.bin.debug_som" "${dest}"
      copy_file "${ANDROID_BUILD_ROOT}/device/variscite/imx8m/dart_mx8mp/cm_hello_world.bin.debug_dart" "${dest}"
      copy_file "${ANDROID_BUILD_ROOT}/device/variscite/imx8m/dart_mx8mp/cm_rpmsg_lite_pingpong_rtos_linux_remote.bin.debug_dart" "${dest}"
      copy_file "${ANDROID_BUILD_ROOT}/device/variscite/imx8m/dart_mx8mp/cm_rpmsg_lite_str_echo_rtos.bin.debug_dart" "${dest}"
  fi
  copy_glob "${ANDROID_BUILD_ROOT}/device/variscite/scripts/uuu_scripts/*.lst" "${dest}"
}

copy_scripts() {
  mkdir -p "${ART_SCRIPTS}"

  shopt -s nullglob
  script_files=("${INSTALL_SCRIPT_DIR}"/*.sh)
  shopt -u nullglob

  if [ ${#script_files[@]} -eq 0 ]; then
    echo "WARN: No .sh scripts found in ${SCRIPT_DIR}"
    return
  fi

  cp -a "${script_files[@]}" "${ART_SCRIPTS}/"

  echo "Copied scripts to ${ART_SCRIPTS}:"
  for script in "${script_files[@]}"; do
    echo "  - $(basename "$script")"
  done
}

create_tar_zst() {
  local src_dir="${ART_ROOT:-}"
  [ -n "${src_dir}" ] || { echo "ERROR: ART_ROOT is not set"; return 1; }
  [ -d "${src_dir}" ] || { echo "ERROR: directory not found: ${src_dir}"; return 1; }

  command -v zstd >/dev/null 2>&1 || { echo "ERROR: zstd not found in PATH"; return 1; }
  command -v tar  >/dev/null 2>&1 || { echo "ERROR: tar not found in PATH"; return 1; }

  local parent base out_file level threads
  parent="$(dirname -- "${src_dir}")"
  base="$(basename -- "${src_dir}")"

  out_file="${1:-${parent}/${base}.tar.zst}"
  level="${ZSTD_LEVEL:-19}"
  threads="${ZSTD_THREADS:-0}"

  rm -f "${out_file}"

  echo "Creating: ${out_file}"
  echo "From     : ${src_dir}"

  tar -C "${parent}" -cf - "${base}" \
    | zstd -"${level}" -T"${threads}" -o "${out_file}"
}

if [ -d "${ART_ROOT}" ]; then
  rm -r "${ART_ROOT}"
  echo "Cleaning ${ART_ROOT}"
fi

mkdir -p "${ART_ROOT}" "${ART_SCRIPTS}"
[ "${TARGET}" = "iw91x" ] || [ "${TARGET}" = "both" ] && mkdir -p "${ART_ANDROID_DEFAULT}"
[ "${TARGET}" = "both" ] && mkdir -p "${ART_ANDROID_LWB}"

if [ "${TARGET}" = "iw91x" ] || [ "${TARGET}" = "both" ]; then
  run_build "iw91x" ""
  copy_artifacts_for_machine "${ART_ANDROID_DEFAULT}"
fi

if [ "${TARGET}" = "lwb" ] || [ "${TARGET}" = "both" ]; then
  run_build "lwb" "TARGET_BCM_WIFI=true"
  copy_artifacts_for_machine "${LWB_DEST}"
fi

copy_scripts
create_tar_zst

echo "Done."
echo "Artifacts root: ${ART_ROOT}"
echo "Compressed archive created at: ${ART_ROOT}.tar.zst"
