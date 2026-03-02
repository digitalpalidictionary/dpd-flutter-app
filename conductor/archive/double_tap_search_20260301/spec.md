# Spec: Double-Tap to Search

## Overview

Implement double-tap on any word in search results to initiate a new search for that word — matching the webapp's behavior where double-clicking any word searches for it.

## Technical Approach

Use Flutter's built-in `SelectionArea` widget to wrap the results list. This provides:
- Native double-tap to select word behavior
- Single `onSelectionChanged` callback for the entire results area
- Works reliably across Android/iOS platforms

## Functional Requirements

### FR-1: SelectionArea Wrapper
- Create `DoubleTapSearchWrapper` widget that wraps any child with `SelectionArea`
- `SelectionArea` provides native text selection with double-tap word selection
- Single callback fires when any text in the wrapped area is selected

### FR-2: Selection Callback
- `onSelectionChanged: (SelectedContent? selection)` callback on SelectionArea
- Extract selected text via `selection?.plainText`
- Trigger search when selection is non-empty
- Use existing `doubleTapSearchProvider` to broadcast the selected word

### FR-3: Search Screen Integration
- Wrap the results list (`_SearchResults` widget) with `DoubleTapSearchWrapper`
- Keep existing listener in `SearchScreen` to handle provider updates
- Update text field and trigger search when word is selected

### FR-4: Revert Individual Widget Changes
The previous approach (per-widget SelectableText) didn't work reliably. Revert these files:
- `word_card.dart` — use regular `Text` widget
- `inline_entry_card.dart` — use regular `Text` widget  
- `accordion_card.dart` — use regular `Text` widget
- `entry_content.dart` — use regular `RichText` widget
- Delete `searchable_text.dart` — no longer needed

### FR-5: Exclude Interactive Elements
- Buttons should not trigger search when double-tapped
- SelectionArea naturally excludes some interactive elements
- Verify buttons don't cause unwanted searches

### FR-6: Examples Section
- The examples use `flutter_html` which renders native widgets
- SelectionArea should work with HTML content automatically
- If issues arise, can address separately

## Non-Functional Requirements

- **Platform Support**: Must work on Android (primary), iOS
- **Performance**: Minimal overhead from wrapping with SelectionArea
- **User Experience**: Selection handles and toolbar work natively

## UI/UX Details

### Before (Current Behavior)
1. User searches for a word
2. Results display with headwords and meanings
3. To search for a different word, user must type it in the search box

### After (Expected Behavior)
1. User searches for a word
2. Results display with headwords and meanings
3. User double-taps on any word in results
4. That word is automatically searched

## Acceptance Criteria
1. Double-tapping any word in search results triggers a new search for that word
2. Works in both inline and accordion display modes
3. Works on Android devices
4. Selection handles work natively after double-tap
5. Buttons do not trigger search when double-tapped

## Files to Modify

| File | Change |
|------|--------|
| `lib/widgets/double_tap_search_wrapper.dart` | NEW — SelectionArea wrapper widget |
| `lib/widgets/word_card.dart` | Revert to regular Text |
| `lib/widgets/inline_entry_card.dart` | Revert to regular Text |
| `lib/widgets/accordion_card.dart` | Revert to regular Text |
| `lib/widgets/entry_content.dart` | Revert to regular RichText |
| `lib/screens/search_screen.dart` | Wrap results with DoubleTapSearchWrapper |
| `lib/widgets/searchable_text.dart` | DELETE — not used |
| `lib/providers/double_tap_search_provider.dart` | Keep — used for cross-widget communication |

## Out of Scope
- Triple-tap or long-press to select (double-tap is sufficient)
- Modifying search algorithm
- Adding to entry screen (only search results)
