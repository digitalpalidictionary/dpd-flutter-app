# ---------- DART & FLUTTER ----------


# Run on connected device/emulator
run:
    flutter run

# Analyze code
analyze:
    flutter analyze

# Run tests
test:
    flutter test


# ---------- ANDROID ----------

_android_pkg := "net.dpdict.dpd_flutter_app.debug"
_android_db_dir := "/storage/emulated/0/Android/data/" + _android_pkg + "/files"
_android_db_path := _android_db_dir + "/dpd-mobile.db"
_local_db := "../dpd-db/exporter/share/dpd-mobile.db"

# Build, install debug APK, push DB, then launch — all in one
android-run:
    flutter build apk --debug
    adb install -r build/app/outputs/flutter-apk/app-debug.apk
    adb shell mkdir -p {{_android_db_dir}}
    adb push {{_local_db}} {{_android_db_path}}
    adb shell am start -n {{_android_pkg}}/net.dpdict.dpd_flutter_app.MainActivity

# Build and install debug APK without clearing app data
android-install:
    flutter build apk --debug && adb install -r build/app/outputs/flutter-apk/app-debug.apk

# Push DB and restart the running app
android-push-db:
    adb shell mkdir -p {{_android_db_dir}}
    adb push {{_local_db}} {{_android_db_path}}
    adb shell am force-stop {{_android_pkg}}
    adb shell am start -n {{_android_pkg}}/net.dpdict.dpd_flutter_app.MainActivity
    @echo "DB pushed and app restarted."

# Build debug APK
android-build:
    flutter build apk --debug

# Build release APK
android-build-release:
    flutter build apk --release
    cp build/app/outputs/flutter-apk/app-release.apk build/app/outputs/flutter-apk/dpd.apk
    @echo "\nRelease APK: build/app/outputs/flutter-apk/dpd.apk"

# Rebuild mobile DB in dpd-db repo
build-db:
    cd ../dpd-db && uv run python exporter/mobile/mobile_exporter.py

# ---------- LINUX ----------

# Build and run Linux
linux-run:
    flutter build linux --debug && flutter run -d linux

# Copy dpd-mobile.db to Linux app support directory (for linux-run)
linux-push-db:
    cp ../dpd-db/exporter/share/dpd-mobile.db ~/Documents/dpd-mobile.db
