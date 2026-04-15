## Thread: 20260415_search_input_fixes
Search bar input fixes — sutta codes, numbers, punctuation stripping

## Phase 1: Fix search input behavior

- [ ] Disable autocorrect on search TextField
  - File: `lib/screens/search_screen.dart` (~line 500)
  - Add `autocorrect: false`, `enableSuggestions: false` to TextField
  → verify: type "sn12.1" — no auto-space after dot

- [ ] Update ASCII regex to include digits and dots
  - File: `lib/utils/transliteration.dart` (line 9)
  - Change `^[a-zA-Z\s]+$` to `^[a-zA-Z0-9.\s]+$`
  → verify: toRoman("sn12.1") returns "sn12.1" unchanged

- [ ] Strip ? and ! from DB queries
  - File: `lib/database/dao.dart` (line 573-581)
  - Add .replaceAll('?', '').replaceAll('!', '') to _normalizeQuery
  → verify: searching "ko?" returns same results as "ko"

- [ ] Strip ? and ! in search screen before autocomplete/provider
  - File: `lib/screens/search_screen.dart` in _onChanged and _onSearch
  - Strip after toRoman() call
  → verify: autocomplete for "ko?" shows same suggestions as "ko"

- [ ] Phase 1 verification
  → verify: type "sn12.1" (no space, results appear), type "ko?" (finds "ko"), type ".tii.na" (still converts to ṭīṇa)
