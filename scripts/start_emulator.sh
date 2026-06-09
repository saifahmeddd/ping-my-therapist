#!/usr/bin/env bash
# Create (if needed) and start the medium phone emulator.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SDK="${ANDROID_HOME:-$HOME/Library/Android/sdk}"
export ANDROID_HOME="$SDK"
export ANDROID_SDK_ROOT="$SDK"
ADB="$SDK/platform-tools/adb"
EMU="$SDK/emulator/emulator"
AVD="generic_phone"
LOG="/tmp/generic_phone_emulator.log"

list_emulators() {
  "$ADB" devices | awk '/^emulator-/{print $1}'
}

emulator_running() {
  local dev avd_name
  while read -r dev; do
    [ -z "$dev" ] && continue
    avd_name="$("$ADB" -s "$dev" emu avd name 2>/dev/null | head -n 1 | tr -d '\r')"
    if [ "$avd_name" = "$AVD" ]; then
      return 0
    fi
  done < <(list_emulators)
  return 1
}

wait_for_boot() {
  echo "Waiting for emulator to boot (usually 1-3 minutes)..."
  local i boot
  for i in $(seq 1 90); do
    if list_emulators | grep -q .; then
      boot="$("$ADB" shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')"
      if [ "$boot" = "1" ]; then
        echo "Emulator boot complete."
        return 0
      fi
    fi
    if [ -f "$LOG" ] && grep -q "ERROR" "$LOG"; then
      echo "Emulator failed to start:"
      tail -5 "$LOG"
      exit 1
    fi
    if (( i % 5 == 0 )); then
      echo "Still booting... (${i}s)"
    fi
    sleep 2
  done
  echo "Emulator boot timed out. Log:"
  tail -10 "$LOG"
  exit 1
}

start_emulator() {
  : > "$LOG"
  echo "Starting $AVD..."
  nohup "$EMU" -avd "$AVD" -no-snapshot-load >>"$LOG" 2>&1 &
  sleep 4
  if [ -f "$LOG" ] && grep -q "ERROR" "$LOG"; then
    echo "Emulator failed to start:"
    tail -8 "$LOG"
    exit 1
  fi
  wait_for_boot
}

bash "$ROOT/scripts/setup_emulator.sh"

if emulator_running; then
  echo "$AVD already running"
  exit 0
fi

start_emulator
