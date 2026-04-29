#!/usr/bin/env bash

set -euo pipefail

APP_NAME="${1:-RemindMee.app}"
SOURCE_DIR="${2:-$HOME/Desktop/Release}"
OUTPUT_DMG="${3:-RemindMee.dmg}"
VOLUME_NAME="${4:-RemindMee Installer}"

if ! command -v create-dmg >/dev/null 2>&1; then
  echo "Error: create-dmg is not installed."
  echo "Install it with: brew install create-dmg"
  exit 1
fi

APP_PATH="${SOURCE_DIR}/${APP_NAME}"

if [[ ! -d "${APP_PATH}" ]]; then
  echo "Error: App not found at: ${APP_PATH}"
  echo "Usage: $0 [APP_NAME] [SOURCE_DIR] [OUTPUT_DMG] [VOLUME_NAME]"
  echo "Example: $0 RemindMee.app \"$HOME/Desktop/Release\" RemindMee.dmg \"RemindMee Installer\""
  exit 1
fi

if [[ -f "${OUTPUT_DMG}" ]]; then
  echo "Removing existing ${OUTPUT_DMG}"
  rm -f "${OUTPUT_DMG}"
fi

create-dmg \
  --volname "${VOLUME_NAME}" \
  --window-size 640 400 \
  --icon-size 110 \
  --icon "${APP_NAME}" 170 190 \
  --app-drop-link 470 190 \
  --hide-extension "${APP_NAME}" \
  "${OUTPUT_DMG}" \
  "${SOURCE_DIR}"

echo "Done: ${OUTPUT_DMG}"
