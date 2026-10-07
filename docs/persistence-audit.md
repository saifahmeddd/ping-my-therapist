# Flutter persistence audit (2026-10-08)

This audit covers user-created data in the Flutter patient app. Visual assets bundled with the APK and third-party Spotify artwork are not user records.

| Data | Durable store and read path | Audit result |
| --- | --- | --- |
| Account and session | Firebase Auth; splash/login check the signed-in user | SDK-backed; live sign-up, reset, and session restoration still need device verification. |
| Patient profile | `users/{uid}`; profile reloads Firestore and Auth email | Edit writes name, age, occupation; email change requires verification. Registration now retries a profile write after Auth succeeds instead of creating a second account. |
| Onboarding answers | `onboarding_responses/{uid}` plus `users/{uid}.onboarding_complete` in one batch | Completion remains on the save screen after failure and offers retry. |
| Prompted and free-write journals | `journal_entries` with `userId`, text, prompt, server timestamp; saved screen queries the same user ID | Save is awaited; failed text remains editable; duplicate taps are blocked. Saved entries use one indexed filter and are sorted locally. |
| Quick and detailed mood check-ins | `mood_checkins` with `userId`, selections, optional reflection text, server timestamp | Both screens now require a successful write before reporting completion. Tracker and music read the signed-in user's records. |
| AI conversations | `chat_sessions` with `userId` and message array; sidebar reads the user's sessions | First send always creates a session. User-message save errors restore the draft; assistant-message errors offer retry. History load/delete errors are shown. Owner deletion requires the local Firestore rule change to be deployed. |
| Bookings | `appointments` with patient Firebase UID; My Bookings streams records by patient ID | Creation is awaited. Duplicate-slot detection now uses one indexed patient query and local filtering. Live therapist-to-patient synchronization still needs verification. |
| Therapist profiles and images | `therapists` records contain profile-photo URLs; images load remotely | The patient app has no photo capture/upload flow. Bundled illustrations and GIFs ship in the APK; Spotify artwork is external and may change or be unavailable. |

Automated tests cover journal retry and ordering, mood retry, onboarding retry, chat message serialization, booking mapping and duplicate windows, and existing UI/navigation flows. They do not exercise a live Firebase project or prove that deployed Firestore rules match this repository. Verify on a physical device by saving each record, force-closing and reopening the app, signing out and back in, and checking the same records. Check the portal-created booking path separately with a linked patient.

The Firestore rules change is deliberately local until deployment is approved. It permits a patient to delete only their own chat sessions and keeps session ownership immutable on update.

## Remaining limits

- Unsaved form drafts (journal text before Save, a partly completed onboarding flow, and an unsent chat composer message) are in widget memory. They do not survive force-closing the app. Persisting these sensitive drafts would require an explicit secure local-draft design.
- Firebase Auth account creation and the subsequent `users/{uid}` profile write are separate operations. The registration screen can retry a failed profile write while it remains open; force-closing between those operations still needs a recovery flow.
- Chat messages are stored in one Firestore document per session. Very long conversations can eventually reach Firestore's document-size limit; moving messages to a subcollection would be a data migration.
- A successful mocked or widget test does not prove production Firebase rules, data indexes, account permissions, or offline synchronization. The physical-device save/reopen/sign-in checks above remain required.
