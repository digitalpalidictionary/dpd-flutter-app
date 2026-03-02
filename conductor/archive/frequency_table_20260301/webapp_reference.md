# Frequency Table — Webapp Visual Reference

This document captures every visual detail needed to build a pixel-perfect Flutter replica of the webapp frequency table. It is the single source of truth during implementation. Do NOT re-read the webapp source files — everything is here.

---

## 1. SECTION STRUCTURE

The frequency section is inside a container div with:
- 2px solid border, color `--primary` (hsl(198, 100%, 50%))
- border-radius: 7px
- padding: 3px 7px
- line-height: 150%

Contents in order:
1. Heading paragraph
2. Frequency table (the `freq_html`)
3. Corpus legend (4 `<p>` blocks)
4. Explanation link paragraph
5. Footer paragraph

---

## 2. HEADING

```html
<p class="heading underlined">
    Frequency of <b>lemma</b> and its declensions
</p>
```

CSS:
```css
p.heading {
  margin: 0px 0px;
  padding: 2px 0px;
}
.underlined {
  border-bottom: 1px solid var(--primary);   /* hsl(198, 100%, 50%) */
  margin-bottom: 5px;
}
```

Heading text variants (from `FreqHeading` JSON field):
- Declensions: `Frequency of <b>word</b> and its declensions`
- Conjugations: `Frequency of <b>word</b> and its conjugations`
- Indeclinable: `Frequency of <b>word</b>`
- No matches: `There are no exact matches of <b>word</b>`

---

## 3. BUTTON

```html
<a class="dpd-button" href="#" data-target="frequency_{{lemma}}">frequency</a>
```

CSS:
```css
a.dpd-button {
  background-color: var(--primary);          /* hsl(198, 100%, 50%) */
  border: 1px solid var(--primary);
  border-radius: 7px;
  color: var(--dark);                        /* hsl(198, 100%, 5%) */
  cursor: pointer;
  display: inline-block;
  font-size: 80%;
  font-weight: 400;
  margin: 1px 1px 2px 1px;
  padding: 2px 5px;
  text-decoration: none;
  user-select: none;
  box-shadow: 2px 2px 4px hsla(0, 0%, 20%, 0.4);
}

a.dpd-button.active {
  background-color: var(--primary-alt);      /* hsl(205, 100%, 40%) */
  border-color: var(--primary-alt);
  color: var(--light);                       /* hsl(198, 100%, 95%) */
}
```

In Flutter: uses existing `DpdSectionButton` widget. Position: LAST button (after all family buttons).

---

## 4. TABLE CSS

### Table element
```css
table.freq {
  border-radius: 7px;
  border-collapse: separate;
  border: none;
}
```

### Header cells (thead th)
```css
table.freq thead th {
  text-align: center;
}
```

### Body header cells (tbody th) — row labels
```css
table.freq tbody th {
  border: 1px solid var(--primary);           /* hsl(198, 100%, 50%) */
  border-radius: 7px;
  padding: 5px 10px;
  text-align: center;
  width: 1ex;
  vertical-align: middle;
}
```

### Data cells (td) — frequency numbers
```css
table.freq td {
  border-collapse: separate;
  border-radius: 7px;
  border: 1px solid var(--gray-transparent);  /* hsla(0, 0%, 50%, 0.25) */
  font-size: 0.8em;
  min-width: 30px;
  text-align: center;
  vertical-align: middle;
  white-space: nowrap;
  width: 2.5em;
}
```

### Special cell types
```css
table.freq td.void {
  border: 0px solid transparent;              /* invisible, no content */
}

table.freq td.gap {
  border: 0px solid transparent;
  width: 10px;                                /* spacing between corpus groups */
}
```

### Vertical text (category labels: Vinaya, Sutta, Abhidhamma, Aññā)
```css
.vertical-text {
  text-orientation: upright;
  inline-size: fit-content;
  word-break: break-all;
  max-width: 1ex;
  white-space: break-spaces;
  align-items: center;
}
```

---

## 5. GRADIENT COLORS (11 LEVELS)

### CSS Variables
```
--freq0:  hsla(198, 90%, 50%, 0.1)    /* nearly invisible */
--freq1:  hsla(200, 90%, 50%, 0.2)    /* very light blue */
--freq2:  hsla(202, 90%, 50%, 0.3)
--freq3:  hsla(204, 90%, 50%, 0.4)
--freq4:  hsla(206, 90%, 50%, 0.5)
--freq5:  hsla(208, 90%, 50%, 0.6)
--freq6:  hsla(210, 90%, 50%, 0.7)
--freq7:  hsla(212, 90%, 50%, 0.8)
--freq8:  hsla(214, 90%, 50%, 0.9)
--freq9:  hsla(216, 90%, 50%, 1.0)
--freq10: hsla(218, 90%, 50%, 1.0)
```

### Gradient CSS rules
```css
/* gr0: zero frequency — text hidden, faint border */
table.freq td.gr0 {
  border: 1px solid var(--freq0);
  border-color: var(--gray-transparent);    /* hsla(0, 0%, 50%, 0.25) */
  color: transparent;
}

/* gr1–gr5: DARK text on LIGHT blue background */
table.freq td.gr1 { background-color: var(--freq1); border-color: var(--freq1); color: var(--dark); }
table.freq td.gr2 { background-color: var(--freq2); border-color: var(--freq2); color: var(--dark); }
table.freq td.gr3 { background-color: var(--freq3); border-color: var(--freq3); color: var(--dark); }
table.freq td.gr4 { background-color: var(--freq4); border-color: var(--freq4); color: var(--dark); }
table.freq td.gr5 { background-color: var(--freq5); border-color: var(--freq5); color: var(--dark); }

/* gr6–gr10: LIGHT text on DARK blue background */
table.freq td.gr6  { background-color: var(--freq6);  border-color: var(--freq6);  color: var(--light); }
table.freq td.gr7  { background-color: var(--freq7);  border-color: var(--freq7);  color: var(--light); }
table.freq td.gr8  { background-color: var(--freq8);  border-color: var(--freq8);  color: var(--light); }
table.freq td.gr9  { background-color: var(--freq9);  border-color: var(--freq9);  color: var(--light); }
table.freq td.gr10 { background-color: var(--freq10); border-color: var(--freq10); color: var(--light); }
```

### Dark mode overrides
```css
.dark-mode table.freq td {
  color: var(--light);                       /* all cells get light text */
}
.dark-mode table.freq td.gr0 {
  border: 1px solid var(--freq0);
  border-color: var(--gray-transparent);
  color: transparent;                        /* gr0 stays hidden in dark mode */
}
```

### Flutter color values (already in DpdColors.freq)
```
freq[0]  = HSLα(198, 90%, 50%, 0.1)
freq[1]  = HSLα(200, 90%, 50%, 0.2)
freq[2]  = HSLα(202, 90%, 50%, 0.3)
freq[3]  = HSLα(204, 90%, 50%, 0.4)
freq[4]  = HSLα(206, 90%, 50%, 0.5)
freq[5]  = HSLα(208, 90%, 50%, 0.6)
freq[6]  = HSLα(210, 90%, 50%, 0.7)
freq[7]  = HSLα(212, 90%, 50%, 0.8)
freq[8]  = HSLα(214, 90%, 50%, 0.9)
freq[9]  = HSLα(216, 90%, 50%, 1.0)
freq[10] = HSLα(218, 90%, 50%, 1.0)
```

Text color rule: gr0 = transparent, gr1–5 = dark (hsl(198,100%,5%)), gr6–10 = light (hsl(198,100%,95%))

---

## 6. COMPLETE TABLE STRUCTURE — EVERY ROW, EVERY CELL

### Column layout (13 visible columns + 4 gap columns)

```
Col 0:  Vertical category label (Vinaya/Sutta/Abhidhamma/Aññā)
Col 1:  Row label (Pārājika, Dīgha, etc.)
Col 2:  CST M (mūla)
Col 3:  CST A (aṭṭhakathā)
Col 4:  CST Ṭ (ṭīkā)
Col 5:  [gap]
Col 6:  BJT M
Col 7:  BJT A
Col 8:  [gap]
Col 9:  SYA M
Col 10: SYA A
Col 11: [gap]
Col 12: SC M
```

### Header Row 1 — Corpus names
```
(empty) | (empty) | CST (colspan=3, title="Chaṭṭha Saṅgāyana Tipiṭaka (Myanmar)") | (empty) | BJT (colspan=2, title="Buddha Jayanti Tipiṭaka (Sri Lanka)") | (empty) | SYA (colspan=2, title="Syāmaraṭṭha 1927 Royal Edition (Thailand)") | (empty) | MST (colspan=1, title="Mahāsaṅgīti Tipiṭaka (Sutta Central)")
```

### Header Row 2 — Sub-column labels
```
(empty) | (empty) | M (title="mūla") | A (title="aṭṭhakathā") | Ṭ (title="ṭīkā") | (empty) | M (title="mūla") | A (title="aṭṭhakathā") | (empty) | M (title="mūla") | A (title="aṭṭhakathā") | (empty) | M (title="mūla")
```

Note: Header row 2 has `style="text-align: right;"`

### Data index mapping — JSON array index → table cell

Format: `CorpusFreq[index]` / `CorpusGrad[index]`

#### VINAYA SECTION (vertical-text rowspan="6", meaning 5 data rows + 1 header row)

| Row | Label | CST M | CST A | CST Ṭ | BJT M | BJT A | SYA M | SYA A | SC M |
|-----|-------|-------|-------|-------|-------|-------|-------|-------|------|
| Pārājika | | Cst[0] | Cst[19] | Cst[33] **rs5** | Bjt[0] | Bjt[19] | Sya[0] **rs2** | Sya[17] **rs5** | Sc[0] |
| Pācittiya | | Cst[1] | Cst[20] | _(spanned)_ | Bjt[1] | Bjt[20] | _(spanned)_ | _(spanned)_ | Sc[1] |
| Mahāvagga | | Cst[2] | Cst[21] | _(spanned)_ | Bjt[2] | Bjt[21] | Sya[1] | _(spanned)_ | Sc[2] |
| Cūḷavagga | | Cst[3] | Cst[22] | _(spanned)_ | Bjt[3] | Bjt[22] | Sya[2] | _(spanned)_ | Sc[3] |
| Parivāra | | Cst[4] | Cst[23] | _(spanned)_ | Bjt[4] | Bjt[23] | Sya[3] | _(spanned)_ | Sc[4] |

**rs5** = rowspan="5", **rs2** = rowspan="2"

#### SUTTA SECTION (vertical-text rowspan="8", meaning 7 data rows + 1 header row)

| Row | Label | CST M | CST A | CST Ṭ | BJT M | BJT A | SYA M | SYA A | SC M |
|-----|-------|-------|-------|-------|-------|-------|-------|-------|------|
| Dīgha | | Cst[5] | Cst[24] | Cst[34] | Bjt[5] | Bjt[24] | Sya[4] | Sya[18] | Sc[5] |
| Majjhima | | Cst[6] | Cst[25] | Cst[35] | Bjt[6] | Bjt[25] | Sya[5] | Sya[19] | Sc[6] |
| Saṃyutta | | Cst[7] | Cst[26] | Cst[36] | Bjt[7] | Bjt[26] | Sya[6] | Sya[20] | Sc[7] |
| Aṅguttara | | Cst[8] | Cst[27] | Cst[37] | Bjt[8] | Bjt[27] | Sya[7] | Sya[21] | Sc[8] |
| Khuddaka 1 | | Cst[9] | Cst[28] | **void** | Bjt[9] | Bjt[28] | Sya[8] | Sya[22] | Sc[9] |
| Khuddaka 2 | | Cst[10] | Cst[29] | **void** | Bjt[10] | Bjt[29] | Sya[9] | Sya[23] | Sc[10] |
| Khuddaka 3 | | Cst[11] | Cst[30] | Cst[38] | Bjt[11] | Bjt[30] | Sya[10] | Sya[24] | Sc[11] |

Note: CST Ṭ for Khuddaka 1 and 2 = **void** (no ṭīkā exists for those)

#### ABHIDHAMMA SECTION (vertical-text rowspan="8", meaning 7 data rows + 1 header row)

| Row | Label | CST M | CST A | CST Ṭ | BJT M | BJT A | SYA M | SYA A | SC M |
|-----|-------|-------|-------|-------|-------|-------|-------|-------|------|
| Dhammasaṅgaṇī | | Cst[12] | Cst[31] **rs7** | Cst[39] **rs7** | Bjt[12] | Bjt[31] | Sya[11] | Sya[25] **rs7** | Sc[12] |
| Vibhaṅga | | Cst[13] | _(spanned)_ | _(spanned)_ | Bjt[13] | Bjt[32] | Sya[12] | _(spanned)_ | Sc[13] |
| Dhātukathā | | Cst[14] | _(spanned)_ | _(spanned)_ | Bjt[14] | Bjt[33] | Sya[13] **rs2** | _(spanned)_ | Sc[14] |
| Puggalapaññatti | | Cst[15] | _(spanned)_ | _(spanned)_ | Bjt[15] | Bjt[34] | _(spanned)_ | _(spanned)_ | Sc[15] |
| Kathāvatthu | | Cst[16] | _(spanned)_ | _(spanned)_ | Bjt[16] | Bjt[35] | Sya[14] | _(spanned)_ | Sc[16] |
| Yamaka | | Cst[17] | _(spanned)_ | _(spanned)_ | Bjt[17] | Bjt[36] | Sya[15] | _(spanned)_ | Sc[17] |
| Paṭṭhāna | | Cst[18] | _(spanned)_ | _(spanned)_ | Bjt[18] | Bjt[37] | Sya[16] | _(spanned)_ | Sc[18] |

**rs7** = rowspan="7", **rs2** = rowspan="2"

#### AÑÑĀ SECTION (vertical-text rowspan="10", meaning 9 data rows + 1 header row)

| Row | Label | CST M | CST A | CST Ṭ | BJT M | BJT A | SYA M | SYA A | SC M |
|-----|-------|-------|-------|-------|-------|-------|-------|-------|------|
| Visuddhimagga | | **void** | Cst[32] | Cst[40] | **void** | Bjt[38] | **void** | Sya[26] | **void** |
| Leḍī Sayāḍo | | **void** | **void** | Cst[41] | — | — | — | — | — |
| Buddhavandanā | | **void** | **void** | Cst[42] | — | — | — | — | — |
| Vaṃsa | | **void** | **void** | Cst[43] | — | — | — | — | — |
| Byākaraṇa | | **void** | **void** | Cst[44] | — | — | — | — | — |
| Pucchavissajjanā | | **void** | **void** | Cst[45] | — | — | — | — | — |
| Nīti | | **void** | **void** | Cst[46] | — | — | — | — | — |
| Pakiṇṇaka | | **void** | **void** | Cst[47] | — | — | — | — | — |
| Sihaḷa | | **void** | **void** | Cst[48] | — | — | — | — | — |

**CRITICAL:** Rows 2–9 of Aññā (Leḍī through Sihaḷa) only have 3 cells each: void, void, CstṬ. They have NO gap cells, NO BJT/SYA/SC columns. The row simply ends after the CST Ṭ value.

---

## 7. ROWSPAN SUMMARY

All rowspans in the table:

| Location | Cell | Index | Rowspan |
|----------|------|-------|---------|
| Vinaya, Pārājika | CST Ṭ | CstFreq[33] / CstGrad[33] | 5 |
| Vinaya, Pārājika | SYA M | SyaFreq[0] / SyaGrad[0] | 2 |
| Vinaya, Pārājika | SYA A | SyaFreq[17] / SyaGrad[17] | 5 |
| Abhidhamma, Dhammasaṅgaṇī | CST A | CstFreq[31] / CstGrad[31] | 7 |
| Abhidhamma, Dhammasaṅgaṇī | CST Ṭ | CstFreq[39] / CstGrad[39] | 7 |
| Abhidhamma, Dhammasaṅgaṇī | SYA A | SyaFreq[25] / SyaGrad[25] | 7 |
| Abhidhamma, Dhātukathā | SYA M | SyaFreq[13] / SyaGrad[13] | 2 |

---

## 8. JSON DATA STRUCTURE (freq_data column)

```json
{
  "FreqHeading": "Frequency of <b>word</b> and its declensions",
  "CstFreq": [49 ints],    "CstGrad": [49 ints 0-10],
  "BjtFreq": [39 ints],    "BjtGrad": [39 ints 0-10],
  "SyaFreq": [30 ints],    "SyaGrad": [30 ints 0-10],
  "ScFreq":  [19 ints],    "ScGrad":  [19 ints 0-10]
}
```

Array index breakdown:

**CST (49 entries):**
- 0–4: Vinaya M (Pārājika, Pācittiya, Mahāvagga, Cūḷavagga, Parivāra)
- 5–11: Sutta M (Dīgha, Majjhima, Saṃyutta, Aṅguttara, Khuddaka 1/2/3)
- 12–18: Abhidhamma M (Dhammasaṅgaṇī, Vibhaṅga, Dhātukathā, Puggalapaññatti, Kathāvatthu, Yamaka, Paṭṭhāna)
- 19–23: Vinaya A
- 24–30: Sutta A (Dīgha, Majjhima, Saṃyutta, Aṅguttara, Khuddaka 1/2/3)
- 31: Abhidhamma A (combined)
- 32: Visuddhimagga A
- 33: Vinaya Ṭ (combined)
- 34–38: Sutta Ṭ (Dīgha, Majjhima, Saṃyutta, Aṅguttara, Khuddaka 3) — NO Khuddaka 1/2
- 39: Abhidhamma Ṭ (combined)
- 40: Visuddhimagga Ṭ
- 41–48: CST-only Aññā Ṭ (Leḍī, Buddhavandanā, Vaṃsa, Byākaraṇa, Pucchavissajjanā, Nīti, Pakiṇṇaka, Sihaḷa)

**BJT (39 entries):**
- 0–4: Vinaya M
- 5–11: Sutta M
- 12–18: Abhidhamma M
- 19–23: Vinaya A
- 24–30: Sutta A
- 31–37: Abhidhamma A (individual: Dhammasaṅgaṇī, Vibhaṅga, Dhātukathā, Puggalapaññatti+, Kathāvatthu, Yamaka, Paṭṭhāna)
- 38: Visuddhimagga A

**SYA (30 entries):**
- 0–3: Vinaya M (Pārājika+Pācittiya combined [0], Mahāvagga [1], Cūḷavagga [2], Parivāra [3])
- 4–10: Sutta M (Dīgha, Majjhima, Saṃyutta, Aṅguttara, Khuddaka 1/2/3)
- 11–16: Abhidhamma M (Dhammasaṅgaṇī, Vibhaṅga, Dhātukathā+Puggalapaññatti [13], Kathāvatthu [14], Yamaka [15], Paṭṭhāna [16])
- 17: Vinaya A (combined)
- 18–24: Sutta A (Dīgha, Majjhima, Saṃyutta, Aṅguttara, Khuddaka 1/2/3)
- 25: Abhidhamma A (combined)
- 26: Visuddhimagga A
- 27–29: unused/extra (indices exist but map to Aññā items with value 0)

**SC (19 entries):**
- 0–4: Vinaya M
- 5–11: Sutta M
- 12–18: Abhidhamma M
- (SC has no A or Ṭ columns)

---

## 9. CORPUS LEGEND (below table)

Four separate `<p>` elements:
```html
<p><b>CST</b>: Chaṭṭha Saṅgāyana Tipiṭaka (Myanmar)</p>
<p><b>BJT</b>: Buddha Jayanti Tipiṭaka (Sri Lanka)</p>
<p><b>SYA</b>: Syāmaraṭṭha 1927 Royal Edition (Thailand)</p>
<p><b>MST</b>: Mahāsaṅgīti Tipiṭaka (Sutta Central)</p>
```

---

## 10. EXPLANATION LINK

```html
<p>
  For a detailed explanation of how this word frequency chart is calculated,
  it's accuracies and inaccuracies, please refer to
  <a class="dpd-link"
     href="https://digitalpalidictionary.github.io/features/frequency/"
     target="_blank">this webpage</a>.
</p>
```

---

## 11. FOOTER

```html
<p class="dpd-footer">
  If something looks out of place,
  <a class="dpd-link" href="[feedback form URL]" target="_blank">log it here.</a>
</p>
```

CSS:
```css
p.dpd-footer {
  border-top: 1px solid var(--primary);
  font-size: 80%;
  padding: 5px 0px;
  margin-top: 5px;
}
```

---

## 12. REAL EXAMPLE — "a 1.1" freq_html (from database)

This is the actual HTML stored in the database for entry "a 1.1". Use this as the ground truth for verifying your Flutter output.

```html
<table class="freq">
<thead>
<tr>
<th></th>
<th></th>
<th colspan="3" title="Chaṭṭha Saṅgāyana Tipiṭaka (Myanmar)"><b>CST</b></th>
<th></th>
<th colspan="2" title="Buddha Jayanti Tipiṭaka (Sri Lanka)"><b>BJT</b></th>
<th></th>
<th colspan="2" title="Syāmaraṭṭha 1927 Royal Edition (Thailand)"><b>SYA</b></th>
<th></th>
<th colspan="1" title="Mahāsaṅgīti Tipiṭaka (Sutta Central)"><b>MST</b></th>
</tr>
<tr style="text-align: right;">
<th></th>
<th></th>
<!-- CST -->
<th title="mūla">M</th>
<th title="aṭṭhakathā">A</th>
<th title="ṭīkā">Ṭ</th>
<th></th>
<!-- BJT -->
<th title="mūla">M</th>
<th title="aṭṭhakathā">A</th>
<th></th>
<!-- SYA -->
<th title="mūla">M</th>
<th title="aṭṭhakathā">A</th>
<th></th>
<!-- SC -->
<th title="mūla">M</th>
</tr>
</thead>
<tbody>
<tr>
<th class="vertical-text" rowspan="6">Vinaya</th>
</tr>
<tr>
<th>Pārājika</th>
<td class="gr1">1</td>
<td class="gr1">29</td>
<td class="gr1" rowspan="5">265</td>
<td class="gap"></td>
<td class="gr0">0</td>
<td class="gr1">215</td>
<td class="gap"></td>
<td class="gr0" rowspan="2">0</td>
<td class="gr0" rowspan="5">0</td>
<td class="gap"></td>
<td class="gr0">0</td>
</tr>
<tr>
<th>Pācittiya</th>
<td class="gr1">2</td>
<td class="gr0">0</td>
<td class="gap"></td>
<td class="gr0">0</td>
<td class="gr1">31</td>
<td class="gap"></td>
<td class="gap"></td>
<td class="gr0">0</td>
</tr>
<tr>
<th>Mahāvagga</th>
<td class="gr1">9</td>
<td class="gr0">0</td>
<td class="gap"></td>
<td class="gr0">0</td>
<td class="gr1">4</td>
<td class="gap"></td>
<td class="gr0">0</td>
<td class="gap"></td>
<td class="gr0">0</td>
</tr>
<tr>
<th>Cūḷavagga</th>
<td class="gr1">21</td>
<td class="gr0">0</td>
<td class="gap"></td>
<td class="gr0">0</td>
<td class="gr1">2</td>
<td class="gap"></td>
<td class="gr0">0</td>
<td class="gap"></td>
<td class="gr0">0</td>
</tr>
<tr>
<th>Parivāra</th>
<td class="gr1">31</td>
<td class="gr1">2</td>
<td class="gap"></td>
<td class="gr0">0</td>
<td class="gr1">5</td>
<td class="gap"></td>
<td class="gr0">0</td>
<td class="gap"></td>
<td class="gr0">0</td>
</tr>
<tr>
<th class="vertical-text" rowspan="8">Sutta</th>
</tr>
<tr>
<th>Dīgha</th>
<td class="gr1">4</td>
<td class="gr1">92</td>
<td class="gr1">314</td>
<td class="gap"></td>
<td class="gr1">13</td>
<td class="gr1">398</td>
<td class="gap"></td>
<td class="gr1">2</td>
<td class="gr1">4</td>
<td class="gap"></td>
<td class="gr0">0</td>
</tr>
<tr>
<th>Majjhima</th>
<td class="gr1">1</td>
<td class="gr1">103</td>
<td class="gr1">191</td>
<td class="gap"></td>
<td class="gr0">0</td>
<td class="gr2">498</td>
<td class="gap"></td>
<td class="gr0">0</td>
<td class="gr1">8</td>
<td class="gap"></td>
<td class="gr0">0</td>
</tr>
<tr>
<th>Saṃyutta</th>
<td class="gr0">0</td>
<td class="gr1">53</td>
<td class="gr1">41</td>
<td class="gap"></td>
<td class="gr0">0</td>
<td class="gr1">304</td>
<td class="gap"></td>
<td class="gr1">12</td>
<td class="gr1">4</td>
<td class="gap"></td>
<td class="gr0">0</td>
</tr>
<tr>
<th>Aṅguttara</th>
<td class="gr1">195</td>
<td class="gr1">78</td>
<td class="gr1">128</td>
<td class="gap"></td>
<td class="gr1">4</td>
<td class="gr1">391</td>
<td class="gap"></td>
<td class="gr1">1</td>
<td class="gr1">2</td>
<td class="gap"></td>
<td class="gr0">0</td>
</tr>
<tr>
<th>Khuddaka 1</th>
<td class="gr1">23</td>
<td class="gr1">414</td>
<td class="void"></td>
<td class="gap"></td>
<td class="gr1">129</td>
<td class="gr10">2128</td>
<td class="gap"></td>
<td class="gr0">0</td>
<td class="gr1">38</td>
<td class="gap"></td>
<td class="gr0">0</td>
</tr>
<tr>
<th>Khuddaka 2</th>
<td class="gr1">10</td>
<td class="gr1">136</td>
<td class="void"></td>
<td class="gap"></td>
<td class="gr1">220</td>
<td class="gr4">1057</td>
<td class="gap"></td>
<td class="gr0">0</td>
<td class="gr1">95</td>
<td class="gap"></td>
<td class="gr0">0</td>
</tr>
<tr>
<th>Khuddaka 3</th>
<td class="gr1">55</td>
<td class="gr1">254</td>
<td class="gr1">36</td>
<td class="gap"></td>
<td class="gr3">672</td>
<td class="gr7">1486</td>
<td class="gap"></td>
<td class="gr0">0</td>
<td class="gr1">170</td>
<td class="gap"></td>
<td class="gr0">0</td>
</tr>
<tr>
<th class="vertical-text" rowspan="8">Abhidhamma</th>
</tr>
<tr>
<th>Dhammasaṅgaṇī</th>
<td class="gr0">0</td>
<td class="gr1" rowspan="7">119</td>
<td class="gr1" rowspan="7">154</td>
<td class="gap"></td>
<td class="gr1">6</td>
<td class="gr1">354</td>
<td class="gap"></td>
<td class="gr0">0</td>
<td class="gr1" rowspan="7">27</td>
<td class="gap"></td>
<td class="gr0">0</td>
</tr>
<tr>
<th>Vibhaṅga</th>
<td class="gr1">6</td>
<td class="gap"></td>
<td class="gr1">2</td>
<td class="gr1">215</td>
<td class="gap"></td>
<td class="gr0">0</td>
<td class="gap"></td>
<td class="gr0">0</td>
</tr>
<tr>
<th>Dhātukathā</th>
<td class="gr0">0</td>
<td class="gap"></td>
<td class="gr0">0</td>
<td class="gr1">2</td>
<td class="gap"></td>
<td class="gr0" rowspan="2">0</td>
<td class="gap"></td>
<td class="gr0">0</td>
</tr>
<tr>
<th>Puggalapaññatti</th>
<td class="gr1">26</td>
<td class="gap"></td>
<td class="gr1">1</td>
<td class="gr1">11</td>
<td class="gap"></td>
<td class="gap"></td>
<td class="gr0">0</td>
</tr>
<tr>
<th>Kathāvatthu</th>
<td class="gr1">59</td>
<td class="gap"></td>
<td class="gr1">243</td>
<td class="gr1">39</td>
<td class="gap"></td>
<td class="gr0">0</td>
<td class="gap"></td>
<td class="gr0">0</td>
</tr>
<tr>
<th>Yamaka</th>
<td class="gr0">0</td>
<td class="gap"></td>
<td class="gr0">0</td>
<td class="gr1">9</td>
<td class="gap"></td>
<td class="gr0">0</td>
<td class="gap"></td>
<td class="gr0">0</td>
</tr>
<tr>
<th>Paṭṭhāna</th>
<td class="gr0">0</td>
<td class="gap"></td>
<td class="gr0">0</td>
<td class="gr1">8</td>
<td class="gap"></td>
<td class="gr0">0</td>
<td class="gap"></td>
<td class="gr0">0</td>
</tr>
<tr>
<th class="vertical-text" rowspan="10">Aññā</th>
</tr>
<tr>
<th>Visuddhimagga</th>
<td class="void"></td>
<td class="gr1">99</td>
<td class="gr1">135</td>
<td class="gap"></td>
<td class="void"></td>
<td class="gr2">601</td>
<td class="gap"></td>
<td class="void"></td>
<td class="gr0">0</td>
<td class="gap"></td>
<td class="void"></td>
</tr>
<tr>
<th>Leḍī Sayāḍo</th>
<td class="void"></td>
<td class="void"></td>
<td class="gr1">119</td>
</tr>
<tr>
<th>Buddhavandanā</th>
<td class="void"></td>
<td class="void"></td>
<td class="gr1">110</td>
</tr>
<tr>
<th>Vaṃsa</th>
<td class="void"></td>
<td class="void"></td>
<td class="gr0">0</td>
</tr>
<tr>
<th>Byākaraṇa</th>
<td class="void"></td>
<td class="void"></td>
<td class="gr2">501</td>
</tr>
<tr>
<th>Pucchavissajjanā</th>
<td class="void"></td>
<td class="void"></td>
<td class="gr0">0</td>
</tr>
<tr>
<th>Nīti</th>
<td class="void"></td>
<td class="void"></td>
<td class="gr1">109</td>
</tr>
<tr>
<th>Pakiṇṇaka</th>
<td class="void"></td>
<td class="void"></td>
<td class="gr1">2</td>
</tr>
<tr>
<th>Sihaḷa</th>
<td class="void"></td>
<td class="void"></td>
<td class="gr1">24</td>
</tr>
</tbody>
</table>
<p><b>CST</b>: Chaṭṭha Saṅgāyana Tipiṭaka (Myanmar)</p>
<p><b>BJT</b>: Buddha Jayanti Tipiṭaka (Sri Lanka)</p>
<p><b>SYA</b>: Syāmaraṭṭha 1927 Royal Edition (Thailand)</p>
<p><b>MST</b>: Mahāsaṅgīti Tipiṭaka (Sutta Central)</p>
```

---

## 13. REAL EXAMPLE — "a 1.1" freq_data JSON

```json
{
  "FreqHeading": "Frequency of <b>a 1.1</b> and its declensions",
  "CstFreq": [1,2,9,21,31,4,1,0,195,23,10,55,0,6,0,26,59,0,0,29,0,0,0,2,92,103,53,78,414,136,254,119,99,265,314,191,41,128,36,154,135,119,110,0,501,0,109,2,24],
  "CstGrad": [1,1,1,1,1,1,1,0,1,1,1,1,0,1,0,1,1,0,0,1,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,2,0,1,1,1],
  "BjtFreq": [0,0,0,0,0,13,0,0,4,129,220,672,6,2,0,1,243,0,0,215,31,4,2,5,398,498,304,391,2128,1057,1486,354,215,2,11,39,9,8,601],
  "BjtGrad": [0,0,0,0,0,1,0,0,1,1,1,3,1,1,0,1,1,0,0,1,1,1,1,1,1,2,1,1,10,4,7,1,1,1,1,1,1,1,2],
  "SyaFreq": [0,0,0,0,2,0,12,1,0,0,0,0,0,0,0,0,0,0,4,8,4,2,38,95,170,27,0,0,0,2],
  "SyaGrad": [0,0,0,0,1,0,1,1,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,0,0,0,1],
  "ScFreq": [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
  "ScGrad": [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
}
```

### Verification: Cross-reference JSON → HTML for "a 1.1"

| Row | Cell | JSON Index | JSON Value | HTML Class | HTML Value | Match? |
|-----|------|-----------|------------|------------|------------|--------|
| Pārājika | CST M | CstFreq[0]/CstGrad[0] | 1/1 | gr1 | 1 | ✓ |
| Pārājika | CST A | CstFreq[19]/CstGrad[19] | 29/1 | gr1 | 29 | ✓ |
| Pārājika | CST Ṭ | CstFreq[33]/CstGrad[33] | 265/1 | gr1 rs5 | 265 | ✓ |
| Pārājika | BJT M | BjtFreq[0]/BjtGrad[0] | 0/0 | gr0 | 0 | ✓ |
| Pārājika | BJT A | BjtFreq[19]/BjtGrad[19] | 215/1 | gr1 | 215 | ✓ |
| Khuddaka 1 | BJT A | BjtFreq[28]/BjtGrad[28] | 2128/10 | gr10 | 2128 | ✓ |
| Khuddaka 3 | BJT A | BjtFreq[30]/BjtGrad[30] | 1486/7 | gr7 | 1486 | ✓ |

All values match. The JSON data maps correctly to the HTML output.

---

## 14. EMPTY STATE

When `freq_data` is empty or all zeros:
```html
<p class="heading underlined">
  There are no exact matches of <b>word</b> in any texts.
</p>
<p>It probably only occurs in compounds. Or perhaps there is an error.</p>
```

When `freq_data` is null/empty entirely → no button shown at all.
