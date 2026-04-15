# DPD Flutter App

Offline Flutter app for the [Digital Pali Dictionary](https://dpdict.net). It is Android-first and currently in beta.

This project uses [Kamma](https://github.com/bdhrs/kamma) for spec-driven work. Project context, specs, plans, and reviews live in [`kamma/`](kamma/).

## Install The Beta App

The public beta is for Android.

- Install guide in the DPD docs: <https://digitalpalidictionary.github.io/install/dpd_app/>
- GitHub releases: <https://github.com/digitalpalidictionary/dpd-flutter-app/releases>
- Latest release: <https://github.com/digitalpalidictionary/dpd-flutter-app/releases/latest>
- Beta tester notes: [`BETA_TESTER.md`](BETA_TESTER.md)

The app is still beta software. Installation uses a direct APK download rather than the Play Store. On first launch, the app downloads the dictionary database.

## For Developers

If you want to work on the app locally, it helps to have:

- Flutter stable
- Android SDK and `adb` if you want to test on Android
- [`just`](https://github.com/casey/just)

Typical local setup:

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

## Relevant Flutter And Dart Commands

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
flutter analyze
flutter test
```

## Relevant Just Recipes

```bash
just run                # generate the changelog asset and run the app; normal local development entry point
just analyze            # run static analysis; use this to catch lint and type issues quickly
just test               # run the test suite; use this for automated verification
just android-fresh      # build/install debug APK, push local DB from ../dpd-db, launch app; use when testing against a fresh local DB export
just android-update     # rebuild and reinstall debug APK without replacing the on-device DB; normal Android app-code iteration
just android-push-db    # push local DB from ../dpd-db and restart app; use when only the DB changed
just android-install-no-db  # install debug APK with no DB push and clear app data; use to test first-run download flow
just android-delete-db      # delete the on-device DB and restart app; use to force a re-download
just android-build      # build a debug APK only
just android-build-release  # build a release APK and copy it to build/app/outputs/flutter-apk/dpd.apk
just build-db           # rebuild the packaged mobile DB in ../dpd-db; only for local DB export work
just linux-run          # build and run the Linux app
just linux-push-db      # copy local DB from ../dpd-db into the Linux app location used for local testing
```
