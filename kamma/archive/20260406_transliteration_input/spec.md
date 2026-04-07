# Transliteration Input Support

## Overview
Allow users to search using any Brahmic or romanization input script. Input is auto-detected and converted to Roman (IAST) for DB lookup. The search bar always displays what the user typed. Uses `indic_transliteration_dart` (pure Dart, no FFI). Addresses GitHub issue #8.

## What it should do
1. User types in any supported script (Devanagari, ITRANS, Velthuis, Bengali, etc.).
2. **Velthuis only**: ASCII sequences convert live in the text field as the user types (`aa→ā`, `.t→ṭ`, `~n→ñ`, etc.).
3. **All other scripts**: text field is never modified. The field always shows what the user typed.
4. Background (debounced) search fires as the user types — for all scripts, including Brahmic.
5. Explicit search (button or Enter) also converts and searches — field stays unchanged.
6. Display is always Roman (IAST). No display transliteration.
7. A Velthuis help popup (the `?` button in the search bar) guides users on Velthuis input.

## Constraints
- DB queries always use Roman (IAST).
- Text field is only ever written by Velthuis live conversion — never by `toRoman()`.
- Pure Dart package only — no FFI (avoids 16 KB ELF alignment issues on Android 15+).
- No user setting for input script — auto-detection handles everything.

## How we'll know it's done
- Devanagari: type `धम्म`, results appear while typing, field stays in Devanagari throughout.
- Pressing search with Devanagari in the field: results update, field stays Devanagari.
- Velthuis: type `raaga`, field converts live to `rāga`, results show rāga entries.
- IAST: type `rāga` directly, works as before.
- Double-tap word search: field updates to the tapped word in Roman (external sync path).

## What's not included
- Display transliteration (always Roman/IAST).
- Per-user input script setting.
- Thai/Sinhala (not auto-detected by `indic_transliteration_dart` — would need explicit scheme selection).
