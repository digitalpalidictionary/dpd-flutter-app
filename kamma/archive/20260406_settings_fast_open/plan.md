# Plan: Settings Panel Performance Fix

## Phase 1: Replace CompactSegmented with lightweight widget
- [x] 1.1 Rewrite `CompactSegmented` in `compact_segmented.dart` — replace the
      `SegmentedButton` wrapper with a simple `Row` of styled `GestureDetector`
      containers using theme colors
- [x] 1.2 Remove the deferred loading hack (`_showFullContent` / `_SettingsContentLoading`)
      from `settings_panel.dart` — no longer needed when widgets are fast
- [x] 1.3 Verify: all settings toggles render correctly and respond to taps
