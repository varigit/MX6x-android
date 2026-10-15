#!/usr/bin/env bash
# Start the Android 16 build container from any working directory.
set -euo pipefail
script_path=$(readlink -f -- "${BASH_SOURCE[0]}")
android_dir=$(cd -- "$(dirname -- "$script_path")/../.." && pwd)
exec "$android_dir/var-docker/run.sh" -u 22.04 -a 16.0.0_2.0.0 -l -w "$android_dir" "$@"
