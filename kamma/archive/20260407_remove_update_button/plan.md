# Plan: Remove "Update Now" button from settings

## Phase 1: Remove button and clean up

- [x] Task 1: Edit `lib/widgets/settings_panel.dart`
  - [x] Remove `app_update_provider.dart` import (unused after button removal)
  - [x] Remove `database_update_service.dart` import (DbStatus only used in isUpdating)
  - [x] Remove `appUpdateState` watcher and `isUpdating` variable
  - [x] Remove the `FilledButton.icon` "Update Now" button and its `Padding` wrapper
  - [x] Remove the `buildDivider` call that followed the button

- [x] Task 2: Phase verification — `flutter analyze` passes with no issues
