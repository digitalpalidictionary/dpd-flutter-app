# Run on connected device/emulator
run:
    flutter run

# Run on Linux desktop
run-linux:
    flutter run -d linux

# Build and install debug APK without clearing app data
install:
    flutter build apk --debug && adb install -r build/app/outputs/flutter-apk/app-debug.apk

# Fresh install: wipe data, install APK, create storage dir, push DB
install-fresh:
    flutter build apk --debug && flutter install && adb shell mkdir -p /storage/emulated/0/Android/data/net.dpdict.dpd_flutter_app/files && adb push ../dpd-db/exporter/share/dpd-mobile.db /storage/emulated/0/Android/data/net.dpdict.dpd_flutter_app/files/dpd-mobile.db

# Build debug APK
build:
    flutter build apk --debug

# Build release APK
build-release:
    flutter build apk --release
    cp build/app/outputs/flutter-apk/app-release.apk build/app/outputs/flutter-apk/dpd.apk
    @echo "\nRelease APK: build/app/outputs/flutter-apk/dpd.apk"

# Analyze code
analyze:
    flutter analyze

# Run tests
test:
    flutter test

# Push dpd-mobile.db to connected Android device
push-mobile-db:
    adb push ../dpd-db/exporter/share/dpd-mobile.db /storage/emulated/0/Android/data/net.dpdict.dpd_flutter_app/files/dpd-mobile.db
