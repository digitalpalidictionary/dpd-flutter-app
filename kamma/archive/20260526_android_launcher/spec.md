# Spec: Android launcher — full app name + squircle icon fix

## Overview
Two Android-only launcher fixes. Does not affect anything inside the app.

## What it should do
1. The app label in the Android launcher reads "Digital Pāḷi Dictionary"
   (with diacritics) instead of "DPD".
2. The launcher icon renders cleanly with squircle/teardrop/circle masks —
   no white edges showing around the blue circle.

## Current behaviour
- `android/app/build.gradle.kts` sets the app label via
  `resValue("string", "app_name", "DPD")` for release.
- Adaptive icon background was `#ffffff`; logo PNG is a blue circle
  (`#00B2FF`) on a transparent background — white corners show on squircle.

## Assumptions
- Brand blue sampled from `assets/images/dpd-logo-dark-512.png` → `#00B2FF`.
- Debug label stays as "DPD Debug".

## How we'll know it's done
- Long-press icon in launcher → label reads "Digital Pāḷi Dictionary".
- Squircle, teardrop, and circle masks all show a solid blue shape with no
  white halo.

## What's not included
- iOS label, web/Windows/macOS/Linux icons.
- Any in-app text, splash, or theme changes.
