/*
 * Copyright (C) 2014 The Android Open Source Project
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
#include <errno.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/socket.h>
#include <sys/un.h>
#include <fcntl.h>
#include <dlfcn.h>
#include <inttypes.h>
#include <cutils/uevent.h>
#include <errno.h>
#include <sys/poll.h>
#include <pthread.h>
#include <linux/netlink.h>
#include <stdlib.h>
#include <stdbool.h>

#define LOG_TAG "PowerHAL"
#include <utils/Log.h>

#include <hardware/hardware.h>
#include <hardware/power.h>

#include "power-helper.h"

// Custom Lineage hints
const static power_hint_t POWER_HINT_SET_PROFILE = (power_hint_t)0x00000111;

#define USINSEC 1000000L
#define NSINUS 1000L

#ifndef RPM_STAT
#define RPM_STAT "/d/rpm_stats"
#endif

#ifndef RPM_MASTER_STAT
#define RPM_MASTER_STAT "/d/rpm_master_stats"
#endif

#ifndef RPM_SYSTEM_STAT
#define RPM_SYSTEM_STAT "/d/system_stats"
#endif

/*
   Set with TARGET_WLAN_POWER_STAT in BoardConfig.mk
   Defaults to QCACLD3 path
   Path for QCACLD3: /d/wlan0/power_stats
   Path for QCACLD2 and Prima: /d/wlan_wcnss/power_stats
*/


/* Use these stats on pre-nougat qualcomm kernels */
static const char *rpm_param_names[] = {
    "vlow_count",
    "accumulated_vlow_time",
    "vmin_count",
    "accumulated_vmin_time"
};

static const char *rpm_master_param_names[] = {
    "xo_accumulated_duration",
    "xo_count",
    "xo_accumulated_duration",
    "xo_count",
    "xo_accumulated_duration",
    "xo_count",
    "xo_accumulated_duration",
    "xo_count"
};


#define STATE_ON "state=1"
#define STATE_OFF "state=0"
#define STATE_HDR_ON "state=2"
#define STATE_HDR_OFF "state=3"

#define MAX_LENGTH         50
#define BOOST_SOCKET       "/dev/socket/pb"


#define POWERSAVE_MIN_FREQ 384000
#define POWERSAVE_MAX_FREQ 1026000
#define BIAS_PERF_MIN_FREQ 1134000
#define NORMAL_MAX_FREQ 1512000

#define MAX_FREQ_LIMIT_PATH "/sys/kernel/cpufreq_limit/limited_max_freq"
#define MIN_FREQ_LIMIT_PATH "/sys/kernel/cpufreq_limit/limited_min_freq"


static int client_sockfd;
static struct sockaddr_un client_addr;
static int last_state = -1;

static pthread_mutex_t profile_lock = PTHREAD_MUTEX_INITIALIZER;

enum {
    PROFILE_POWER_SAVE = 0,
    PROFILE_BALANCED,
    PROFILE_HIGH_PERFORMANCE,
    PROFILE_BIAS_POWER,
    PROFILE_BIAS_PERFORMANCE,
    PROFILE_MAX
};

static int current_power_profile = PROFILE_BALANCED;


static void socket_init()
{
    if (!client_sockfd) {
        client_sockfd = socket(PF_UNIX, SOCK_DGRAM, 0);
        if (client_sockfd < 0) {
            ALOGE("%s: failed to open: %s", __func__, strerror(errno));
            return;
        }
        memset(&client_addr, 0, sizeof(struct sockaddr_un));
        client_addr.sun_family = AF_UNIX;
        snprintf(client_addr.sun_path, UNIX_PATH_MAX, BOOST_SOCKET);
    }
}

static int sysfs_write(const char *path, char *s)
{
    char buf[80];
    int len;
    int fd = open(path, O_WRONLY);

    if (fd < 0) {
        strerror_r(errno, buf, sizeof(buf));
        ALOGE("Error opening %s: %s\n", path, buf);
        return -1;
    }

    len = write(fd, s, strlen(s));
    if (len < 0) {
        strerror_r(errno, buf, sizeof(buf));
        ALOGE("Error writing to %s: %s\n", path, buf);
        return -1;
    }

    close(fd);
    return 0;
}

void power_init(void)
{
    ALOGI("%s", __func__);
    socket_init();
    
}


static int sysfs_write_int(char *path, int value)
{
    char buf[80];
    snprintf(buf, 80, "%d", value);
    return sysfs_write(path, buf);
}



static void sync_thread(int off)
{
    int rc;
    pid_t client;
    char data[MAX_LENGTH];

    if (client_sockfd < 0) {
        ALOGE("%s: boost socket not created", __func__);
        return;
    }

    client = getpid();

    if (!off) {
        snprintf(data, MAX_LENGTH, "2:%d", client);
        rc = sendto(client_sockfd, data, strlen(data), 0,
            (const struct sockaddr *)&client_addr, sizeof(struct sockaddr_un));
    } else {
        snprintf(data, MAX_LENGTH, "3:%d", client);
        rc = sendto(client_sockfd, data, strlen(data), 0,
            (const struct sockaddr *)&client_addr, sizeof(struct sockaddr_un));
    }

    if (rc < 0) {
        ALOGE("%s: failed to send: %s", __func__, strerror(errno));
    }
}

static void enc_boost(int off)
{
    int rc;
    pid_t client;
    char data[MAX_LENGTH];

    if (client_sockfd < 0) {
        ALOGE("%s: boost socket not created", __func__);
        return;
    }

    client = getpid();

    if (!off) {
        snprintf(data, MAX_LENGTH, "5:%d", client);
        rc = sendto(client_sockfd, data, strlen(data), 0,
            (const struct sockaddr *)&client_addr, sizeof(struct sockaddr_un));
    } else {
        snprintf(data, MAX_LENGTH, "6:%d", client);
        rc = sendto(client_sockfd, data, strlen(data), 0,
            (const struct sockaddr *)&client_addr, sizeof(struct sockaddr_un));
    }

    if (rc < 0) {
        ALOGE("%s: failed to send: %s", __func__, strerror(errno));
    }
}

static void process_video_encode_hint(void *metadata)
{

    socket_init();

    if (client_sockfd < 0) {
        ALOGE("%s: boost socket not created", __func__);
        return;
    }

    if (metadata) {
        if (!strncmp(metadata, STATE_ON, sizeof(STATE_ON))) {
            /* Video encode started */
            sync_thread(1);
            enc_boost(1);
        } else if (!strncmp(metadata, STATE_OFF, sizeof(STATE_OFF))) {
            /* Video encode stopped */
            sync_thread(0);
            enc_boost(0);
        }  else if (!strncmp(metadata, STATE_HDR_ON, sizeof(STATE_HDR_ON))) {
            /* HDR usecase started */
        } else if (!strncmp(metadata, STATE_HDR_OFF, sizeof(STATE_HDR_OFF))) {
            /* HDR usecase stopped */
        }else
            return;
    } else {
        return;
    }
}


static void touch_boost()
{
    int rc;
    pid_t client;
    char data[MAX_LENGTH];

    if (client_sockfd < 0) {
        ALOGE("%s: boost socket not created", __func__);
        return;
    }

    client = getpid();

    snprintf(data, MAX_LENGTH, "1:%d", client);
    rc = sendto(client_sockfd, data, strlen(data), 0,
        (const struct sockaddr *)&client_addr, sizeof(struct sockaddr_un));
    if (rc < 0) {
        ALOGE("%s: failed to send: %s", __func__, strerror(errno));
    }
}

void power_set_interactive(int on)
{
    if (last_state == -1) {
        last_state = on;
    } else {
        if (last_state == on)
            return;
        else
            last_state = on;
    }

    ALOGV("%s %s", __func__, (on ? "ON" : "OFF"));
    if (on) {
        sync_thread(0);
        touch_boost();
    } else {
        sync_thread(1);
    }
}

static void set_power_profile(int profile) {
    int min_freq = POWERSAVE_MIN_FREQ;
    int max_freq = NORMAL_MAX_FREQ;

    ALOGV("%s: profile=%d", __func__, profile);

    switch (profile) {
    case PROFILE_HIGH_PERFORMANCE:
        min_freq = NORMAL_MAX_FREQ;
        max_freq = NORMAL_MAX_FREQ;
        break;
    case PROFILE_BIAS_PERFORMANCE:
        min_freq = BIAS_PERF_MIN_FREQ;
        max_freq = NORMAL_MAX_FREQ;
        break;
    case PROFILE_BIAS_POWER:
        min_freq = POWERSAVE_MIN_FREQ;
        max_freq = POWERSAVE_MAX_FREQ;
        break;
    case PROFILE_POWER_SAVE:
        min_freq = POWERSAVE_MIN_FREQ;
        max_freq = POWERSAVE_MAX_FREQ;
        break;
    default:
        break;
    }

    sysfs_write_int(MIN_FREQ_LIMIT_PATH, min_freq);
    sysfs_write_int(MAX_FREQ_LIMIT_PATH, max_freq);

    current_power_profile = profile;

    ALOGD("%s: set power profile mode: %d", __func__, current_power_profile);
}

void power_hint(power_hint_t hint, void *data)
{
    
    if (hint == POWER_HINT_SET_PROFILE) {
        pthread_mutex_lock(&profile_lock);
        set_power_profile(*(int32_t *)data);
        pthread_mutex_unlock(&profile_lock);
        return;
    }

    // Skip other hints in powersave mode
    if (current_power_profile == PROFILE_POWER_SAVE)
        return;

    switch (hint) {
        case POWER_HINT_INTERACTION:
        case POWER_HINT_LAUNCH:
            ALOGV("POWER_HINT_INTERACTION");
            touch_boost();
            break;

        case POWER_HINT_VIDEO_ENCODE:
            process_video_encode_hint(data);
            break;

        default:
             break;
    }
}

int get_number_of_profiles()
{
    return PROFILE_MAX;
}

static int extract_stats(uint64_t *list, char *file, const char**param_names,
                         unsigned int num_parameters, int isHex) {
    FILE *fp;
    ssize_t read;
    size_t len;
    size_t index = 0;
    char *line;
    int ret;

    fp = fopen(file, "r");
    if (fp == NULL) {
        ret = -errno;
        ALOGE("%s: failed to open: %s Error = %s", __func__, file, strerror(errno));
        return ret;
    }

    for (line = NULL, len = 0;
         ((read = getline(&line, &len, fp) != -1) && (index < num_parameters));
         free(line), line = NULL, len = 0) {
        uint64_t value;
        char* offset;

        size_t begin = strspn(line, " \t");
        if (strncmp(line + begin, param_names[index], strlen(param_names[index]))) {
            continue;
        }

        offset = memchr(line, ':', len);
        if (!offset) {
            continue;
        }

        if (isHex) {
            sscanf(offset, ":%" SCNx64, &value);
        } else {
            sscanf(offset, ":%" SCNu64, &value);
        }
        list[index] = value;
        index++;
    }

    free(line);
    fclose(fp);

    return 0;
}

int extract_platform_stats(uint64_t *list) {
    int ret;
    //Data is located in two files
    ret = extract_stats(list, RPM_STAT, rpm_param_names, RPM_PARAM_COUNT, false);
    if (ret) {
        for (size_t i=0; i < RPM_PARAM_COUNT; i++)
            list[i] = 0;
    }
    ret = extract_stats(list + RPM_PARAM_COUNT, RPM_MASTER_STAT,
                        rpm_master_param_names, PLATFORM_PARAM_COUNT - RPM_PARAM_COUNT, true);
    if (ret) {
        for (size_t i=RPM_PARAM_COUNT; i < PLATFORM_PARAM_COUNT; i++)
        list[i] = 0;
    }
    return 0;
}

