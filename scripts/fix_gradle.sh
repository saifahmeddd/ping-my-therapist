#!/usr/bin/env bash
# Run once if `flutter run` fails with metadata.bin / kotlin-dsl errors.
set -euo pipefail

echo "Stopping Gradle daemons..."
pkill -f GradleDaemon 2>/dev/null || true

echo "Clearing corrupted Gradle 8.10.2 cache..."
rm -rf "$HOME/.gradle/caches/8.10.2/kotlin-dsl" "$HOME/.gradle/daemon"

echo "Clearing project Gradle state..."
rm -rf "$(dirname "$0")/../android/.gradle"

echo "Done. Now run: flutter run"
