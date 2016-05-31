#
# Copyright 2015 The Android Open Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

bcmdhd_firmware_mk := device/variscite/vardart6ul/bcm4343/bcm_4343w_fw/

ifeq ($(bcmdhd_firmware_mk), $(wildcard $(bcmdhd_firmware_mk)))
firmware_dst_folder = system/vendor/firmware/bcm4343

SRC_FILES := bcmdhd.cal fw_bcmdhd.bin fw_bcmdhd_apsta.bin
COPY_FILES += \
  $(join $(patsubst %, $(bcmdhd_firmware_mk)/%, $(SRC_FILES)), $(patsubst %, :$(firmware_dst_folder)/%, $(SRC_FILES)))
PRODUCT_COPY_FILES += $(COPY_FILES)
else
  $(warning "Not found bcm4343 wifi firmware.")
endif

