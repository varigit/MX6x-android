/*
 * Copyright (C) 2012 The Android Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

/* Copyright (C) 2015-2016 Freescale Semiconductor, Inc. */
/* Copyright (C) 2018 Variscite Ltd */

#ifndef _BDROID_BUILDCFG_H
#define _BDROID_BUILDCFG_H

#define BTM_DEF_LOCAL_NAME "DART-MX8M"

#define KERNEL_MISSING_CLOCK_BOOTTIME_ALARM TRUE

// Networking, Capturing, Object Transfer
// MAJOR CLASS: COMPUTER
// MINOR CLASS: PALM SIZE PC/PDA
#define BTA_DM_COD {0x1A, 0x01, 0x14}

#define BTIF_HF_SERVICES (BTA_HSP_SERVICE_MASK)
#define BTIF_HF_SERVICE_NAMES  { BTIF_HSAG_SERVICE_NAME, NULL }
#define BTM_WBS_INCLUDED TRUE
#define BTIF_HF_WBS_PREFERRED TRUE

/*Enable A2dp Sink */
#define BTA_AV_SINK_INCLUDED TRUE
#define USE_AUDIO_TRACK TRUE

#define BLE_PRIVACY_SPT TRUE
#define BLE_VND_INCLUDED TRUE

#endif
