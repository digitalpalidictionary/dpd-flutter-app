# Plan: What's New Dialog After Update

## Phase 1 — Data layer

- [x] 1.1 Add `fetchReleaseNotes(tag)` to AppUpdateService — fetches `body` for a specific tag from GitHub API
- [x] 1.2 Add `lastSeenVersion` read/write to SharedPreferences (key: `last_seen_version`)

## Phase 2 — UI

- [x] 2.1 In app.dart startup logic, compare current version to stored last-seen version
- [x] 2.2 If newer: fetch release notes, show dialog (tag + scrollable notes + OK button)
- [x] 2.3 On OK: store current version as last-seen

## Phase 3 — Verification

- [x] 3.1 `flutter analyze` passes with no new issues
