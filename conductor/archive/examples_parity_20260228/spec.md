# Spec: Examples Tab Webapp Parity

## Overview

Achieve pixel-level visual and structural parity between the Flutter app's Examples
section and the DPD webapp's examples display. Seven distinct divergences were found by
comparing the webapp HTML/CSS against the Flutter widget code.

## Reference

- Webapp HTML: `../dpd-db/exporter/webapp/templates/dpd_headword.html` (lines 1177–1210)
- Webapp CSS: `../dpd-db/exporter/webapp/static/dpd.css`
- Flutter widget: `lib/widgets/entry_content.dart` (`EntryExampleBlock`)
- Flutter card: `lib/widgets/accordion_card.dart`
- Flutter bottom sheet: `lib/widgets/entry_bottom_sheet.dart`
- Flutter screen: `lib/screens/entry_screen.dart`

## Functional Requirements

### FR-1: Button Label — Singular vs Plural

The webapp uses two distinct computed properties on `DpdHeadword`:

- `needs_example_button`: `meaning_1 AND example_1 AND NOT example_2` → button label **"example"** (singular, lowercase)
- `needs_examples_button`: `meaning_1 AND example_1 AND example_2` → button label **"examples"** (plural, lowercase)

Flutter currently always uses the label `'Examples'`. It must match the webapp:

- One example only → `'example'`
- Two examples → `'examples'`

The same label logic applies in `EntryScreen` (the `ExpansionTile` title).

### FR-2: Source/Sutta Text Colour

CSS: `p.sutta { color: var(--primary-text); }` — the cyan primary-text colour, mapped to
`DpdColors.primaryText` in Flutter.

Flutter currently uses `theme.colorScheme.outline` (a muted grey). Must change to
`DpdColors.primaryText`.

### FR-3: Source/Sutta Separator

Webapp renders: `{{d.i.source_1}} {{d.i.sutta_1|safe}}` — source and sutta joined with a
**single space**, no separator character.

Flutter currently joins with `' · '`. Must change to a single space `' '`.

### FR-4: Sutta Field HTML Rendering

The `sutta_1` / `sutta_2` fields may contain HTML anchor tags, e.g.:

```html
<a class="sutta_link" href="https://suttacentral.net/sn1.1">SN 1.1</a>
```

CSS for `a.sutta_link`:
```css
a.sutta_link {
  color: var(--primary-text);   /* cyan */
  font-style: italic;
  text-decoration: none;
  font-weight: bold;
}
a.sutta_link:hover {
  color: var(--primary-alt);
  text-decoration: underline;
}
```

Webapp renders sutta with `|safe`. Flutter currently renders sutta as plain `Text()`,
stripping any HTML. The sutta/source line must be rendered via `flutter_html` so that
anchor links are tappable and styled correctly.

### FR-5: Container Horizontal Padding

Webapp `div.dpd`: `padding: 3px 7px` (7 px horizontal).

Flutter's examples content is wrapped in `Padding(horizontal: 16)` (16 px). This must
change to **7 px** to match the webapp.

### FR-6: Inter-Example Spacing

Webapp: consecutive `<p>` blocks with `margin: 0px` — no explicit gap between examples.

Flutter: `SizedBox(height: 16)` between the two example blocks. This must be removed.

### FR-7: Feedback Footer

Webapp shows a footer inside the examples container:

```html
<p class="dpd-footer">
    Can you think of a better example?
    <a class="dpd-link"
        href="https://docs.google.com/forms/d/e/1FAIpQLSf9boBe7k5tCwq7LdWgBHHGIPVc4ROO5yjVDo1X5LDAxkmGWQ/viewform?usp=pp_url&entry.438735500={id}%20{lemma_link}&entry.326955045=Examples&entry.1433863141=DPD+{date}"
        target="_blank">
        Add it here.</a>
</p>
```

CSS:
```css
p.dpd-footer {
  border-top: 1px solid var(--primary);
  font-size: 80%;       /* ~11.2 px at 14 px base */
  padding: 5px 0px;
  margin-top: 5px;
}
.dpd-link {
  color: var(--primary-text);
  font-weight: 700;
  text-decoration: none;
}
```

Flutter must add an equivalent footer widget (`EntryExampleFooter`) at the bottom of the
examples section (inside the `DpdSectionContainer`), with:

- Top divider: 1 px border in primary colour
- Margin top: 5 px
- Padding: 5 px top/bottom
- Text: `"Can you think of a better example? "` at 80 % of body font size
- Tappable `"Add it here."` — `DpdColors.primaryText`, bold, no underline
- Tap opens URL in external browser via `url_launcher`
- URL parameters: `entry.438735500={id}%20{lemma_url}`, `entry.326955045=Examples`,
  `entry.1433863141=DPD+{date}` where date is `YYYY-MM-DD`

## Non-Functional Requirements

- Changes must apply consistently across all three entry display contexts:
  `AccordionCard`, `EntryBottomSheet`, `EntryScreen`.
- `url_launcher` is already in `pubspec.yaml`.
- The footer link opens in an external browser (not a WebView).

## Acceptance Criteria

- [ ] Button reads "example" (singular) when only one example exists
- [ ] Button reads "examples" (plural) when two examples exist
- [ ] Source/sutta text is `DpdColors.primaryText` (cyan), italic
- [ ] Source and sutta are joined with a single space, no `·` separator
- [ ] Sutta field is rendered as HTML; `sutta_link` anchors are tappable and styled
- [ ] Container horizontal padding is 7 px (matching `div.dpd`)
- [ ] No gap between example 1 block and example 2 block
- [ ] Feedback footer appears after all examples with correct text, colours, and URL
- [ ] All three display contexts (AccordionCard, BottomSheet, EntryScreen) show the same result

## Out of Scope

- Changes to the `DpdSectionContainer` outer border or outer margin
- Changes to any section other than Examples
- iOS-specific URL handling
