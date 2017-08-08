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
# Hacked up a simple Makefile for the D855 Kernel, this has a lot of optimized
# flags and went a little extreme on specifying the flags since this is for a 
# remote compile target.
#
#                                               Mar 2016 - Omar Avelar
#
# Extra info and references taken from: 
# https://source.codeaurora.org/external/gigabyte/kernel/msm/log/?h=caf/msm-3.4
#
#
#
# Extra packages to be used in debian:
#
# sudo dpkg --add-architecture armhf
# sudo dpkg --add-architecture armel
# sudo apt-get update
# sudo apt-get install crossbuild-essential-armhf crossbuild-essential-armel

# sudo apt-get install gcc-arm-none-eabi gcc-arm-none-eabi-source
# sudo apt-get install linux-libc-dev:armel
# sudo apt-get install linux-libc-dev:armhf

############################################################################
########################## GLOBAL MAKE ARGUMENTS ###########################
############################################################################

export ARCH := arm
export ROOT_DIR := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
ifneq ($(wildcard /usr/bin/arm-none-eabi-disabled),)
    export CROSS_COMPILE := /usr/bin/arm-none-eabi-
else
    export CROSS_COMPILE := $(ROOT_DIR)/gcc/linaro-6.3/bin/arm-eabi-
endif
export KBUILD_VERBOSE := 0

############################################################################
##################### LOCAL SETUP AND FILE STRUCTURES ######################
############################################################################

KDEFCONFIG := lineageos_d855_oxavelar_defconfig
KSRC_PATH = $(ROOT_DIR)/kernel/
OUT_PATH := $(ROOT_DIR)/out
KBUILD_OUT_PATH = $(OUT_PATH)/kbuild
MBUILD_OUT_PATH = $(OUT_PATH)/mbuild
DBUILD_OUT_PATH = $(OUT_PATH)/dbuild


############################################################################
############## KERNEL OPTIMIZATION FLAGS FOR THE QCOM S801 #################
############################################################################

export QCOM_S801 := \
        -march=armv7ve \
        -mtune=cortex-a15 \
        -mfpu=neon-vfpv4 \
        -mvectorize-with-neon-quad \
        -mno-unaligned-access \
        --param l1-cache-line-size=64 \
        --param l1-cache-size=32 \
        --param l2-cache-size=2048 \

export GRAPHTIE_FLAGS := \
        -fgraphite-identity \
        -ftree-loop-linear \
        -floop-interchange \
        -floop-strip-mine \
        -floop-block \

export KCFLAGS := \
        -pipe \
        -O3 \
        -fomit-frame-pointer \
        -ftree-vectorize \
        -ftree-slp-vectorize \
        -fvect-cost-model \
        -ftree-partial-pre \
        -fweb \
        -fgcse \
        -fgcse-sm \
        -fgcse-las \
        -fgcse-after-reload \
        -fivopts \
        -fsection-anchors \
        -fsched-spec-load \
        -ftree-loop-distribution \
        -ftree-loop-distribute-patterns \
        -ftree-loop-im \
        -ftree-loop-if-convert \
        -ftree-loop-if-convert-stores \
        -fpredictive-commoning \
        -foptimize-register-move \
        -fipa-cp-clone \
        -fipa-pta \
        -fmodulo-sched \
        -fmodulo-sched-allow-regmoves \
        $(QCOM_S801) \
        $(GRAPHITE_FLAGS) \

export KCFLAGS += -Wno-maybe-uninitialized
export LDFLAGS += -O3 --hash-style=gnu --as-needed -flto

export KCFLAGS += -Wno-unused-const-variable
export KCFLAGS += -Wno-misleading-indentation
export KCFLAGS += -Wno-bool-compare
export KCFLAGS += -Wno-shift-overflow
export KCFLAGS += -Wno-tautological-compare
export KCFLAGS += -Wno-duplicate-decl-specifier
export KCFLAGS += -Wno-switch-unreachable
export KCFLAGS += -Wno-array-bounds


############################################################################
########################### KERNEL BUILD STEPS #############################
############################################################################

.PHONY: kernel
kernel: dtb
	mkdir -p "$(KBUILD_OUT_PATH)"
	$(MAKE) -C "$(KSRC_PATH)" O="$(KBUILD_OUT_PATH)" "$(KDEFCONFIG)"
	$(MAKE) -C "$(KSRC_PATH)" O="$(KBUILD_OUT_PATH)" CONFIG_NO_ERROR_ON_MISMATCH=y CONFIG_DEBUG_SECTION_MISMATCH=y KCFLAGS+="$(KCFLAGS)" zImage
	cp -f "$(KBUILD_OUT_PATH)/arch/$(ARCH)/boot/zImage" "$(OUT_PATH)/zImage"

.PHONY: modules
modules:
	# General modules from the kernel
	mkdir -p "$(MBUILD_OUT_PATH)"
	$(MAKE) -C "$(KSRC_PATH)" O="$(MBUILD_OUT_PATH)" "$(KDEFCONFIG)"
	$(MAKE) -C "$(KSRC_PATH)" O="$(MBUILD_OUT_PATH)" KCFLAGS+="$(KCFLAGS)" modules
	# Copy the created modules to the ramdisk path and strip debug symbols
	find "$(MBUILD_OUT_PATH)" -iname *.ko -exec cp -f \{\} "$(OUT_PATH)/lib/modules/" \;
	strip --strip-debug --strip-unneeded --remove-section=.comment --remove-section=.note "$(OUT_PATH)/lib/modules/*.*o"

.PHONY: dtb
dtb:
	mkdir -p "$(DBUILD_OUT_PATH)"
	$(MAKE) -C "$(KSRC_PATH)" O="$(DBUILD_OUT_PATH)" "$(KDEFCONFIG)"
	$(MAKE) -C "$(KSRC_PATH)" O="$(DBUILD_OUT_PATH)" KCFLAGS+="$(KCFLAGS)" dtbs
	"$(ROOT_DIR)/tools/dtbToolCM" -s 2048 -d "qcom,msm-id = <" -o "$(OUT_PATH)/dt.img" -p "$(DBUILD_OUT_PATH)/scripts/dtc/" "$(DBUILD_OUT_PATH)/arch/$(ARCH)/boot/"
	cp -f "$(OUT_PATH)/dt.img" "$(OUT_PATH)/dtb"

.PHONY: clean
clean:
	$(MAKE) -C "$(KSRC_PATH)" mrproper
	rm -rf "$(OUT_PATH)"

