---
# Bug Fix: App update must wait for database download to complete

## Overview
The app update check fires independently of the database download, causing a race condition. When the app installs an APK update while the database is still downloading, Android kills the app mid-download. On restart the database file is locked or corrupt, producing `SqliteException(5): database is locked`.

## What it should do
- The app update check (`appUpdateProvider.checkForUpdates()`) must not run until `dbUpdateProvider` has reached a stable `DbStatus.ready` state.
- If a DB download/extraction is in progress when the APK reaches `readyToInstall`, the install must be deferred until DB status returns to `ready`.
- APK downloads may overlap with DB downloads (no corruption risk). Only APK install (which kills the app) is dangerous and must be gated.
- The deferred install must fire exactly once — not on every subsequent `ready` transition.

## Constraints
- All changes in `lib/app.dart` only — sequencing logic, not provider internals.
- Manual listeners must be stored and cleaned up in `dispose()`.
- A single `_maybeInstallAppUpdate()` helper must be the sole path to `installUpdate()`, ensuring DB status is re-read immediately before install.
- Must not delay app startup when no DB download is needed.

## How we'll know it's done
- App update check only fires after `dbUpdateProvider.status == DbStatus.ready`.
- APK install only fires when DB status is `ready`, verified by re-reading state immediately before install.
- Deferred install fires exactly once via a `_appInstallPending` flag.
- All manual listeners are cleaned up in `dispose()`.
- Tests cover: immediate fire when DB ready, deferred check when DB busy, deferred install when DB busy, install fires once when DB becomes ready.

## What's not included
- Changes to download resume logic, foreground service, or notification handling.
- Any UI changes to the update flow.
- Changes to provider internals (`AppUpdateNotifier`, `DbUpdateNotifier`).
