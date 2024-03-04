#!/bin/bash -e

if [[ -z "${ANDROID_NDK}" ]]; then
    echo "Must provide NDK_ROOT in environment" 1>&2
    exit 1
fi

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
ROOT_DIR="${DIR}/../../"
source ${ANDROID_NDK}/build/tools/ndk_bin_common.sh
NDK_TOOLCHAIN=${ANDROID_NDK}/toolchains/llvm/prebuilt/${HOST_TAG}

# ripped from private sysops repo
cd ~ && mkdir -p tensorflow/build_arm64-v8a tensorflow/build_x86_64 && cd tensorflow
curl -L https://github.com/tensorflow/tensorflow/archive/refs/tags/v2.12.0.tar.gz | tar -xzv
patch -p1 -d tensorflow-2.12.0 < ${DIR}/tflite.patch
cd ~/tensorflow/build_arm64-v8a
cmake -DCMAKE_TOOLCHAIN_FILE=${ANDROID_NDK}/build/cmake/android.toolchain.cmake \
  -DANDROID_ABI=arm64-v8a ../tensorflow-2.12.0/tensorflow/lite/c
cmake --build . -j
${NDK_TOOLCHAIN}/bin/llvm-strip --strip-unneeded libtensorflowlite_c.so
cd ~/tensorflow/build_x86_64
cmake -DCMAKE_TOOLCHAIN_FILE=${ANDROID_NDK}/build/cmake/android.toolchain.cmake \
  -DANDROID_ABI=x86_64 ../tensorflow-2.12.0/tensorflow/lite/c
cmake --build . -j
${NDK_TOOLCHAIN}/bin/llvm-strip --strip-unneeded libtensorflowlite_c.so
cd ../
mkdir -p ${ROOT_DIR}/services/mlmodel/tflitecpu/android/jni/arm64-v8a
mkdir -p ${ROOT_DIR}/services/mlmodel/tflitecpu/android/jni/x86_64
cp build_arm64-v8a/libtensorflowlite_c.so ${ROOT_DIR}/services/mlmodel/tflitecpu/android/jni/arm64-v8a/
cp build_x86_64/libtensorflowlite_c.so ${ROOT_DIR}/services/mlmodel/tflitecpu/android/jni/x86_64/
cd ~ && rm -rf ~/tensorflow/
