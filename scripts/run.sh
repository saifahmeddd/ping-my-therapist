#!/usr/bin/env bash
# Start the medium phone emulator and run the app.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SDK="${ANDROID_HOME:-$HOME/Library/Android/sdk}"
export ANDROID_HOME="$SDK"
export ANDROID_SDK_ROOT="$SDK"
ADB="$SDK/platform-tools/adb"
AVD="generic_phone"

list_emulators() {
  "$ADB" devices | awk '/^emulator-/{print $1}'
}

require_free_disk() {
  local avail_kb
  avail_kb=$(df -k "$HOME" | awk 'NR==2 {print $4}')
  if [ "$avail_kb" -lt 4194304 ]; then
    echo "Low disk space: less than 4 GB free on your home drive."
    echo "Free space, then run again. Tips:"
    echo "  - Empty Trash"
    echo "  - Delete unused Android AVDs in ~/.android/avd/"
    echo "  - Run: rm -rf ~/.gradle/caches"
    exit 1
  fi
}

cd "$ROOT"
require_free_disk
bash "$ROOT/scripts/start_emulator.sh"

DEVICE_ID=""
while read -r dev; do
  [ -z "$dev" ] && continue
  avd_name="$("$ADB" -s "$dev" emu avd name 2>/dev/null | head -n 1 | tr -d '\r')"
  if [ "$avd_name" = "$AVD" ]; then
    DEVICE_ID="$dev"
    break
  fi
done < <(list_emulators)

if [ -z "$DEVICE_ID" ]; then
  echo "No emulator detected after boot."
  exit 1
fi

echo "Running on $AVD ($DEVICE_ID)"
flutter run -d "$DEVICE_ID" "$@"
