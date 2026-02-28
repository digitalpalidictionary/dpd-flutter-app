# Future TODOs

## Inflection  Tables

- [ ] Gray out unattested forms: bundle `all_tipitaka_words` set at build time, add `span.gray` styling for forms not found in the canon
- [ ] Remove `inflections_html` column from database to reduce DB size (once dynamic tables are verified)

## Family Tables

- [ ] Optimize mobile.db: copy only `data` + `count` columns from family tables (~10 MB total for all five), drop `html` column (useless for Flutter native widgets)
- [ ] Consider building family data from scratch via headword queries instead of pre-compiled tables — would eliminate family tables entirely but requires replicating `meaning_combo` and `degree_of_completion` logic in Dart
- [ ] Add build-and-cache strategy: compute family data on first access, store in memory cache with LRU eviction to bound memory usage
- [ ] Add clickable lemma links in family tables to navigate to other entries
