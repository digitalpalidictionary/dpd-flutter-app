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

# Build and install debug APK without clearing app data
android-install:
    flutter build apk --debug && adb install -r build/app/outputs/flutter-apk/app-debug.apk

# Fresh install: wipe data, install APK, create storage dir, push DB
android-install-fresh:
    flutter build apk --debug && adb install -r build/app/outputs/flutter-apk/app-debug.apk && adb shell mkdir -p /storage/emulated/0/Android/data/net.dpdict.dpd_flutter_app.debug/files && adb push ../dpd-db/exporter/share/dpd-mobile.db /storage/emulated/0/Android/data/net.dpdict.dpd_flutter_app.debug/files/dpd-mobile.db

# Build debug APK
android-build:
    flutter build apk --debug

# Build release APK
android-build-release:
    flutter build apk --release
    cp build/app/outputs/flutter-apk/app-release.apk build/app/outputs/flutter-apk/dpd.apk
    @echo "\nRelease APK: build/app/outputs/flutter-apk/dpd.apk"


# Rebuild mobile DB in dpd-db repo and copy to share
build-db:
    cd ../dpd-db && uv run python exporter/mobile/mobile_exporter.py

# Push dpd-mobile.db to connected Android device (debug build)
android-push-db:
    adb push ../dpd-db/exporter/share/dpd-mobile.db /storage/emulated/0/Android/data/net.dpdict.dpd_flutter_app.debug/files/dpd-mobile.db

# ---------- LINUX ----------

# Run on Linux desktop
linux-run:
    flutter run -d linux

# Copy dpd-mobile.db to Linux app support directory (for linux-run)
linux-push-db:
    cp ../dpd-db/exporter/share/dpd-mobile.db ~/Documents/dpd-mobile.db
