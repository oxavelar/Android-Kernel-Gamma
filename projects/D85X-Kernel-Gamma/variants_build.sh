#!/bin/bash

CURR_PATH=${0%/*}
CURR_PATH="$(realpath $CURR_PATH)/"

mkdir -p "${CURR_PATH}/release"

variants="d855 vs985 ls990 d850 d851 d852"

for variant in $variants
do
    rm -vrf "${CURR_PATH}/out/kbuild/arch/arm64/boot"
    time make -j10 KDEFCONFIG=lineageos_${variant}_oxavelar_defconfig
    mkdir -vp "${CURR_PATH}/release/${variant}"
    mv -v "${CURR_PATH}/out/zImage" "${CURR_PATH}/release/${variant}/zImage"
    mv -v "${CURR_PATH}/out/dtb" "${CURR_PATH}/release/${variant}/dtb"
done

