#!/bin/bash

# Exit on error
set -e

APP_NAME="MacWiggleBox"
BUNDLE_ID="com.frankocald.MacWiggleBox"
BUILD_DIR=".build/release"
APP_BUNDLE="${APP_NAME}.app"

echo "Building ${APP_NAME} in release mode..."
swift build -c release --disable-sandbox

echo "Creating .app bundle structure..."
rm -rf "${APP_BUNDLE}"
mkdir -p "${APP_BUNDLE}/Contents/MacOS"
mkdir -p "${APP_BUNDLE}/Contents/Resources"

echo "Copying binary and Info.plist..."
cp "${BUILD_DIR}/${APP_NAME}" "${APP_BUNDLE}/Contents/MacOS/"
cp "Resources/Info.plist" "${APP_BUNDLE}/Contents/"

# If we have an icon, we'd copy it here
# cp "Resources/AppIcon.icns" "${APP_BUNDLE}/Contents/Resources/"

echo "Successfully created ${APP_BUNDLE}!"
echo "You can now move ${APP_BUNDLE} to your /Applications folder."
