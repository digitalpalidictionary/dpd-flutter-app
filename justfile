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

_android_pkg_debug := "net.dpdict.dpd_flutter_app.debug"
_android_pkg_release := "net.dpdict.dpd_flutter_app"
_android_activity := "net.dpdict.dpd_flutter_app.MainActivity"
_android_data := "/storage/emulated/0/Android/data"
_android_db_debug := _android_data + "/" + _android_pkg_debug + "/files/dpd-mobile.db"
_local_db := "../dpd-db/exporter/share/dpd-mobile.db"

# Install an APK from build/app/outputs/flutter-apk onto the device.
_android-install apk:
    adb install -r build/app/outputs/flutter-apk/{{apk}}

# Push a local mobile DB from ../dpd-db into the given package's files dir.
# The cleanup avoids stale SQLite sidecars.
_android-push-db pkg:
    adb shell am force-stop {{pkg}}
    adb shell mkdir -p {{_android_data}}/{{pkg}}/files
    adb shell rm -f {{_android_data}}/{{pkg}}/files/dpd-mobile.db-wal {{_android_data}}/{{pkg}}/files/dpd-mobile.db-shm {{_android_data}}/{{pkg}}/files/dpd-mobile.db-journal
    adb push {{_local_db}} {{_android_data}}/{{pkg}}/files/dpd-mobile.db

# Launch the app for the given package.
_android-launch pkg:
    adb shell am start -n {{pkg}}/{{_android_activity}}

# --- Debug ---

# Build a debug APK only.
# Use this when you need the APK artifact but do not want to install or launch it.
android-debug-build:
    dart run tool/generate_changelog.dart
    flutter build apk --debug

# Build and install a debug APK, push a local mobile DB from ../dpd-db, then launch.
# Use this when you are doing Android development against a fresh local database
# export and want one command to reset the device-side app state into that setup.
android-debug-install: android-debug-build (_android-install "app-debug.apk") (_android-push-db _android_pkg_debug) (_android-launch _android_pkg_debug)

# Build and install a debug APK with cleared app data and no DB push.
# Use this to test the real first-run experience where the app downloads the
# database itself on launch.
android-debug-install-no-db: android-debug-build (_android-install "app-debug.apk")
    adb shell pm clear {{_android_pkg_debug}}
    adb shell am start -n {{_android_pkg_debug}}/{{_android_activity}}

# Rebuild and reinstall the debug APK without touching the on-device database.
# Use this for normal Android iteration when app code changed but the existing
# device database and app data should stay in place.
android-debug-update: android-debug-build (_android-install "app-debug.apk")

# Push a local mobile DB from ../dpd-db onto the device and restart the app.
# Use this when database content changed locally and you want to refresh only
# the database without rebuilding the APK.
android-debug-push-db: (_android-push-db _android_pkg_debug) (_android-launch _android_pkg_debug)
    @echo "DB pushed (WAL/SHM cleaned) and app restarted."

# Push a local mobile DB from ../dpd-db onto the device WITHOUT relaunching.
# Use this for an automated refresh (e.g. on device plug-in) where the app
# should stay closed after the database is replaced.
android-debug-push-db-no-launch: (_android-push-db _android_pkg_debug)
    @echo "DB pushed (WAL/SHM cleaned), app left stopped."

# Delete the on-device database and restart the app.
# Use this to force the app back into its download-required state without
# reinstalling the APK.
android-debug-delete-db:
    adb shell am force-stop {{_android_pkg_debug}}
    adb shell rm -f {{_android_db_debug}} {{_android_db_debug}}-wal {{_android_db_debug}}-shm {{_android_db_debug}}-journal {{_android_db_debug}}.zip
    adb shell am start -n {{_android_pkg_debug}}/{{_android_activity}}
    @echo "DB deleted — app will prompt for download."

# --- Release ---

# Build a release APK only.
# Use this when preparing a distributable Android build for manual testing or release work.
android-release-build:
    dart run tool/generate_changelog.dart
    flutter build apk --release

# Build and install a release APK, push a local mobile DB from ../dpd-db, then launch.
# Use this to test a release build against a fresh local database export.
android-release-install: android-release-build (_android-install "app-release.apk") (_android-push-db _android_pkg_release) (_android-launch _android_pkg_release)

# Build and install a release APK with cleared app data and no DB push.
# Use this to test the real first-run experience where the app downloads the
# database itself on launch.
android-release-install-no-db: android-release-build (_android-install "app-release.apk")
    adb shell pm clear {{_android_pkg_release}}
    adb shell am start -n {{_android_pkg_release}}/{{_android_activity}}

# Rebuild the packaged mobile database in the sibling ../dpd-db repo.
# Use this only when the database export itself needs to be regenerated locally.
build-db:
    cd ../dpd-db && uv run python exporter/mobile/mobile_exporter.py --cone --peu --wordnet

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
