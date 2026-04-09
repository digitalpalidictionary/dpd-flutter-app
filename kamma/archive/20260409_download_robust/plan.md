# Plan: Robust Download Experience

Affected files:
- `lib/services/database_update_service.dart` — main download/extract logic
- `lib/services/foreground_download_service.dart` — Android notification wrapper (unchanged, but now called by service)
- `lib/providers/database_update_provider.dart` — state management, will be simplified
- `lib/screens/download_screen.dart` — UI (cancel button, status labels)

---

## Phase 1: Consolidate download service

### [x] 1.1 Inject ForegroundDownloadController into DatabaseUpdateService
### [x] 1.2 Move foreground lifecycle into downloadAndInstall
### [x] 1.3 Simplify provider download methods
### [x] 1.4 Verify phase 1

---

## Phase 2: Stall detection + cancel support + reduced timeout

### [x] 2.1 Add CancelToken support to DatabaseUpdateService
### [x] 2.2 Add stall detection timer
### [x] 2.3 Reduce receiveTimeout
### [x] 2.4 Wire cancel into provider
### [x] 2.5 Verify phase 2

---

## Phase 3: Stream zip extraction + remove silent double-download

### [x] 3.1 Stream zip extraction from disk
### [x] 3.2 Remove silent double-download on corrupt zip
### [x] 3.3 Verify phase 3

---

## Phase 4: Status label for resume fallback + UI cancel button

### [x] 4.1 Add onStatusLabel callback to downloadAndInstall
### [x] 4.2 Wire status label into provider state
### [x] 4.3 Show status label in download screen
### [x] 4.4 Add Cancel button to download screen
### [x] 4.5 Verify phase 4

---

## Phase 5: Final verification
### [x] 5.1 Read every changed file for end-to-end correctness.
### [x] 5.2 Run `flutter analyze` — zero errors.
### [x] 5.3 Run full test suite — all pass (2 pre-existing dict_provider failures unrelated to this work).
