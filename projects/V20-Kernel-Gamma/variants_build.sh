#!/bin/bash

CURR_PATH=${0%/*}
CURR_PATH="$(realpath $CURR_PATH)/"

mkdir -p "${CURR_PATH}/release"

variants="us996 vs995 h910 h918 h990 ls997"

for variant in $variants
do
    # Single Screen
    rm -vrf "${CURR_PATH}/out/kbuild/arch/arm64/boot"
    time make -j10 KDEFCONFIG=lineageos_${variant}_oxavelar_defconfig
    mkdir -vp "${CURR_PATH}/release/${variant}"
    mv -v "${CURR_PATH}/out/Image.gz-dtb" "${CURR_PATH}/release/${variant}/Image.gz-dtb"
    
    # Second Screen
    rm -vrf "${CURR_PATH}/out/kbuild/arch/arm64/boot"
    time make -j10 KDEFCONFIG=lineageos_${variant}_oxavelar_defconfig CONFIG_LGE_DISABLE_SECOND_SCREEN=n
    mkdir -vp "${CURR_PATH}/release/${variant}_ss"
    mv -v "${CURR_PATH}/out/Image.gz-dtb" "${CURR_PATH}/release/${variant}_ss/Image.gz-dtb"
done

