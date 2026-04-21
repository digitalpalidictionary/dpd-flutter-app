# Plan: Construction in summary toggle

## Phase 1 — Setting model + persistence

- [x] Add `showConstructionInSummary` field to `Settings` class in
      `lib/providers/settings_provider.dart`
  - default `true`
  - include in `copyWith`, `==`, `hashCode`
  → verify: `dart analyze lib/providers/settings_provider.dart` reports no errors

- [x] Add `_load()` read and `setShowConstructionInSummary()` method in `SettingsNotifier`
  - key: `'show_construction_in_summary'`
  → verify: same analyze check

## Phase 2 — Summary provider wires the flag

- [x] In `lib/providers/summary_provider.dart`, watch `settingsProvider` inside
      `summaryEntriesProvider` and pass `showConstruction` bool to `buildSummaryEntries`
- [x] Add `showConstruction` parameter (default `true`) to `buildSummaryEntries` and
      `_buildHeadwordSummaryMeaning`; when `false`, skip appending `[$summary]`
  → verify: `dart analyze lib/providers/summary_provider.dart` no errors

## Phase 3 — Settings UI

- [x] In `lib/widgets/settings_panel.dart`, insert a new `ListTile` with
      `CompactSegmented<bool>` for `showConstructionInSummary` immediately before the
      "Grammar button" tile (after the divider at line ~116)
  - title: `'Construction in summary'`
  - segments: `Hide` (false) / `Show` (true)
  → verify: `dart analyze lib/widgets/settings_panel.dart` no errors

## Phase 4 — Full analysis

- [x] Run `dart analyze lib/` and confirm zero new errors
  → verify: touched files are clean; remaining `lib/` warnings are pre-existing in benchmarks/transliterator files
