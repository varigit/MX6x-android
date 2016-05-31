/*
 * Copyright (C) 2015 The Android Open Source Project
 * Copyright (C) 2015 Freescale Semiconductor, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include <cutils/log.h>
#include <cutils/misc.h>
#include <cutils/memory.h>
#include <cutils/properties.h>
#include <hardware_brillo/wifi_driver_hal.h>

#include <string>
#include <sys/syscall.h>

#if BCMDHD_USE_KERNEL_MODULE
#define init_module(mod, len, opts) syscall(__NR_init_module, mod, len, opts)
#endif

namespace {

    enum CheckmodResult{
        MOD_INSED,
        NOT_FOUND
    };

const char kCfg80211KoPath[] = "/system/lib/modules/cfg80211.ko";
const char kCfg80211KoName[] = "cfg80211";
const char kBcmdhdDriverPath[] = "/system/lib/modules/bcmdhd.ko";
const char kBcmdhdDriverName[] = "bcmdhd";
const char kBcmdhdApFirmwarePath[] = "/system/vendor/firmware/bcm4343/fw_bcmdhd_apsta.bin";
const char kBcmdhdStaFirmwarePath[] = "/system/vendor/firmware/bcm4343/fw_bcmdhd.bin";
const char kBcmdhdFirmwareConfigPath[] = "/sys/module/bcmdhd/parameters/firmware_path";
const char kBcmdhdNvramConfigPath[] = "/sys/module/bcmdhd/parameters/nvram_path";
const char kBcmdhdNvramPath[] = "/system/vendor/firmware/bcm4343/bcmdhd.cal";
const char kModulesSysfsPath[] = "/proc/modules";

const char kApDeviceName[] = "wlan0";
const char kStationDeviceName[] = "wlan0";


static bool read_file(const std::string& filename, std::string* buffer,
                      size_t buffer_size) {
  int fd = open(filename.c_str(), O_RDONLY);
  if (fd < 0) {
    ALOGE("Cannot open %s for reading", filename.c_str());
    return false;
  }
  char buffer_data[buffer_size];
  ssize_t count = read(fd, buffer_data, buffer_size);
  close(fd);

  if (count <= 0) {
    ALOGE("Cannot read any data from %s", filename.c_str());
    return false;
  }

  buffer->assign(buffer_data, count);
  return true;
}

#if BCMDHD_USE_KERNEL_MODULE
static int checkmod(const char *mod_name) {
    std::string module_path(kModulesSysfsPath);
    std::string module_name(mod_name);
    std::string module_content;
    read_file(module_path, &module_content, 1024);
    if (module_content.find(module_name, 0) == std::string::npos)
        return NOT_FOUND;
    else
        return MOD_INSED;

}
#endif

#if BCMDHD_USE_KERNEL_MODULE
static int insmod(const char *filename, const char *args) {
    void *module;
    unsigned int size;
    int ret;
    module = load_file(filename, &size);
    if (!module) {
        ALOGE("insmod:load_file %s  error", filename);
        return -1;
    }
    ret = init_module(module, size, args);
    free(module);
    return ret;
}
#endif


static bool write_file(
    const std::string& filename, const std::string& content) {
  int fd = open(filename.c_str(), O_WRONLY);
  if (fd < 0) {
    ALOGE("Cannot open %s for writing", filename.c_str());
    return false;
  }
  ssize_t write_count = content.size();
  ssize_t actual_count = write(fd, content.c_str(), write_count);
  close(fd);

  if (actual_count != write_count) {
    ALOGE("Expected to write %d bytes to %s but write returns %d",
          write_count, filename.c_str(), actual_count);
    return false;
  }
  return true;
}



static wifi_driver_error wifi_driver_initialize_bcmdhd() {

    int ret = -1;
    ALOGD("bcmdhd wifi_driver init.");
#if BCMDHD_USE_KERNEL_MODULE
    if (checkmod(kCfg80211KoName) == NOT_FOUND) {
        if (insmod(kCfg80211KoPath, "")) {
            ALOGE("Cannot insmod cfg80211");
            return WIFI_ERROR_UNKNOWN;
        }
    }
    if (checkmod(kBcmdhdDriverName) == NOT_FOUND) {
        if (insmod(kBcmdhdDriverPath, "")) {
            ALOGE("Cannot insmod bcmdhd driver.");
            return WIFI_ERROR_UNKNOWN;
        }
    }
#endif
    return WIFI_SUCCESS;
}

static wifi_driver_error wifi_driver_set_mode_bcmdhd(
    wifi_driver_mode mode,
    char* wifi_device_name,
    size_t wifi_device_name_size) {
  const char* device_name = nullptr;
  ALOGD("Wifi HAL setup mode: %s to %s mode", wifi_device_name, mode==WIFI_MODE_AP? "AP":"STA");
  std::string ap_firmware(kBcmdhdApFirmwarePath);
  std::string sta_firmware(kBcmdhdStaFirmwarePath);
  std::string firmware_config(kBcmdhdFirmwareConfigPath);
  std::string nvram_config(kBcmdhdNvramConfigPath);
  std::string nvram_file(kBcmdhdNvramPath);
  switch (mode) {
    case WIFI_MODE_AP:
      strlcpy(wifi_device_name, kApDeviceName, wifi_device_name_size);
      write_file(firmware_config, ap_firmware);
      break;

    case WIFI_MODE_STATION:
      strlcpy(wifi_device_name, kStationDeviceName, wifi_device_name_size);
      write_file(firmware_config, sta_firmware);
      break;

    default:
      ALOGE("Unkonwn WiFi driver mode %d", mode);
      return WIFI_ERROR_INVALID_ARGS;
  }
  write_file(nvram_config, nvram_file);

  return WIFI_SUCCESS;
}

static int close_bcmdhd_driver(struct hw_device_t* device) {
  wifi_driver_device_t* dev = reinterpret_cast<wifi_driver_device_t*>(device);
  if (dev)
    free(dev);
  return 0;
}

static int open_bcmdhd_driver(const struct hw_module_t* module, const char*,
                       struct hw_device_t** device) {
  wifi_driver_device_t* dev = reinterpret_cast<wifi_driver_device_t*>(
      calloc(1, sizeof(wifi_driver_device_t)));

  dev->common.tag = HARDWARE_DEVICE_TAG;
  dev->common.version = WIFI_DRIVER_DEVICE_API_VERSION_0_1;
  // We're forced into this cast by the existing API.  This pattern is
  // common among users of the HAL.
  dev->common.module = const_cast<hw_module_t*>(module);
  dev->common.close = close_bcmdhd_driver;
  dev->wifi_driver_initialize = wifi_driver_initialize_bcmdhd;
  dev->wifi_driver_set_mode = wifi_driver_set_mode_bcmdhd;

  *device = &dev->common;

  return 0;
}

static struct hw_module_methods_t bcmdhd_driver_module_methods = {
  open: open_bcmdhd_driver
};

}  // namespace {}

hw_module_t HAL_MODULE_INFO_SYM = {
  tag: HARDWARE_MODULE_TAG,
  version_major: 1,
  version_minor: 0,
  id: WIFI_DRIVER_HARDWARE_MODULE_ID,
  name: "BCM4343",
  author: "Freescale",
  methods: &bcmdhd_driver_module_methods,
  dso: NULL,
  reserved: {0},
};
