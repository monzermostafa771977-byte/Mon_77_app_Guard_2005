# Build and test

## Requirements
- Flutter stable (CI selects the current stable channel)
- Java 17
- Android SDK (provided by GitHub-hosted Ubuntu runner)

## Commands
```bash
flutter create --platforms=android --org com.monzer --project-name hares .
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
```

APK output: `build/app/outputs/flutter-apk/app-debug.apk`.

## GitHub Actions
Workflow: `.github/workflows/android-apk.yml`.
It runs on pushes to `main`/`master` and can also be started manually from Actions. The APK is uploaded as `HARES-Stage1-debug-APK`.

## Device acceptance checklist
1. Install APK on an Android test device.
2. Launch app and navigate between all main sections.
3. Force-close and reopen; verify app starts normally.
4. Restart device and reopen; verify settings remain.
5. Confirm no usage-monitoring or blocking feature is represented as active in this stage.
6. Before updating an installed build, verify same `applicationId` and do not clear app storage.
