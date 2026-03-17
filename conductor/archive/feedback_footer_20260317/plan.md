# Plan: Feedback Footer

## Context

DPD users are non-technical and won't use GitHub issues. A persistent feedback footer linking to a Google Form lets them report app/UI/UX issues easily. The form auto-fills device info via URL parameters.

## Phase 1: Dependency & URL Helper

- [x] Task 1.1: Add `device_info_plus` to `pubspec.yaml` dependencies
  - Add after `package_info_plus` (line ~51)
  - Run `flutter pub get`

- [x] Task 1.2: Create `lib/utils/app_feedback_url.dart` — async URL builder function
  - Get platform from `dart:io Platform`
  - Get device model and OS version from `DeviceInfoPlugin()`
  - Get app version from `PackageInfo.fromPlatform()`
  - Accept `dbVersion` as parameter
  - URI-encode all values into query params
  - Return full Google Form URL string

- [x] Task 1.3: Write tests for URL builder function
  - Test URL structure and parameter encoding
  - Test with null/empty database version

## Phase 2: Footer Widget

- [x] Task 2.1: Create `lib/widgets/feedback_footer.dart` — `ConsumerWidget`
  - Text: "Having a problem? Report it **here**"
  - Style: fontSize 12.8, `DpdColors.gray` for text, `DpdColors.primaryText` + bold for "here"
  - Thin top border: `DpdColors.primary`, 1px
  - Read `dbUpdateProvider.localVersion` for database version
  - On tap: call `buildFeedbackUrl()` then `launchUrl()`
  - Handle safe area bottom padding via `MediaQuery.of(context).padding.bottom`

## Phase 3: Screen Integration

- [x] Task 3.1: Update `SearchScreen` (`search_screen.dart:305`)
  - Change `bottomNavigationBar` from `_DownloadFooter()` to a `Column(mainAxisSize: MainAxisSize.min)` with `_DownloadFooter()` on top and `FeedbackFooter()` below
  - Remove bottom padding from `_DownloadFooter` (line 1360) — `FeedbackFooter` handles safe area

- [x] Task 3.2: Add `FeedbackFooter` as `bottomNavigationBar` to `_EntryView` Scaffold (`entry_screen.dart:75`)

- [x] Task 3.3: Add `FeedbackFooter` as `bottomNavigationBar` to `_RootView` Scaffold (`root_screen.dart:76`)

## Key Files

| File | Action |
|---|---|
| `pubspec.yaml` | Add `device_info_plus` |
| `lib/utils/app_feedback_url.dart` | New — URL builder |
| `lib/widgets/feedback_footer.dart` | New — footer widget |
| `lib/screens/search_screen.dart` | Update `bottomNavigationBar`, adjust `_DownloadFooter` |
| `lib/screens/entry_screen.dart` | Add `bottomNavigationBar` |
| `lib/screens/root_screen.dart` | Add `bottomNavigationBar` |

## Verification

1. `flutter pub get` — dependency resolution
2. `flutter analyze` — no errors
3. Footer visible on all 3 screens (Search, Entry, Root)
4. "here" link opens Google Form with all 5 fields correctly pre-filled
5. Download footer still appears above feedback footer during updates
6. Footer respects dark/light theme
7. Safe area works on notched devices
