# Plan: Search History & Navigation

## Phase 1: State — History Provider [checkpoint: adf7ecf]

- [x] Task: Create history provider [a89336b]
    - [ ] Create `lib/providers/history_provider.dart`
    - [ ] Define inline `HistoryState` value class: `List<String> entries`, `int currentIndex`
    - [ ] Define `HistoryNotifier extends StateNotifier<HistoryState>` with methods:
        - `add(String term)` — prepend to front, reset index to 0, deduplicate
        - `goBack()` — increment index (older)
        - `goForward()` — decrement index (newer)
        - `clear()` — reset to empty state
    - [ ] Define derived providers: `canGoBackProvider`, `canGoForwardProvider`
    - [ ] Persist entries list to SharedPreferences on each change (key: `dpd_history`)
    - [ ] Load entries from SharedPreferences on init

- [x] Task: Conductor - User Manual Verification 'Phase 1'

---

## Phase 2: UI — Integration into Search Screen

- [x] Task: Add back/forward buttons to search screen [8b557a3]
    - [ ] Modify `lib/screens/search_screen.dart`
    - [ ] Add ← / → `IconButton`s inline in the existing search bar `Row`
    - [ ] Enabled/disabled state from `canGoBackProvider` / `canGoForwardProvider`
    - [ ] On tap: call `goBack()` / `goForward()`, update `searchQueryProvider` with navigated term

- [x] Task: Create history panel widget [714432a]
    - [ ] Create `lib/widgets/history_panel.dart`
    - [ ] Collapsible section (collapsed state is local `bool` in the widget)
    - [ ] Header row: "History" label + clear icon button + collapse toggle (▼/▲)
    - [ ] Body: horizontal `SingleChildScrollView` of tappable term chips
        - Tap on a term: update `searchQueryProvider` + call `add(term)` to move it to front
    - [ ] Only visible when history is non-empty
    - [ ] Integrate into `search_screen.dart` above the results area

- [ ] Task: Wire search actions to history
    - [ ] On `_onSearch()`: call `historyNotifier.add(query)` if query is non-empty
    - [ ] On double-tap search: also calls `add(query)` (via existing provider hook)

- [ ] Task: Conductor - User Manual Verification 'Phase 2'
