# Plan: Android Back Button Navigation

## Phase 1: Analysis and Setup
- [x] Review current SearchScreen structure and `_onClear()` implementation
- [x] Identify the exact widget tree location to add PopScope
- [x] Confirm which state variables represent active UI that should intercept back:
  - [x] `_controller.text` — search query
  - [x] `_overlayEntry` — autocomplete dropdown
  - [x] `_helpOverlayEntry` / `_showHelpPopup` — velthuis help overlay
  - [x] `_infoOverlayEntry` — info popup overlay
  - [x] `_activeInfo` — active info content view (bibliography/thanks)
  - [x] `_showSettingsPanel` — settings side panel (Linux only, always false on Android)
  - [x] `_showHistoryPanel` — history side panel (Linux only, always false on Android)
- [x] Note: on Android, settings/history are modal sheets with their own back handling — no action needed for those

## Phase 2: Implement Back Button Handler
- [x] Create `_hasActiveBackInterceptState()` that returns true when any of the following is true:
  - [x] `_controller.text.isNotEmpty`
  - [x] `_overlayEntry != null`
  - [x] `_showHelpPopup`
  - [x] `_infoOverlayEntry != null`
  - [x] `_activeInfo != null`
- [x] Create `_clearAllActiveState()` that dismisses all active UI (used only by back button):
  - [x] Close info popup: `_removeInfoOverlay()` + `setState(() => _activeInfo = null)`
  - [x] Close velthuis help: `_hideVelthuisHelp()`
  - [x] Clear search/autocomplete/focus: call `_onClear()`
  - [x] Note: settings/history panels omitted — always false on Android; modal sheets handle their own back
- [x] Add `PopScope` wrapper around the `Scaffold` return in `build()`:
  - [x] `canPop: !_hasActiveBackInterceptState()`
  - [x] `onPopInvokedWithResult: (didPop, _) { if (!didPop) _clearAllActiveState(); }`
- [x] Gate behavior to Android only: when not on Android, `_hasActiveBackInterceptState()` always returns false (allows default pop)

## Phase 3: Test and Verify
- [ ] Test on Android device/emulator:
  - [ ] Back button clears active search text
  - [ ] Back button closes autocomplete dropdown
  - [ ] Back button closes velthuis help overlay
  - [ ] Back button closes info popup overlay
  - [ ] Back button clears active info content view (bibliography/thanks)
  - [ ] Back button exits app when no active state remains
- [ ] Verify no regressions:
  - [ ] X button still works as before (behavior unchanged)
  - [ ] Double-tap word search still works
  - [ ] Modal sheets (settings/history on mobile) dismiss correctly with their own back handling
- [ ] Verify non-Android platforms keep current behavior (no PopScope interception)

## Phase 4: Phase Completion
- [x] Verify all tasks in this plan are complete
- [ ] Confirm spec requirements are met:
  - [ ] Back button clears search when active
  - [ ] Back button allows exit when search is clear and no overlays are open
  - [ ] Behavior matches X button functionality for search state
- [ ] Run linter and check for any issues
