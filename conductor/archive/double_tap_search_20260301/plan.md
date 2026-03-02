# Plan: Double-Tap to Search Feature

## Goal
Implement double-tap on any word in search results to initiate a new search for that word — matching web app behavior.

## What Was Tried (Failed)
- Individual `SelectableText` widgets with `onSelectionChanged` callback per widget
- The callback wasn't triggering properly on Android devices
- Complex to maintain (had to update every text widget)

## Approach: SelectionArea

Use Flutter's built-in `SelectionArea` widget to wrap the entire results list. This:
- Enables selection behavior across the entire subtree
- Has a single `onSelectionChanged` callback that fires when any text is selected
- Works natively with double-tap to select words
- Much simpler than wrapping individual widgets

### How It Works
```dart
SelectionArea(
  onSelectionChanged: (SelectedContent? selection) {
    if (selection != null) {
      final text = selection.plainText;
      if (text.isNotEmpty) {
        // Trigger search for selected text
      }
    }
  },
  child: // results list
)
```

## Implementation Steps

### 1. Create wrapper widget
Create `lib/widgets/double_tap_search_wrapper.dart`:
- Accepts a `child` widget
- Wraps with `SelectionArea`
- Listens to `onSelectionChanged`
- Triggers search via `doubleTapSearchProvider`

### 2. Update SearchScreen
- Wrap the results list with `DoubleTapSearchWrapper`
- Remove individual `SearchableText`/`SearchableRichText` from cards
- Keep the provider listener to handle search trigger

### 3. Revert previous widget changes
- Restore `word_card.dart` to use regular `Text` widgets
- Restore `inline_entry_card.dart` to use regular `Text`
- Restore `accordion_card.dart` to use regular `Text`
- Restore `entry_content.dart` to use regular `RichText`

### 4. Examples section
- SelectionArea should automatically work with flutter_html content
- If not, we can address later

## Files to Modify

| File | Change |
|------|--------|
| `conductor/tracks/double_tap_search_20260301/plan.md` | This plan |
| `lib/widgets/double_tap_search_wrapper.dart` | NEW - SelectionArea wrapper |
| `lib/widgets/word_card.dart` | Revert to regular Text |
| `lib/widgets/inline_entry_card.dart` | Revert to regular Text |
| `lib/widgets/accordion_card.dart` | Revert to regular Text |
| `lib/widgets/entry_content.dart` | Revert to regular RichText |
| `lib/screens/search_screen.dart` | Wrap results in DoubleTapSearchWrapper |

## Decisions

1. **When to trigger search?** → On any selection (simpler, works for long-press too)
2. **Examples section?** → Let SelectionArea handle it naturally
3. **Clear selection?** → No, leave for user to manage

## Success Criteria
- [ ] Double-tap on any word in results triggers new search
- [ ] Works on both inline and accordion display modes
- [ ] Works on Android
