# Beta Tester Guide

Thank you for helping test the Digital Pāḷi Dictionary app.

This beta version is intended for testing before wider release. If you find bugs, installation problems, dictionary mistakes, or anything confusing, please send feedback.

## Download The Latest Release

- Releases page: <https://github.com/digitalpalidictionary/dpd-flutter-app/releases>
- Latest release: <https://github.com/digitalpalidictionary/dpd-flutter-app/releases/latest>

On the latest release page, download the `.apk` file listed under **Assets**.

## Install On Android

Because this app is not installed from the Google Play Store, Android may warn you that installation from this source is blocked.

To install it:

1. Download the latest `.apk` file from the release page.
2. Open the downloaded `.apk` on your Android device.
3. If Android blocks the install, allow installation from that source when prompted.
4. The setting is commonly called `Install unknown apps` or `Allow from this source`.
5. After allowing it, return to the APK and continue the installation.

Notes:

- The exact setting name and menu path vary by Android version and device manufacturer.
- The permission is usually granted to the app you used to open the APK, such as your browser or file manager.
- Android still shows its normal package installer confirmation screen before the app is installed.

On first launch, the app will download the dictionary database. This may take a few minutes depending on your connection speed.

## How Updates Work

The app can check for new releases published on GitHub.

- If a newer app version is available, the app can download the new APK for you and then open Android's installer.
- Android still requires you to confirm the installation step. App updates are not fully silent.
- The dictionary database can also update automatically in the background.
- If the app is set to download updates on Wi-Fi only, background downloads will wait for Wi-Fi.

During beta testing, expect updates every few days to once a week. After release, updates will slow down to roughly once a month.

In short:

- App update: automatic check/download, then Android asks you to approve install.
- Database update: automatic background download and apply.

## How To Send Feedback

At the bottom of every screen you will see:

**`Having a problem? Report it here`**

Please tap this link to report anything you notice, including:

- installation problems
- search problems
- layout or display issues
- crashes or freezes
- confusing or unexpected behaviour
- anything that does not feel right

The form is pre-filled with your device and app version, so you just need to describe the problem. Every report helps, no matter how small.

For feedback about specific words, grammar, or definitions, you can also use the `feedback` button at the bottom of any dictionary entry.

## Quick Troubleshooting

### The APK will not install

- Re-open the APK after allowing installs from that source.
- If needed, try opening the file from your browser downloads list or your file manager again.

### The app does not update immediately

- Make sure the device has internet access.
- Check whether updates are limited to Wi-Fi in the app settings.
- You can also use the app's `Update Now` button in Settings.

### I found a dictionary mistake

- Open the entry, tap the `feedback` button at the bottom, and choose `Correct a mistake`.
