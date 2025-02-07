LOCAL_PATH:= $(call my-dir)

DROIDMEDIA_32 := $(shell cat frameworks/av/media/mediaserver/Android.mk |grep "LOCAL_32_BIT_ONLY[[:space:]]*:=[[:space:]]*" |grep -o "true\|1\|false\|0")

ANDROID_MAJOR :=
ANDROID_MINOR :=
ANDROID_MICRO :=
FORCE_HAL_PARAM :=

include $(LOCAL_PATH)/env.mk
ifdef FORCE_HAL
FORCE_HAL_PARAM := -DFORCE_HAL=$(FORCE_HAL)
endif

ifndef ANDROID_MAJOR
include build/core/version_defaults.mk
ifeq ($(strip $(PLATFORM_VERSION)),)
$error(*** Cannot get Android platform version)
endif
ANDROID_MAJOR = $(shell echo $(PLATFORM_VERSION) | cut -d . -f 1)
ANDROID_MINOR = $(shell echo $(PLATFORM_VERSION) | cut -d . -f 2)
ANDROID_MICRO = $(shell echo $(PLATFORM_VERSION) | cut -d . -f 3)
endif

ifeq ($(strip $(ANDROID_MAJOR)),)
$(error *** ANDROID_MAJOR undefined)
endif

ifeq ($(strip $(ANDROID_MINOR)),)
$(error *** ANDROID_MINOR undefined)
endif

ifeq ($(strip $(ANDROID_MINOR)),)
$(warning *** ANDROID_MICRO undefined. Assuming 0)
ANDROID_MINOR = 0
endif

ifeq ($(strip $(ANDROID_MICRO)),)
$(warning *** ANDROID_MICRO undefined. Assuming 0)
ANDROID_MICRO = 0
endif

include $(CLEAR_VARS)
LOCAL_SRC_FILES := droidmedia.cpp \
                   droidmediacamera.cpp \
                   droidmediaconstants.cpp \
                   droidmediacodec.cpp \
                   droidmediaconvert.cpp \
                   droidmediarecorder.cpp \
                   allocator.cpp \
                   droidmediabuffer.cpp \
                   private.cpp

LOCAL_SHARED_LIBRARIES := libc \
                          libdl \
                          libutils \
                          libcutils \
                          libcamera_client \
                          libgui \
                          libui \
                          libbinder \
                          libstagefright \
                          libstagefright_foundation \
                          libmedia

ifeq ($(ANDROID_MAJOR),$(filter $(ANDROID_MAJOR),8 9))
LOCAL_SHARED_LIBRARIES += liblog
endif

ifeq ($(ANDROID_MAJOR),$(filter $(ANDROID_MAJOR),9))
LOCAL_SHARED_LIBRARIES += libmediaextractor \
                          android.hidl.memory@1.0
endif

LOCAL_CPPFLAGS=-DANDROID_MAJOR=$(ANDROID_MAJOR) -DANDROID_MINOR=$(ANDROID_MINOR) -DANDROID_MICRO=$(ANDROID_MICRO) $(FORCE_HAL_PARAM) -Wno-unused-parameter
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE := libdroidmedia

ifeq ($(strip $(ANDROID_MAJOR)),7)
LOCAL_C_INCLUDES := frameworks/native/include/media/openmax \
                    frameworks/native/include/media/hardware
else ifeq ($(ANDROID_MAJOR),$(filter $(ANDROID_MAJOR),8 9))
LOCAL_C_INCLUDES := frameworks/native/include/media/openmax \
                    frameworks/native/include/media/hardware \
                    frameworks/native/libs/nativewindow/include \
                    frameworks/av/media/libstagefright/omx/include \
                    frameworks/av/media/libstagefright/xmlparser/include
else
LOCAL_C_INCLUDES := frameworks/native/include/media/openmax
endif

ifeq ($(ANDROID_MAJOR),$(filter $(ANDROID_MAJOR),9))
LOCAL_C_INCLUDES += frameworks/av/media/libmediaextractor/include
endif

include $(BUILD_SHARED_LIBRARY)

include $(CLEAR_VARS)
LOCAL_SRC_FILES := minimedia.cpp
LOCAL_C_INCLUDES := frameworks/av/services/camera/libcameraservice \
                    frameworks/av/media/libmediaplayerservice \
                    system/media/camera/include
LOCAL_SHARED_LIBRARIES := libcameraservice \
                          libmediaplayerservice \
                          libcamera_client \
                          libutils \
                          libmedia \
                          libbinder \
                          libgui \
                          libcutils \
                          libui

ifeq ($(ANDROID_MAJOR),$(filter $(ANDROID_MAJOR),8 9))
LOCAL_C_INCLUDES += frameworks/native/libs/sensor/include \
                    frameworks/av/media/libstagefright/omx/include
LOCAL_SHARED_LIBRARIES += liblog \
                          libhidlbase \
                          libhidltransport \
                          libhwbinder \
                          libsensor \
                          android.frameworks.sensorservice@1.0 \
                          android.hardware.camera.common@1.0 \
                          android.hardware.camera.provider@2.4
endif

ifeq ($(ANDROID_MAJOR),$(filter $(ANDROID_MAJOR),9))
LOCAL_SHARED_LIBRARIES += android.hidl.memory@1.0
endif

LOCAL_MODULE_TAGS := optional
LOCAL_CPPFLAGS=-DANDROID_MAJOR=$(ANDROID_MAJOR) -DANDROID_MINOR=$(ANDROID_MINOR) -DANDROID_MICRO=$(ANDROID_MICRO) -Wno-unused-parameter
ifeq ($(MINIMEDIA_SENSORSERVER_DISABLE),1)
    LOCAL_CPPFLAGS += -DSENSORSERVER_DISABLE
endif
LOCAL_MODULE := minimediaservice
ifeq ($(strip $(DROIDMEDIA_32)), true)
LOCAL_32_BIT_ONLY := true
endif
include $(BUILD_EXECUTABLE)

include $(CLEAR_VARS)
LOCAL_SRC_FILES := minisf.cpp allocator.cpp
LOCAL_SHARED_LIBRARIES := libutils \
                          libbinder \
                          libmedia \
                          libgui \
                          libcutils \
                          libui

ifeq ($(ANDROID_MAJOR),$(filter $(ANDROID_MAJOR),8 9))
LOCAL_C_INCLUDES := frameworks/native/libs/sensor/include \
                    frameworks/native/include
LOCAL_SHARED_LIBRARIES += liblog \
                          libhidlbase \
                          libhidltransport \
                          libhwbinder \
                          libsensor \
                          android.frameworks.sensorservice@1.0 \
                          android.hardware.camera.common@1.0 \
                          android.hardware.camera.provider@2.4
endif

ifeq ($(ANDROID_MAJOR),$(filter $(ANDROID_MAJOR),9))
LOCAL_SHARED_LIBRARIES += android.hidl.memory@1.0
endif

LOCAL_MODULE_TAGS := optional
LOCAL_CPPFLAGS := -DANDROID_MAJOR=$(ANDROID_MAJOR) -DANDROID_MINOR=$(ANDROID_MINOR) -DANDROID_MICRO=$(ANDROID_MICRO) -Wno-unused-parameter
ifneq ($(CM_BUILD),)
LOCAL_CPPFLAGS += -DCM_BUILD
endif
ifneq ($(shell cat frameworks/native/services/surfaceflinger/SurfaceFlinger.h |grep getDisplayInfoEx),)
LOCAL_CPPFLAGS += -DUSE_SERVICES_VENDOR_EXTENSION
endif
LOCAL_MODULE := minisfservice
ifeq ($(strip $(DROIDMEDIA_32)), true)
LOCAL_32_BIT_ONLY := true
endif
include $(BUILD_EXECUTABLE)

include $(CLEAR_VARS)
LOCAL_SRC_FILES := libminisf.cpp allocator.cpp
LOCAL_SHARED_LIBRARIES := libutils \
                          libbinder \
                          libmedia \
                          libgui \
                          libcutils \
                          libui
LOCAL_MODULE_TAGS := optional
LOCAL_CPPFLAGS := -DANDROID_MAJOR=$(ANDROID_MAJOR) -DANDROID_MINOR=$(ANDROID_MINOR) -DANDROID_MICRO=$(ANDROID_MICRO) -Wno-unused-parameter
ifneq ($(CM_BUILD),)
LOCAL_CPPFLAGS += -DCM_BUILD
endif
ifneq ($(shell cat frameworks/native/services/surfaceflinger/SurfaceFlinger.h |grep getDisplayInfoEx),)
LOCAL_CPPFLAGS += -DUSE_SERVICES_VENDOR_EXTENSION
endif
ifeq ($(ANDROID_MAJOR),$(filter $(ANDROID_MAJOR),8 9))
LOCAL_SHARED_LIBRARIES += liblog \
                          libcamera_client \
                          libhidlbase \
                          libhidltransport \
                          libhwbinder \
                          libsensor \
                          android.frameworks.sensorservice@1.0 \
                          android.hardware.camera.common@1.0 \
                          android.hardware.camera.provider@2.4
endif

ifeq ($(ANDROID_MAJOR),$(filter $(ANDROID_MAJOR),9))
LOCAL_SHARED_LIBRARIES += android.hidl.memory@1.0
endif

LOCAL_MODULE := libminisf
include $(BUILD_SHARED_LIBRARY)
