# Run on connected device/emulator
run:
    flutter run

# Run on Linux desktop
run-linux:
    flutter run -d linux

# Install debug APK on connected Android device
install:
    flutter install

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
