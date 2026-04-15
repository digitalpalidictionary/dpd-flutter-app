# ---------- DART & FLUTTER ----------


# Start the app on the current Flutter target.
# Use this for normal local development when you want the app to launch and
# let its standard startup flow handle the database download if needed.
run:
    dart run tool/generate_changelog.dart
    flutter run

# Run static analysis.
# Use this before or after changes to catch type errors, lint issues, and
# general Dart/Flutter problems without launching the app.
analyze:
    flutter analyze

# Run the test suite.
# Use this for the repo's automated verification of non-UI behavior.
test:
    flutter test


# ---------- ANDROID ----------

_android_pkg := "net.dpdict.dpd_flutter_app.debug"
_android_db_dir := "/storage/emulated/0/Android/data/" + _android_pkg + "/files"
_android_db_path := _android_db_dir + "/dpd-mobile.db"
_local_db := "../dpd-db/exporter/share/dpd-mobile.db"

# Build a debug APK, install it, push a local mobile DB from ../dpd-db, then launch.
# Use this when you are doing Android development against a fresh local database
# export and want one command to reset the device-side app state into that setup.
android-fresh:
    dart run tool/generate_changelog.dart
    flutter build apk --debug
    adb install -r build/app/outputs/flutter-apk/app-debug.apk
    adb shell am force-stop {{_android_pkg}}
    adb shell mkdir -p {{_android_db_dir}}
    adb shell rm -f {{_android_db_path}}-wal {{_android_db_path}}-shm {{_android_db_path}}-journal
    adb push {{_local_db}} {{_android_db_path}}
    adb shell am start -n {{_android_pkg}}/net.dpdict.dpd_flutter_app.MainActivity

# Rebuild and reinstall the debug APK without touching the on-device database.
# Use this for normal Android iteration when app code changed but the existing
# device database and app data should stay in place.
android-update:
    dart run tool/generate_changelog.dart && flutter build apk --debug && adb install -r build/app/outputs/flutter-apk/app-debug.apk

# Push a local mobile DB from ../dpd-db onto the device and restart the app.
# Use this when database content changed locally and you want to refresh only
# the database without rebuilding the APK. The cleanup avoids stale SQLite sidecars.
android-push-db:
    adb shell am force-stop {{_android_pkg}}
    adb shell mkdir -p {{_android_db_dir}}
    adb shell rm -f {{_android_db_path}}-wal {{_android_db_path}}-shm {{_android_db_path}}-journal
    adb push {{_local_db}} {{_android_db_path}}
    adb shell am start -n {{_android_pkg}}/net.dpdict.dpd_flutter_app.MainActivity
    @echo "DB pushed (WAL/SHM cleaned) and app restarted."

# Install a debug APK with no local DB push and clear app data first.
# Use this to test the real first-run experience where the app downloads the
# database itself on launch.
android-install-no-db:
    dart run tool/generate_changelog.dart
    flutter build apk --debug
    adb install -r build/app/outputs/flutter-apk/app-debug.apk
    adb shell pm clear {{_android_pkg}}
    adb shell am start -n {{_android_pkg}}/net.dpdict.dpd_flutter_app.MainActivity

# Delete the on-device database and restart the app.
# Use this to force the app back into its download-required state without
# reinstalling the APK.
android-delete-db:
    adb shell am force-stop {{_android_pkg}}
    adb shell rm -f {{_android_db_path}} {{_android_db_path}}-wal {{_android_db_path}}-shm {{_android_db_path}}-journal {{_android_db_path}}.zip
    adb shell am start -n {{_android_pkg}}/net.dpdict.dpd_flutter_app.MainActivity
    @echo "DB deleted — app will prompt for download."

# Build a debug APK only.
# Use this when you need the APK artifact but do not want to install or launch it.
android-build:
    dart run tool/generate_changelog.dart
    flutter build apk --debug

# Build a release APK and copy it to a stable output name.
# Use this when preparing a distributable Android build for manual testing or release work.
android-build-release:
    dart run tool/generate_changelog.dart
    flutter build apk --release
    cp build/app/outputs/flutter-apk/app-release.apk build/app/outputs/flutter-apk/dpd.apk
    @echo "\nRelease APK: build/app/outputs/flutter-apk/dpd.apk"

# Rebuild the packaged mobile database in the sibling ../dpd-db repo.
# Use this only when the database export itself needs to be regenerated locally.
build-db:
    cd ../dpd-db && uv run python exporter/mobile/mobile_exporter.py --cone

# ---------- LINUX ----------

# Build and run the Linux app.
# Use this for local desktop development on Linux when you want the generated
# changelog included and the app launched immediately.
linux-run:
    dart run tool/generate_changelog.dart && flutter build linux --debug && flutter run -d linux

# Copy a local mobile DB from ../dpd-db into the Linux app location used by this repo.
# Use this when testing Linux against a specific local database export instead
# of relying on the app's normal download/update path.
linux-push-db:
    cp ../dpd-db/exporter/share/dpd-mobile.db ~/Documents/dpd-mobile.db
