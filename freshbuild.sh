#!/bin/bash
set -e

# Configuration
BOARD="eyelash_corne_left"
SHIELD="nice_view"
BASE_DIR=$(mktemp -d)
BUILD_DIR="${BASE_DIR}/build"
GITHUB_WORKSPACE="/workspace/zmk-new_corne"

echo "Working in temporary directory: ${BASE_DIR}"

# Create config directory
mkdir -p ${BASE_DIR}/config

# Copy config files
cp -R ${GITHUB_WORKSPACE}/config/* ${BASE_DIR}/config/

# Initialize west workspace from scratch
cd ${BASE_DIR}
west init -m https://github.com/infused-kim/zmk --mr pr-testing/mouse_ps2_module_base

# Update all dependencies
west update

# Export Zephyr
west zephyr-export

# Build
mkdir -p ${BUILD_DIR}
west build -s zmk/app -d "${BUILD_DIR}" -b "${BOARD}" -- \
  -DZMK_CONFIG=${BASE_DIR}/config \
  -DSHIELD="${SHIELD}" \
  -DZMK_EXTRA_MODULES="${GITHUB_WORKSPACE}"

# Copy the resulting firmware (if build succeeds)
if [ -f "${BUILD_DIR}/zephyr/zmk.uf2" ]; then
  mkdir -p ${GITHUB_WORKSPACE}/firmware
  cp ${BUILD_DIR}/zephyr/zmk.uf2 ${GITHUB_WORKSPACE}/firmware/${BOARD}.uf2
  echo "Firmware built successfully: ${GITHUB_WORKSPACE}/firmware/${BOARD}.uf2"
else
  echo "Build failed, no firmware produced"
fi