# Plan — strip `*` from irregular inflection stems

- [x] Fix `lib/models/inflection_table_builder.dart`
  - `extractWordForms`: irregular check + strip both `!` and `*`
  - `buildInflectionTable`: same two changes
- [x] Add `*` stripping to `lib/widgets/tap_search_wrapper.dart` `_cleanPali()`
- [x] Verify `lib/services/intent_service.dart` already strips `*` (allowlist)
- [x] Add regression tests
  - `test/models/inflection_table_builder_test.dart` — `!*` cases
  - `test/services/intent_service_test.dart` — leading-only `*pivi` → `pivi`
- [x] Run `flutter test` — new tests pass; one PRE-EXISTING unrelated failure
      (`all forms are occurring by default`) confirmed failing on clean `main`
