#!/usr/bin/env bash
# Creates a plain generic phone emulator (no camera notch, minimal skin).
set -euo pipefail

export JAVA_HOME="${JAVA_HOME:-/Applications/Android Studio.app/Contents/jbr/Contents/Home}"
SDK="${ANDROID_HOME:-$HOME/Library/Android/sdk}"
export ANDROID_HOME="$SDK"
export ANDROID_SDK_ROOT="$SDK"
AVDCMD="$SDK/cmdline-tools/latest/bin/avdmanager"
EMU="$SDK/emulator/emulator"
AVD="generic_phone"
IMAGE="system-images;android-35;google_apis_playstore;arm64-v8a"
CONFIG="$HOME/.android/avd/${AVD}.avd/config.ini"

apply_low_disk_settings() {
  [ -f "$CONFIG" ] || return 0
  sed -i '' \
    -e 's/^disk.dataPartition.size = .*/disk.dataPartition.size = 2147483648/' \
    -e 's/^hw.sdCard = .*/hw.sdCard = no/' \
    -e 's/^sdcard.size = .*/sdcard.size = 128 MB/' \
    -e 's/^hw.ramSize = .*/hw.ramSize = 1536M/' \
    -e 's/^firstboot.bootFromLocalSnapshot = .*/firstboot.bootFromLocalSnapshot = no/' \
    -e 's/^firstboot.saveToLocalSnapshot = .*/firstboot.saveToLocalSnapshot = no/' \
    "$CONFIG"
}

if "$EMU" -list-avds 2>/dev/null | grep -Fxq "$AVD"; then
  apply_low_disk_settings
  echo "$AVD already exists (low-disk settings applied)"
  exit 0
fi

echo "Creating $AVD (Medium Phone, Android 35)..."
echo no | "$AVDCMD" create avd -n "$AVD" -d medium_phone -k "$IMAGE" --force
apply_low_disk_settings
echo "Done."
