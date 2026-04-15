# Plan: Remove showExactResults Setting
## Thread ID: 20260415_remove_exact_filter

---

## Phase 1 — Remove showExactResults from all files

### Task 1.1 — `lib/providers/settings_provider.dart` [x]
Remove all traces of `showExactResults`:
- Field declaration: `final bool showExactResults;`
- Constructor default: `this.showExactResults = true,`
- `copyWith` parameter: `bool? showExactResults,` and the assignment line
- `==` operator check: `other.showExactResults == showExactResults &&`
- `hashCode` entry: `showExactResults,` in `Object.hash(...)`
- `_load()` read: `final showExactResults = _prefs.getBool('show_exact_results') ?? true;`
- `_load()` state assignment: `showExactResults: showExactResults,`
- `setShowExactResults()` method (lines ~271–274)

→ verify: `grep -rn showExactResults lib/` returns zero results

---

### Task 1.2 — `lib/widgets/settings_panel.dart` [x]
Remove the "Exact results" `ListTile` block (the `() => ListTile(title: const Text('Exact results'), ...)` entry in `itemBuilders`). Also remove the trailing comma/divider if it causes a gap. The "Partial results" and "Fuzzy results" tiles must remain untouched.

→ verify: `grep -n "Exact results" lib/widgets/settings_panel.dart` returns zero results

---

### Task 1.3 — `lib/screens/search_screen.dart` [x]
In `_buildBody()`, currently (around lines 777–794):

```dart
final visibleExact = settings.showExactResults
    ? exact
    : <DpdHeadwordWithRoot>[];
final visibleDictExact = settings.showExactResults
    ? dictExact
    : <DictResult>[];
```

Replace:
- `visibleExact` → use `exact` directly everywhere it appears (passed to `SplitResultsList` as `exact:` and used in the empty-check condition)
- `visibleDictExact` → use `dictExact` directly everywhere it appears

Also update the empty-check condition (lines ~796–808) which references `visibleExact` and `visibleDictExact`.

Also update the `SplitResultsList(...)` call which passes `exact: visibleExact` and `dictExact: visibleDictExact`.

The `settings` local variable may still be needed for other settings (`showSummary`, `displayMode`, etc.) — do NOT remove it.

→ verify: `grep -n "visibleExact\|visibleDictExact\|showExactResults" lib/screens/search_screen.dart` returns zero results

---

### Task 1.4 — Phase verification [x]
Run Flutter analyzer to confirm no new errors were introduced.

→ verify: `flutter analyze` completes with no errors (warnings are acceptable if pre-existing)

---

## Commit guidance (do NOT commit — suggest only)

**Message:** `fix: exact search results are now always shown`

**Body:**
- Removed `showExactResults` setting — there is no valid reason to hide exact matches
- Deleted "Exact results" Show/Hide tile from the settings panel
- `exact` and `dictExact` results are now passed unconditionally to the results list
