#!/bin/bash

targets=("STM32F103" "STM32F407" "STM32F030" "STM32H743" "STM32L476" "STM32F303" "testing")
link="https://center.conan.io"  # Replace with your actual Conan remote URL

conan remote add my_remote "$link" || true

for target in "${targets[@]}"; do
    echo "Building package for compile_target=${target}"
    conan create . -o a_rtos_m/*:compile_target=${target} --build=missing
done

conan upload "a_rtos_m/1.0.0@" --all -r=my_remote --confirm
