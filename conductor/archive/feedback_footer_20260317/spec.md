# Spec: Feedback Footer

## Overview

Add a persistent feedback footer bar at the bottom of all screens (Search, Entry, Root) with text: "Having a problem? Report it here" — where "here" is a tappable link that opens a Google Form in an external browser with device info pre-filled via URL parameters. This mirrors the existing feedback footer in the Chrome extension.

## Google Form Details

- **Form URL:** `https://docs.google.com/forms/d/e/1FAIpQLSd2Agk8K2EwAv-wXxxYw4Ud6rezW96BmMf2qPhrT3-0cW-ALQ/viewform`
- **Pre-fill parameters:**
  - `entry.405390413` = platform (Android, iOS, etc.)
  - `entry.671095698` = device model (e.g. "Pixel 9")
  - `entry.1162202610` = device OS version (e.g. "Android 15")
  - `entry.1433863141` = app version (e.g. "0.1.1")
  - `entry.100565099` = database version

## Functional Requirements

### FR-1: Device Info Collection

Collect five fields automatically:
1. **Platform** — Android, iOS, Linux, macOS, Windows (from `dart:io Platform`)
2. **Device model** — e.g. "Pixel 9", "iPhone 15" (from `device_info_plus`)
3. **OS version** — e.g. "Android 15", "iOS 17.4" (from `device_info_plus`)
4. **App version** — e.g. "0.1.1" (from `package_info_plus`)
5. **Database version** — from `dbUpdateProvider.localVersion`

### FR-2: Feedback URL Builder

An async function that gathers all five fields and constructs the full Google Form URL with values URI-encoded as query parameters.

### FR-3: Feedback Footer Widget

A `ConsumerWidget` displaying:
- Text: "Having a problem? Report it **here**"
- "here" is styled as a tappable link (blue, bold) matching `DpdFooter` style
- Thin top border using `DpdColors.primary` (1px, matching existing section footer pattern)
- Bottom safe area padding for notched devices
- Tapping "here" calls the URL builder and opens the form via `url_launcher`

### FR-4: Footer Placement

- **Search screen:** Feedback footer below the existing download footer. Both coexist in a `Column(mainAxisSize: MainAxisSize.min)`. Download footer collapses to `SizedBox.shrink` when inactive.
- **Entry screen:** Feedback footer as `bottomNavigationBar` on `_EntryView` Scaffold.
- **Root screen:** Feedback footer as `bottomNavigationBar` on `_RootView` Scaffold.

### FR-5: Theme Support

Footer must render correctly in both light and dark themes using existing `DpdColors` tokens.

## Existing Code to Reuse

| Resource | Location | Purpose |
|----------|----------|---------|
| `url_launcher` | `pubspec.yaml` | Open form URL in browser |
| `appVersionProvider` | `providers/settings_provider.dart:243` | App version string |
| `dbUpdateProvider.localVersion` | `providers/database_update_provider.dart:17` | Database version |
| `DpdFooter` | `widgets/entry_content.dart:171` | Style reference (fontSize 12.8, gray text, blue bold link) |
| `DpdColors` | `theme/dpd_colors.dart` | `primaryText`, `gray`, `primary` for borders |
| `_DownloadFooter` | `screens/search_screen.dart:1326` | Coexists; collapses when not downloading |
| `_platform()` | `utils/date_utils.dart:8` | Platform name pattern (but device_info_plus provides richer data) |

## New Dependency

- `device_info_plus` — provides device model and OS version
