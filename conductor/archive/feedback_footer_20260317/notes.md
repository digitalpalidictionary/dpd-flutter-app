# Feedback Footer — Investigation Notes

## Existing Footer Patterns

### DpdFooter (entry_content.dart:171)
- Style: `fontSize: 12.8`, `color: DpdColors.gray`
- Link style: `color: DpdColors.primaryText`, `fontWeight: FontWeight.w700`
- Top border: `DpdColors.primary`, 1px
- Uses `GestureDetector` + `launchUrl()`

### _DownloadFooter (search_screen.dart:1326)
- Returns `SizedBox.shrink()` when not downloading/extracting
- Handles its own bottom padding via `MediaQuery.of(context).padding.bottom`
- When stacking with feedback footer, download footer should NOT add bottom padding — feedback footer handles it

## Safe Area Consideration
- Only the bottom-most widget in the `bottomNavigationBar` Column should handle safe area padding
- When download footer is active, it sits above feedback footer — so feedback footer always owns the bottom padding
