# Plan: Gray Out Non-Occurring Inflection Forms

## Phase 1: Data Layer — Load Lookup Keys Set

- [x] Task: Add DAO method to fetch all lookup keys [4d4b34a]
  - [x] Write test for `getAllLookupKeys()` returning a `Set<String>`
  - [x] Implement `getAllLookupKeys()` in `dao.dart` — `SELECT lookup_key FROM lookup`
  - [x] Verify test passes

- [x] Task: Create Riverpod provider for lookup key set [bc17fb2]
  - [x] Create `lookup_keys_provider.dart` with a `FutureProvider<Set<String>>` that calls `dao.getAllLookupKeys()`
  - [x] Eagerly initialize the provider after UI loads (in the app's root widget or similar startup hook)
  - [x] Verify provider loads in background without blocking UI

## Phase 2: Inflection Builder — Add Occurring Flag

- [x] Task: Add `isOccurring` field to `InflectionForm` [cf69e8b]
  - [x] Write test: `buildInflectionTable` with a lookup set marks forms correctly
  - [x] Add `bool isOccurring` field (default `true`) to `InflectionForm`
  - [x] Add optional `Set<String>? lookupKeys` parameter to `buildInflectionTable()`
  - [x] Set `isOccurring = lookupKeys?.contains(word) ?? true` for each form
  - [x] Verify tests pass

## Phase 3: UI — Gray Styling

- [x] Task: Add gray color to theme [existing: DpdColors.gray = hsl(0,0%,50%)]
  - [x] `DpdColors.gray` already exists as `hsl(0, 0%, 50%)` — no changes needed

- [x] Task: Update `InflectionTable` widget to render non-occurring forms in gray [c1dbc81]
  - [x] Modify `_buildFormText()` to check `form.isOccurring`
  - [x] Non-occurring forms: render text in `DpdColors.gray`
  - [x] Blue highlight for `lookupKey` match takes precedence over gray
  - [x] Graceful degradation: if `isOccurring` is `true` (default), no change

- [x] Task: Wire lookup keys provider into `InflectionSection` [c1dbc81]
  - [x] Watch `lookupKeysProvider` in `InflectionSection`
  - [x] Pass the set (or `null` if not yet loaded) to `buildInflectionTable()`
  - [x] Verify inflection tables render with gray non-occurring forms

- [ ] Task: Conductor - User Manual Verification 'Gray Out Non-Occurring Inflection Forms' (Protocol in workflow.md)
