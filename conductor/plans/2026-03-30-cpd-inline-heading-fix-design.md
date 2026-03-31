# CPD Inline Heading Fix Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Render CPD `h2` and `h3` tags inline on the Flutter side without modifying exported database HTML or CSS.

**Architecture:** Keep the database/export pipeline unchanged and localize the fix to `DictHtmlCard`, which already contains per-dictionary HTML preparation and style mapping. Add a focused widget test first, then add CPD-only heading style overrides so CPD headings render as plain bold inline text while Cone and MW behavior remains unchanged.

**Tech Stack:** Flutter, Dart, `flutter_test`, `flutter_widget_from_html`

---

### Task 1: Add Failing Widget Test

**Files:**
- Create: `test/widgets/dict_html_card_test.dart`
- Modify: `lib/widgets/dict_html_card.dart`

**Step 1: Write the failing test**

Create a widget test that pumps `DictHtmlCard` with `dictId: 'cpd'` and HTML containing inline text before and after `<h2>` and `<h3>`. Assert the rendered widget tree preserves a single flowing line intent by verifying CPD heading tags are converted to non-heading inline semantics in the Flutter-side rendering path.

**Step 2: Run test to verify it fails**

Run: `flutter test test/widgets/dict_html_card_test.dart`
Expected: FAIL because CPD headings are still rendered as block headings.

**Step 3: Write minimal implementation**

Add CPD-only preprocessing and/or tag-specific style handling in `DictHtmlCard` so `h2` and `h3` render inline and bold with reset spacing.

**Step 4: Run test to verify it passes**

Run: `flutter test test/widgets/dict_html_card_test.dart`
Expected: PASS.

### Task 2: Verify No Regression For Other Dictionaries

**Files:**
- Modify: `test/widgets/dict_html_card_test.dart`

**Step 1: Write the failing/guard test**

Add a second expectation showing the CPD-only transformation does not apply to a non-CPD dictionary.

**Step 2: Run test to verify behavior**

Run: `flutter test test/widgets/dict_html_card_test.dart`
Expected: PASS with both CPD-specific and non-CPD expectations.

**Step 3: Run targeted verification**

Run: `flutter test test/widgets/dict_html_card_test.dart`
Expected: PASS.
