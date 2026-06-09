#!/usr/bin/env bash
set -euo pipefail

SDK="${ANDROID_HOME:-$HOME/Library/Android/sdk}"
ADB="$SDK/platform-tools/adb"
EMU="$SDK/emulator/emulator"
AVD="pixel_9_dev"

list_emulators() {
  "$ADB" devices | awk '/^emulator-/{print $1}'
}

emulator_running() {
  "$ADB" devices | awk '/^emulator-.*device$/ {found=1} END {exit !found}'
}

while read -r dev; do
  [ -n "$dev" ] && "$ADB" -s "$dev" emu kill 2>/dev/null || true
done < <(list_emulators)
xcrun simctl shutdown all 2>/dev/null || true
sleep 1

if emulator_running; then
  echo "Pixel 9 emulator already running"
  exit 0
fi

echo "Starting $AVD..."
nohup "$EMU" -avd "$AVD" -no-snapshot-load >/tmp/pixel_9_dev_emulator.log 2>&1 &
"$ADB" wait-for-device
for _ in $(seq 1 90); do
  boot="$("$ADB" shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')"
  [ "$boot" = "1" ] && break
  sleep 2
done
echo "Pixel 9 emulator ready"
