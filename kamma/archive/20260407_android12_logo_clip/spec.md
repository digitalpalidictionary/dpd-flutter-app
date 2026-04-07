# Spec: Android 12 splash logo clipped

## Overview
The DPD logo was being clipped on Android 12+ splash screen because Android 12's Splash Screen API
crops the icon to a circle covering only the inner 66.7% of the drawable area.

## What it should do
- The splash screen logo should be fully visible on all Android versions
- The full "dpd" circle should appear unclipped on first launch

## Constraints
- Must use flutter_native_splash for asset generation
- Cannot change the logo itself — only its padding/placement in the android12 variant
- Dark mode variant also needs the same fix

## How we'll know it's done
- Build and install the app on Android 12+ device
- The DPD logo circle appears fully visible, not clipped

## What's not included
- iOS or web changes
- Changes to the non-Android-12 splash (pre-API-31)
