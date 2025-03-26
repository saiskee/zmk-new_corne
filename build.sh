#!/bin/bash
set -e

# Configuration
BOARD="eyelash_corne_left"
SHIELD="nice_view"
BUILD_DIR=$(mktemp -d)
BASE_DIR="/tmp/zmk-config"
GITHUB_WORKSPACE="/workspace/zmk-new_corne"

# Create directories
mkdir -p ${BASE_DIR}/config

# Copy config files
cp -R ${GITHUB_WORKSPACE}/config/* ${BASE_DIR}/config/

# Initialize west workspace
cd ${BASE_DIR}
west init -l "${BASE_DIR}/config"

# Update dependencies (this will clone a fresh copy of ZMK)
west update

# Export Zephyr
west zephyr-export

# Build
west build -s zmk/app -d "${BUILD_DIR}" -b "${BOARD}" -- \
  -DZMK_CONFIG=${BASE_DIR}/config \
  -DSHIELD="${SHIELD}" \
  -DZMK_EXTRA_MODULES="${GITHUB_WORKSPACE}"

# Copy the resulting firmware (if build succeeds)
if [ -f "${BUILD_DIR}/zephyr/zmk.uf2" ]; then
  mkdir -p ${GITHUB_WORKSPACE}/firmware
  cp ${BUILD_DIR}/zephyr/zmk.uf2 ${GITHUB_WORKSPACE}/firmware/${BOARD}.uf2
  echo "Firmware built successfully: firmware/${BOARD}.uf2"
else
  echo "Build failed, no firmware produced"
fi
