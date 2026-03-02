# Plan: Native Root Matrix Widget

## Context

The root matrix button exists but shows a "coming soon" placeholder. The matrix classifies all headwords derived from a root into a grid of POS × modifier (caus, pass, desid, intens, deno, and compound combinations). The Python exporter (`root_matrix.py`) pre-computes this as HTML, but we need a native Flutter widget built from raw data at runtime.

All required source columns (`lemma_1`, `pos`, `root_key`, `root_base`, `grammar`) already exist in the Flutter DB schema. The largest root has ~800 headwords — a fast query. We'll compute eagerly in the background (like bases) so data is ready when the user taps "root matrix".

## Algorithm

The classification is entirely data-driven — one function `_classifyModifier(rootBase)` handles the modifier detection for all POS types. The modifier priority order (compound before single):

1. `caus & pass` → both `\bcaus\b` and `\bpass\b`
2. `desid & caus` → both `\bdesid\b` and `\bcaus\b`
3. `desid & pass` → both `\bdesid\b` and `\bpass\b` (**prp only**)
4. `intens & caus` → both `\bintens\b` and `\bcaus\b`
5. `deno & caus` → both `\bdeno\b` and `\bcaus\b`
6. `caus` → `\bcaus\b`
7. `pass` → `\bpass\b`
8. `intens` → `\bintens\b`
9. `desid` → `\bdesid\b`
10. `deno` → `\bdeno\b`
11. (none) → base form

Special POS routing (checked in order):
- `pos` in {pr, imp, opt, perf, imperf, aor, fut, cond, abs, ger, inf} → verbs
- `pos == "prp"` → participles
- `pos == "pp"` → participles
- `pos == "adj"` + `grammar` matches `\bpp\b` → participles/pp
- `grammar` matches `\bapp\b` (any pos) → participles/app (no modifier classification)
- `pos == "ptp"` → participles
- `pos == "adj"` + `grammar` contains "ptp" → participles/ptp
- `pos == "masc"` → nouns
- `pos == "root"` + `grammar` contains "masc" → nouns/masc
- `pos == "fem"` → nouns
- `pos == "card"` + `grammar` contains "fem" → nouns/fem
- `pos == "nt"` → nouns
- `lemma_1 == "sogandhika 3"` → nouns/nt (hardcoded special case)
- `pos == "adj"` → adjectives
- `pos == "suffix"` + `root_base` contains "adj" → adjectives
- `pos == "ind"` → adverbs
- `pos == "suffix"` (fallthrough) → adverbs

## Changes

### 1. DAO — `lib/database/dao.dart`

Add method:
```dart
Future<List<({String lemma1, String pos, String rootBase, String grammar})>>
    getHeadwordsForRootMatrix(String rootKey) async {
  // SELECT lemma_1, pos, root_base, grammar FROM dpd_headwords
  // WHERE root_key = ? AND root_key != ''
  // Returns lightweight tuples (not full DpdHeadword rows)
}
```

### 2. Root Matrix Builder — `lib/widgets/root_matrix_builder.dart` (new)

Pure logic file, no widgets. Contains:

- `RootMatrixData` — typed structure: `Map<String, Map<String, List<String>>>` with categories (verbs, participles, nouns, adjectives, adverbs) → subcategories → lemma lists
- `buildRootMatrix(List<records> headwords)` — classifies headwords using data-driven approach
- `_classifyModifier(String rootBase)` — returns modifier suffix string
- `_superscriptNumbers(String lemma)` — converts trailing digits to Unicode superscripts (replicates `superscripter_uni`)

### 3. Root Matrix Widget — `lib/widgets/root_matrix_table.dart` (new)

Native Flutter widget. Takes `RootMatrixData`. Renders:
- Category headers (verbs, participles, nouns, adjectives, adverbs) — bold, spanning full width
- Each non-empty subcategory row: **bold label** | comma-separated lemmas
- Only shows categories that have at least one non-empty subcategory
- Uses same `Table` layout pattern as `RootInfoTable`

### 4. Provider — `lib/providers/database_provider.dart`

Add `rootMatrixProvider` — `FutureProvider.autoDispose.family` that fetches headwords and builds the matrix. Eagerly watched in `build()` of both root widgets (same pattern as `basesForRootProvider`).

### 5. Wire Up — `lib/screens/root_screen.dart` & `lib/widgets/inline_root_card.dart`

Replace `_buildPlaceholderSection('Root Matrix')` with `RootMatrixTable` wrapped in `DpdSectionContainer` + `DpdFooter`. Eagerly watch `rootMatrixProvider` in `build()`.

### 6. Update TODO — `conductor/todo.md`

Mark root matrix entry as done.

## Key Files

| File | Action |
|---|---|
| `lib/database/dao.dart` | Add `getHeadwordsForRootMatrix()` |
| `lib/widgets/root_matrix_builder.dart` | New — classification logic |
| `lib/widgets/root_matrix_table.dart` | New — native table widget |
| `lib/providers/database_provider.dart` | Add `rootMatrixProvider` |
| `lib/screens/root_screen.dart` | Replace placeholder, eager watch |
| `lib/widgets/inline_root_card.dart` | Replace placeholder, eager watch |
| `conductor/todo.md` | Mark done |

## Reference

- Python builder: `/home/bodhirasa/MyFiles/3_Active/dpd-db/db/families/root_matrix.py`
- Superscripter: `/home/bodhirasa/MyFiles/3_Active/dpd-db/tools/superscripter.py`
- Existing pattern: `basesForRootProvider` in `database_provider.dart`
- Existing widget pattern: `RootInfoTable` in `lib/widgets/root_info_table.dart`

## Verification

1. `dart analyze lib/` — no issues
2. Search for "gam" → root matrix button shows native table with verbs/participles/nouns sections
3. Search for "har" → all four √har roots show matrix data
4. Category headers only appear when they have populated rows
5. Lemma numbers display as Unicode superscripts (e.g., "gacchati¹")
6. Data loads eagerly — no visible delay when clicking "root matrix"
7. Works in both inline and root screen modes
