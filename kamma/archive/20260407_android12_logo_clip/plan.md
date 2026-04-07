# Plan: Android 12 splash logo clipped

## Phase 1: Fix Android 12 splash image padding

### Task 1.1 — Create padded android12 logo variants
- [x] Use ImageMagick to create `dpd-logo-android12.png`: 512×512 canvas, logo scaled to 341px (66.7%), centered, transparent bg
- [x] Do the same for `dpd-logo-dark-android12.png`

### Task 1.2 — Update flutter_native_splash config
- [x] In `pubspec.yaml`, point `android_12.image` → `dpd-logo-android12.png`
- [x] Point `android_12.image_dark` → `dpd-logo-dark-android12.png`

### Task 1.3 — Regenerate splash assets
- [x] Run `dart run flutter_native_splash:create`
- [x] Verify the generated android12splash.png images show the padded logo

### Phase 1 Verification
- [x] Verified generated xxxhdpi android12splash.png shows logo centered with padding
- [x] User confirmed fix works on device via `just android-update`
