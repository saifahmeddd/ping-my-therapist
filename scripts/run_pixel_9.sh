#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SDK="${ANDROID_HOME:-$HOME/Library/Android/sdk}"
ADB="$SDK/platform-tools/adb"

cd "$ROOT"
bash "$ROOT/scripts/start_pixel_9_emulator.sh"

DEVICE_ID="$("$ADB" devices | awk '/^emulator-/{print $1; exit}')"
echo "Running on Pixel 9 emulator ($DEVICE_ID)"
flutter run -d "$DEVICE_ID" "$@"
