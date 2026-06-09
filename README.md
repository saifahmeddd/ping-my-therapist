# Ping My Therapist

Flutter app for mood tracking and therapist check-ins.

## Run from VS Code

1. Install the **Flutter** extension (VS Code will prompt if missing).
2. **Terminal → Run Task… → Start Medium Phone Emulator** — creates the AVD on first run, then boots it (1–3 min).
3. Run the app — any of these work:

- **Terminal → Run Build Task** (or `Cmd+Shift+B`) — starts emulator + `flutter run`
- **Terminal → Run Task… → Flutter Run (Android)**
- Press **F5** — starts emulator + debug launch

If the emulator is already running, `flutter run` in the terminal also works.

**If you only see "Mac Designed for iPad"** — the Android emulator is off. Run **Start Medium Phone Emulator** first, or use `./scripts/run.sh` which starts it for you.

The emulator uses the **Medium Phone** profile (Android 35, no notch).

## Run from terminal

```bash
cd "/Users/saifahmed/development/Ping My Therapist"
./scripts/run.sh
```

First run creates the emulator automatically. The first build may take several minutes.

## Requirements

- Flutter SDK
- Android Studio (for the Android SDK and emulator)
- At least ~5 GB free disk space for builds
