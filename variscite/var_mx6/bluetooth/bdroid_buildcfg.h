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

/* Copyright (C) 2015 Freescale Semiconductor, Inc. */

#ifndef _BDROID_BUILDCFG_H
#define _BDROID_BUILDCFG_H

#define BTM_DEF_LOCAL_NAME "VAR-MX6"

/* Default class of device
* {SERVICE_CLASS, MAJOR_CLASS, MINOR_CLASS}
*
* SERVICE_CLASS:0x5A (Bit17 -Networking,Bit19 - Capturing,Bit20 -Object Transfer,Bit22 -Telephony)
* MAJOR_CLASS:0x02 - PHONE
* MINOR_CLASS:0x0C - SMART_PHONE
*
* Networking, Capturing, Object Transfer
* MAJOR CLASS: COMPUTER
* MINOR CLASS: PALM SIZE PC/PDA
*/
#define BTA_DM_COD {0x1A, 0x01, 0x14}

#define BTIF_HF_SERVICES (BTA_HSP_SERVICE_MASK)
#define BTIF_HF_SERVICE_NAMES  { BTIF_HSAG_SERVICE_NAME }
#if 1
#define PAN_NAP_DISABLED TRUE
#define BLE_INCLUDED TRUE
#define BTA_GATT_INCLUDED TRUE
#define SMP_INCLUDED TRUE
#else
#define BTM_WBS_INCLUDED TRUE
#define BTIF_HF_WBS_PREFERRED TRUE

/*Enable A2dp Sink */
#define BTA_AV_SINK_INCLUDED TRUE

#define BLE_PRIVACY_SPT TRUE
#define BLE_VND_INCLUDED TRUE
#endif

#endif
