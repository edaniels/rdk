#!/bin/bash -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
ROOT_DIR="${DIR}/../../"
export TEMP_DIR=`mktemp -d -t droid-rdk`
cd ${TEMP_DIR}
cp ${ROOT_DIR}/droid-rdk.aar .
unzip droid-rdk.aar
rm droid-rdk.aar
cp -R ${ROOT_DIR}/services/mlmodel/tflitecpu/android/jni .
zip -r ${ROOT_DIR}/droid-rdk.aar *
