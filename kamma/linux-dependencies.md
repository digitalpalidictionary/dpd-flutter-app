# Linux Dependencies

This document lists system-level dependencies required to build and run the DPD Flutter app on Linux.

## Build Dependencies

These packages are required to compile the Flutter Linux desktop application:

```bash
# Ubuntu/Debian
sudo apt-get install clang cmake ninja-build pkg-config libgtk-3-dev liblzma-dev libstdc++-12-dev
```

## Runtime Dependencies

These packages are required for audio playback via `just_audio`:

```bash
# Ubuntu/Debian
sudo apt-get install libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev gstreamer1.0-plugins-good gstreamer1.0-plugins-base
```

### Full GStreamer Installation (recommended)

For complete audio codec support:

```bash
sudo apt-get install libgstreamer1.0-dev \
  libgstreamer-plugins-base1.0-dev \
  libgstreamer-plugins-bad1.0-dev \
  gstreamer1.0-plugins-base \
  gstreamer1.0-plugins-good \
  gstreamer1.0-plugins-bad \
  gstreamer1.0-plugins-ugly \
  gstreamer1.0-libav \
  gstreamer1.0-tools \
  gstreamer1.0-x
```

### Alternative Distributions

**Fedora/RHEL:**
```bash
sudo dnf install gstreamer1-devel gstreamer1-plugins-good gstreamer1-plugins-base
```

**Arch Linux:**
```bash
sudo pacman -S gstreamer
```

## Missing Dependency Symptoms

If GStreamer is not installed, audio playback will fail silently:
- Tapping the play button shows a disabled "no entry" cursor
- The audio button enters errored state immediately after clicking
- No audio plays, and the button remains grayed out
