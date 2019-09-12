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

#ifndef _BDROID_BUILDCFG_H
#define _BDROID_BUILDCFG_H
//#warning
#define BTM_DEF_LOCAL_NAME "Variscite VAR-SOM-MX6"

/* actually kernel support it, but rtc irq pin is not connected */
#define KERNEL_MISSING_CLOCK_BOOTTIME_ALARM TRUE

// Wide-band speech support
#define BTM_WBS_INCLUDED TRUE
#define BTIF_HF_WBS_PREFERRED TRUE

// Enable A2dp Sink
#define BTA_AV_SINK_INCLUDED TRUE

#endif
