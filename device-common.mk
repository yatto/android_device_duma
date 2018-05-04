#
# Copyright (C) 2011 The Android Open-Source Project
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

# This file includes all definitions that apply to ALL msm8960 devices, and
# are also specific to msm8960 devices
#
# Everything in this directory will become public

PRODUCT_CHARACTERISTICS := tablet

PRODUCT_AAPT_PREF_CONFIG := xhdpi

PRODUCT_COPY_FILES += \
	device/asus/duma/rootdir/init.duma.usb.rc:root/init.duma.usb.rc \
	device/asus/duma/rootdir/ueventd.duma.rc:root/ueventd.duma.rc

# Wi-Fi & Bluetooth
PRODUCT_PACKAGES := \
	android.hardware.wifi@1.0-service \
	libwpa_client \
	hostapd \
	wificond \
	dhcpcd.conf \
	wpa_supplicant \
	wpa_supplicant.conf

PRODUCT_PACKAGES += \
	bdAddrLoader \
	libwfcu \
	conn_init

PRODUCT_COPY_FILES += \
	device/asus/duma/wifi/WCNSS_cfg.dat:$(TARGET_COPY_OUT_VENDOR)/firmware/wlan/prima/WCNSS_cfg.dat \
	device/asus/duma/wifi/WCNSS_qcom_cfg.ini:$(TARGET_COPY_OUT_VENDOR)/etc/wifi/WCNSS_qcom_cfg.ini \
	device/asus/duma/wifi/WCNSS_qcom_wlan_nv_duma.bin:$(TARGET_COPY_OUT_VENDOR)/etc/wifi/WCNSS_qcom_wlan_nv_deb.bin \
	device/asus/duma/wifi/init.duma.wifi.sh:$(TARGET_COPY_OUT_VENDOR)/bin/init.duma.wifi.sh \
	device/asus/duma/wifi/wpa_supplicant_overlay.conf:$(TARGET_COPY_OUT_VENDOR)/etc/wifi/wpa_supplicant_overlay.conf \
	device/asus/duma/wifi/p2p_supplicant_overlay.conf:$(TARGET_COPY_OUT_VENDOR)/etc/wifi/p2p_supplicant_overlay.conf

# Bluetooth HAL
PRODUCT_PACKAGES += \
	android.hardware.bluetooth@1.0-impl \
	android.hardware.bluetooth@1.0-service \
	libbt-vendor

PRODUCT_COPY_FILES += \
	device/asus/duma/bluetooth/init.duma.bt.sh:$(TARGET_COPY_OUT_VENDOR)/bin/init.duma.bt.sh

# Lights
PRODUCT_PACKAGES += \
	lights.msm8960 \
	android.hardware.light@2.0-impl \
	android.hardware.light@2.0-service

# USB
PRODUCT_PACKAGES += \
	android.hardware.usb@1.0-service

PRODUCT_PACKAGES += \
	charger_res_images

# Live Wallpapers
PRODUCT_PACKAGES += \
	LiveWallpapersPicker \
	librs_jni

PRODUCT_COPY_FILES += \
	device/asus/duma/configs/thermald-duma.conf:$(TARGET_COPY_OUT_VENDOR)/etc/thermald.conf

PRODUCT_COPY_FILES += \
	device/asus/duma/configs/DxHDCP.cfg:$(TARGET_COPY_OUT_VENDOR)/etc/DxHDCP.cfg
# Kickstart
PRODUCT_COPY_FILES += \
    device/asus/duma/kickstart_checker.sh:$(TARGET_COPY_OUT_VENDOR)/bin/kickstart_checker.sh

# Media
PRODUCT_COPY_FILES += \
	frameworks/av/media/libstagefright/data/media_codecs_google_audio.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_codecs_google_audio.xml \
	frameworks/av/media/libstagefright/data/media_codecs_google_video.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_codecs_google_video.xml \
	device/asus/duma/media/media_profiles_V1_0.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_profiles_V1_0.xml \
	device/asus/duma/media/media_codecs.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_codecs.xml \
	device/asus/duma/media/media_codecs_performance.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_codecs_performance.xml

# Prebuilt kl and kcm keymaps
PRODUCT_COPY_FILES += \
	device/asus/duma/keylayout/apq8064-tabla-snd-card_Button_Jack.kl:$(TARGET_COPY_OUT_VENDOR)/usr/keylayout/apq8064-tabla-snd-card_Button_Jack.kl \
	device/asus/duma/keylayout/hs_detect.kl:$(TARGET_COPY_OUT_VENDOR)/usr/keylayout/hs_detect.kl \
	device/asus/duma/keylayout/pmic8xxx_pwrkey.kl:$(TARGET_COPY_OUT_VENDOR)/usr/keylayout/pmic8xxx_pwrkey.kl \
	device/asus/duma/keylayout/keypad_8064.kl:$(TARGET_COPY_OUT_VENDOR)/usr/keylayout/keypad_8064.kl \
	device/asus/duma/keychars/apq8064-tabla-snd-card_Button_Jack.kcm:$(TARGET_COPY_OUT_VENDOR)/usr/keychars/apq8064-tabla-snd-card_Button_Jack.kcm \
	device/asus/duma/keychars/hs_detect.kcm:$(TARGET_COPY_OUT_VENDOR)/usr/keychars/hs_detect.kcm \
	device/asus/duma/keychars/keypad_8064.kcm:$(TARGET_COPY_OUT_VENDOR)/usr/keychars/keypad_8064.kcm \
	device/asus/duma/keychars/pmic8xxx_pwrkey.kcm:$(TARGET_COPY_OUT_VENDOR)/usr/keychars/pmic8xxx_pwrkey.kcm

# Prebuilt input device calibration files
PRODUCT_COPY_FILES += \
	device/asus/duma/configs/touch_dev.idc:$(TARGET_COPY_OUT_VENDOR)/usr/idc/touch_dev.idc \
	device/asus/duma/configs/elan-touchscreen.idc:$(TARGET_COPY_OUT_VENDOR)/usr/idc/elan-touchscreen.idc

# These are the hardware-specific features
PRODUCT_COPY_FILES += \
	frameworks/native/data/etc/handheld_core_hardware.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/handheld_core_hardware.xml \
	frameworks/native/data/etc/android.hardware.camera.autofocus.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.camera.autofocus.xml \
	frameworks/native/data/etc/android.hardware.camera.front.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.camera.front.xml \
	frameworks/native/data/etc/android.hardware.location.gps.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.location.gps.xml \
	frameworks/native/data/etc/android.hardware.wifi.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.wifi.xml \
	frameworks/native/data/etc/android.hardware.wifi.direct.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.wifi.direct.xml \
	frameworks/native/data/etc/android.hardware.sensor.light.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.light.xml \
	frameworks/native/data/etc/android.hardware.sensor.gyroscope.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.gyroscope.xml \
	frameworks/native/data/etc/android.hardware.touchscreen.multitouch.jazzhand.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.touchscreen.multitouch.jazzhand.xml \
	frameworks/native/data/etc/android.software.sip.voip.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.sip.voip.xml \
	frameworks/native/data/etc/android.hardware.usb.accessory.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.usb.accessory.xml \
	frameworks/native/data/etc/android.hardware.usb.host.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.usb.host.xml \
	frameworks/native/data/etc/android.hardware.audio.low_latency.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.audio.low_latency.xml \
	frameworks/native/data/etc/android.hardware.bluetooth_le.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.bluetooth_le.xml \
	frameworks/native/data/etc/android.software.midi.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.midi.xml

# Filesystem management tools
PRODUCT_PACKAGES += \
	e2fsck

PRODUCT_PACKAGES += \
	libgenlock \
	liboverlay \
	hwcomposer.msm8960 \
	gralloc.msm8960 \
	copybit.msm8960 \
	android.hardware.graphics.allocator@2.0-impl \
	android.hardware.graphics.allocator@2.0-service \
	android.hardware.graphics.composer@2.1-impl \
	android.hardware.graphics.composer@2.1-service \
	android.hardware.graphics.mapper@2.0-impl

# Keystore HAL
PRODUCT_PACKAGES += \
	# keystore.msm8960 \
	android.hardware.keymaster@3.0-impl \
	android.hardware.keymaster@3.0-service

# Memtrack HAL
PRODUCT_PACKAGES += \
	memtrack.msm8960 \
	android.hardware.memtrack@1.0-impl \
	android.hardware.memtrack@1.0-service

# Audio
PRODUCT_PACKAGES += \
	audio.primary.msm8960 \
	audio.a2dp.default \
	audio.usb.default \
	audio.r_submix.default \
	android.hardware.audio@2.0-impl \
	android.hardware.audio@2.0-service \
	android.hardware.audio.effect@2.0-impl \
	libaudio-resampler

# Audio configuration
USE_XML_AUDIO_POLICY_CONF := 1

PRODUCT_COPY_FILES += \
	frameworks/av/services/audiopolicy/config/a2dp_audio_policy_configuration.xml:$(TARGET_COPY_OUT_VENDOR)/etc/a2dp_audio_policy_configuration.xml \
	frameworks/av/services/audiopolicy/config/audio_policy_volumes.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio_policy_volumes.xml \
	frameworks/av/services/audiopolicy/config/default_volume_tables.xml:$(TARGET_COPY_OUT_VENDOR)/etc/default_volume_tables.xml \
	frameworks/av/services/audiopolicy/config/r_submix_audio_policy_configuration.xml:$(TARGET_COPY_OUT_VENDOR)/etc/r_submix_audio_policy_configuration.xml \
	frameworks/av/services/audiopolicy/config/usb_audio_policy_configuration.xml:$(TARGET_COPY_OUT_VENDOR)/etc/usb_audio_policy_configuration.xml \
	device/asus/duma/audio/audio_policy_configuration.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio_policy_configuration.xml \
	device/asus/duma/audio/mixer_paths.xml:$(TARGET_COPY_OUT_VENDOR)/etc/mixer_paths.xml

# Voice processing
PRODUCT_PACKAGES += \
	libqcomvoiceprocessing \
	libqcomvoiceprocessingdescriptors

PRODUCT_COPY_FILES += \
	device/asus/duma/audio/audio_effects.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio_effects.xml

# Camera
PRODUCT_PACKAGES += \
	libmmcamera_interface2 \
	libmmcamera_interface \
	android.hardware.camera.provider@2.4-impl \
	android.hardware.camera.provider@2.4-service \
	camera.device@3.2-impl

PRODUCT_PACKAGES += \
	libdivxdrmdecrypt \
	libOmxVdec \
	libOmxVenc \
	libOmxCore \
	libstagefrighthw \
	libc2dcolorconvert

# GPS
PRODUCT_PACKAGES += \
	libloc_eng \
	libloc_core \
	libgps.utils \
	gps.msm8960 \
	android.hardware.gnss@1.0-impl \
	android.hardware.gnss@1.0-service

PRODUCT_COPY_FILES += \
	device/asus/duma/configs/sec_config:$(TARGET_COPY_OUT_VENDOR)/etc/sec_config \
	device/asus/duma/configs/gps.conf:$(TARGET_COPY_OUT_VENDOR)/etc/gps.conf

PRODUCT_PACKAGES += \
        hostapd_default.conf

# Power HAL
PRODUCT_PACKAGES += \
	android.hardware.power@1.0-service.qcom

# DRM
PRODUCT_PACKAGES += \
	android.hardware.drm@1.0-impl \
	android.hardware.drm@1.0-service

# Sensors HAL
PRODUCT_PACKAGES += \
	sensors.msm8960 \
	android.hardware.sensors@1.0-impl \
	android.hardware.sensors@1.0-service

$(call inherit-product, frameworks/native/build/tablet-7in-xhdpi-2048-dalvik-heap.mk)
$(call inherit-product-if-exists, vendor/widevine/arm-generic/widevine-vendor.mk)