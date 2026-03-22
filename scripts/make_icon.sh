#!/bin/bash

# Exit on error
set -e

SOURCE_IMAGE="/Users/frankcaldwell/.gemini/antigravity/brain/d7689336-5539-43a6-a47c-e39922cb3860/uploaded_media_1774219884630.png"
ICONSET_DIR="Resources/AppIcon.iconset"

echo "Creating iconset directory..."
mkdir -p "${ICONSET_DIR}"

echo "Generating icons..."
sips -z 16 16     "${SOURCE_IMAGE}" --out "${ICONSET_DIR}/icon_16x16.png"
sips -z 32 32     "${SOURCE_IMAGE}" --out "${ICONSET_DIR}/icon_16x16@2x.png"
sips -z 32 32     "${SOURCE_IMAGE}" --out "${ICONSET_DIR}/icon_32x32.png"
sips -z 64 64     "${SOURCE_IMAGE}" --out "${ICONSET_DIR}/icon_32x32@2x.png"
sips -z 128 128   "${SOURCE_IMAGE}" --out "${ICONSET_DIR}/icon_128x128.png"
sips -z 256 256   "${SOURCE_IMAGE}" --out "${ICONSET_DIR}/icon_128x128@2x.png"
sips -z 256 256   "${SOURCE_IMAGE}" --out "${ICONSET_DIR}/icon_256x256.png"
sips -z 512 512   "${SOURCE_IMAGE}" --out "${ICONSET_DIR}/icon_256x256@2x.png"
sips -z 512 512   "${SOURCE_IMAGE}" --out "${ICONSET_DIR}/icon_512x512.png"
sips -z 1024 1024 "${SOURCE_IMAGE}" --out "${ICONSET_DIR}/icon_512x512@2x.png"

echo "Converting iconset to icns..."
iconutil -c icns "${ICONSET_DIR}"

echo "Cleaning up iconset directory..."
rm -rf "${ICONSET_DIR}"

echo "Successfully created Resources/AppIcon.icns!"
