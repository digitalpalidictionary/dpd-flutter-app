# Family Tables — Investigation Notes

## DB Field Delimiters
- `family_set` → delimiter is `'; '` (semicolon + space), NOT `' '`
- `family_idioms` → delimiter is `' '` (space)
- `family_compound` → delimiter is `' '` (space)

## Python Model: Button Visibility Logic
Source: `../dpd-db/db/models.py`

```python
# lemma_clean strips trailing number: 'kata 1' → 'kata'
lemma_clean = re.sub(r" \d.*$", "", lemma_1)

needs_root_family_button  → bool(family_root)           # no meaning_1 check
needs_word_family_button  → bool(family_word)            # no meaning_1 check
needs_compound_family_button  → meaning_1 AND cf_set membership check (complex)
needs_compound_families_button → meaning_1 AND cf_set membership check (complex)
needs_idioms_button → meaning_1 AND idioms_set membership check
needs_set_button   → meaning_1 AND family_set AND len == 1
needs_sets_button  → meaning_1 AND family_set AND len > 1
```

**Key rule**: `meaning_1` check required for idioms, sets, and compound families.

## Flutter Field Names (DpdHeadwordWithRoot)
- `h.meaning1` — nullable, maps to DB `meaning_1`
- `h.familyRoot` — nullable
- `h.familyWord` — nullable
- `h.familyCompound` — nullable
- `h.familyIdioms` — nullable
- `h.familySet` — nullable
- `h.rootKey` — nullable (required for root family lookup)

## Idioms: Missing Keys Problem
Many `family_idioms` values (e.g. `'kakkasa'`) do NOT exist in the `family_idiom` table.
- `family_idiom` table has 1162 rows; no idiom PKs contain spaces
- Python model uses `idioms_set` (pre-computed set of all PKs) to filter
- Flutter fix: add `meaning1` check + hide button retroactively when DAO returns empty

## Button Label Conventions
- Webapp CSS `a.dpd-button` does NOT apply `text-transform: uppercase`
- Flutter convention for buttons: sentence-case (Grammar, Notes, Declension/Conjugation)
- Family buttons MUST match Flutter convention: 'Root family', 'Word family', etc.

## Family Table Column Colors (from webapp CSS)
```css
table.family th { color: var(--primary-text); }  /* lemma column → DpdColors.primaryText (blue) */
table.family td.completion { color: var(--gray); } /* completion → DpdColors.gray */
```
- Lemma (th/bold) column: `DpdColors.primaryText` (blue + bold)
- POS column: bold, default theme color
- Meaning column: regular, default theme color
- Completion column: `DpdColors.gray`

## Loading Glitch
- `FamilyLoadingSpinner` shows briefly before data arrives (when null)
- Fix: return `SizedBox.shrink()` for null data — show nothing until full data loads
- Only exception: if we need a visible loading indicator for very slow loads (not needed in practice)

## Widgets Using FamilyStateMixin
1. `family_toggle_section.dart` — standalone, used by `entry_screen.dart`
2. `inline_entry_card.dart` — unified button row with Grammar/Examples/Inflections
3. `accordion_card.dart` — unified button row, only shown when card expanded
4. `entry_bottom_sheet.dart` — unified button row in bottom sheet

## entry_screen.dart Notes
- Uses `ConsumerWidget` (not stateful)
- Uses `ExpansionTile` for Grammar/Examples/Inflections sections
- Wraps `FamilyToggleSection` for family buttons (separate widget)
- No family button unification needed here (different architecture)
