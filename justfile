# Run on connected device/emulator
run:
    flutter run

# Run on Linux desktop
run-linux:
    flutter run -d linux

# Build and install debug APK on connected Android device
install:
    flutter build apk --debug && flutter install

# Build debug APK
build:
    flutter build apk --debug

# Build release APK
build-release:
    flutter build apk --release

# Analyze code
analyze:
    flutter analyze

# Run tests
test:
    flutter test

# Push dpd.db to connected Android device
push-db:
    adb push ../dpd-db/dpd.db /storage/emulated/0/Android/data/net.dpdict.dpd_flutter_app/files/dpd.db
