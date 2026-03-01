import 'package:flutter/material.dart';

import '../models/frequency_data.dart';
import '../theme/dpd_colors.dart';

/// Native Flutter frequency heatmap table replicating the webapp layout.
class FrequencyTable extends StatelessWidget {
  const FrequencyTable({super.key, required this.data});

  final FrequencyData data;

  static const double _cellW = 42.0;
  static const double _cellH = 26.0;
  static const double _gapW = 10.0;
  static const double _vertLabelW = 22.0;
  static const double _rowLabelW = 110.0;

  // Column X offsets (pixels from left edge)
  // Col 0: vertical label (0)
  // Col 1: row label (_vertLabelW)
  // Col 2: CST M
  // Col 3: CST A
  // Col 4: CST Ṭ
  // Col 5: gap
  // Col 6: BJT M
  // Col 7: BJT A
  // Col 8: gap
  // Col 9: SYA M
  // Col 10: SYA A
  // Col 11: gap
  // Col 12: SC M
  double _colX(int col) {
    double x = 0;
    if (col == 0) return x;
    x += _vertLabelW; // past vertical label
    if (col == 1) return x;
    x += _rowLabelW; // past row label
    if (col == 2) return x;
    x += _cellW; // past CST M
    if (col == 3) return x;
    x += _cellW; // past CST A
    if (col == 4) return x;
    x += _cellW; // past CST Ṭ
    if (col == 5) return x;
    x += _gapW; // past gap
    if (col == 6) return x;
    x += _cellW; // past BJT M
    if (col == 7) return x;
    x += _cellW; // past BJT A
    if (col == 8) return x;
    x += _gapW; // past gap
    if (col == 9) return x;
    x += _cellW; // past SYA M
    if (col == 10) return x;
    x += _cellW; // past SYA A
    if (col == 11) return x;
    x += _gapW; // past gap
    if (col == 12) return x;
    return x + _cellW;
  }

  double get _totalWidth => _colX(12) + _cellW;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Total rows: 2 headers + 5 vinaya + 7 sutta + 7 abhidhamma + 9 aññā = 30
    const totalRows = 30;

    final children = <Widget>[];

    // Header rows (rows 0-1)
    _addHeaders(children);

    // Vinaya section (rows 2-6, vertical label spans 5)
    _addVinaya(children, isDark);

    // Sutta section (rows 7-13, vertical label spans 7)
    _addSutta(children, isDark);

    // Abhidhamma section (rows 14-20, vertical label spans 7)
    _addAbhidhamma(children, isDark);

    // Aññā section (rows 21-29, vertical label spans 9)
    _addAnna(children, isDark);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: _totalWidth,
        height: _cellH * totalRows,
        child: Stack(children: children),
      ),
    );
  }

  // ─── POSITIONED CELL HELPERS ──────────────────────────────

  Widget _posFreqCell(
      int row, int col, List<int> freq, List<int> grad, int idx, bool isDark,
      {int rowSpan = 1}) {
    if (idx < 0 || idx >= freq.length) return _posVoidCell(row, col);

    final value = freq[idx];
    final level = grad[idx];

    Color bgColor;
    Color textColor;
    Color borderColor;

    if (level == 0) {
      bgColor = Colors.transparent;
      textColor = Colors.transparent;
      borderColor = DpdColors.grayTransparent;
    } else {
      bgColor = DpdColors.freq[level.clamp(0, 10)];
      borderColor = bgColor;
      textColor = isDark
          ? DpdColors.light
          : (level <= 5 ? DpdColors.dark : DpdColors.light);
    }

    return Positioned(
      left: _colX(col),
      top: row * _cellH,
      child: Container(
        width: _cellW,
        height: _cellH * rowSpan,
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(color: borderColor, width: 1),
          borderRadius: DpdColors.borderRadius,
        ),
        alignment: Alignment.center,
        child: Text(
          '$value',
          style: TextStyle(color: textColor, fontSize: 11.2),
        ),
      ),
    );
  }

  Widget _posVoidCell(int row, int col) {
    return Positioned(
      left: _colX(col),
      top: row * _cellH,
      child: const SizedBox(width: _cellW, height: _cellH),
    );
  }

  Widget _posRowLabel(int row, String text) {
    return Positioned(
      left: _colX(1),
      top: row * _cellH,
      child: Container(
        width: _rowLabelW,
        height: _cellH,
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
        decoration: BoxDecoration(
          border: Border.all(color: DpdColors.primary, width: 1),
          borderRadius: DpdColors.borderRadius,
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: const TextStyle(fontSize: 11.2),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _posVerticalLabel(int startRow, int span, String text) {
    return Positioned(
      left: _colX(0),
      top: startRow * _cellH,
      child: Container(
        width: _vertLabelW,
        height: _cellH * span,
        decoration: BoxDecoration(
          border: Border.all(color: DpdColors.primary, width: 1),
          borderRadius: DpdColors.borderRadius,
        ),
        alignment: Alignment.center,
        child: Text(
          text.split('').join('\n'),
          style: const TextStyle(fontSize: 11.2, height: 1.1),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _posCorpusHeader(int col, int colSpan, String name, String tooltip) {
    return Positioned(
      left: _colX(col),
      top: 0,
      child: Tooltip(
        message: tooltip,
        child: SizedBox(
          width: _cellW * colSpan,
          height: _cellH,
          child: Center(
            child: Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
        ),
      ),
    );
  }

  Widget _posSubHeader(int col, String label, String tooltip) {
    return Positioned(
      left: _colX(col),
      top: _cellH,
      child: Tooltip(
        message: tooltip,
        child: SizedBox(
          width: _cellW,
          height: _cellH,
          child: Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Text(label, style: const TextStyle(fontSize: 11.2)),
            ),
          ),
        ),
      ),
    );
  }

  // ─── SECTION BUILDERS ─────────────────────────────────────

  void _addHeaders(List<Widget> children) {
    children.addAll([
      _posCorpusHeader(
          2, 3, 'CST', 'Chaṭṭha Saṅgāyana Tipiṭaka (Myanmar)'),
      _posCorpusHeader(
          6, 2, 'BJT', 'Buddha Jayanti Tipiṭaka (Sri Lanka)'),
      _posCorpusHeader(
          9, 2, 'SYA', 'Syāmaraṭṭha 1927 Royal Edition (Thailand)'),
      _posCorpusHeader(
          12, 1, 'MST', 'Mahāsaṅgīti Tipiṭaka (Sutta Central)'),
      _posSubHeader(2, 'M', 'mūla'),
      _posSubHeader(3, 'A', 'aṭṭhakathā'),
      _posSubHeader(4, 'Ṭ', 'ṭīkā'),
      _posSubHeader(6, 'M', 'mūla'),
      _posSubHeader(7, 'A', 'aṭṭhakathā'),
      _posSubHeader(9, 'M', 'mūla'),
      _posSubHeader(10, 'A', 'aṭṭhakathā'),
      _posSubHeader(12, 'M', 'mūla'),
    ]);
  }

  void _addVinaya(List<Widget> children, bool isDark) {
    final d = data;
    const base = 2; // first data row

    children.add(_posVerticalLabel(base, 5, 'Vinaya'));

    // Row labels
    const labels = ['Pārājika', 'Pācittiya', 'Mahāvagga', 'Cūḷavagga', 'Parivāra'];
    for (var i = 0; i < labels.length; i++) {
      children.add(_posRowLabel(base + i, labels[i]));
    }

    // CST M (col 2): indices 0-4
    for (var i = 0; i < 5; i++) {
      children.add(_posFreqCell(base + i, 2, d.cstFreq, d.cstGrad, i, isDark));
    }

    // CST A (col 3): indices 19-23
    for (var i = 0; i < 5; i++) {
      children.add(
          _posFreqCell(base + i, 3, d.cstFreq, d.cstGrad, 19 + i, isDark));
    }

    // CST Ṭ (col 4): index 33, rowspan=5
    children.add(
        _posFreqCell(base, 4, d.cstFreq, d.cstGrad, 33, isDark, rowSpan: 5));

    // BJT M (col 6): indices 0-4
    for (var i = 0; i < 5; i++) {
      children.add(
          _posFreqCell(base + i, 6, d.bjtFreq, d.bjtGrad, i, isDark));
    }

    // BJT A (col 7): indices 19-23
    for (var i = 0; i < 5; i++) {
      children.add(
          _posFreqCell(base + i, 7, d.bjtFreq, d.bjtGrad, 19 + i, isDark));
    }

    // SYA M (col 9): index 0 rowspan=2, then 1,2,3
    children.add(
        _posFreqCell(base, 9, d.syaFreq, d.syaGrad, 0, isDark, rowSpan: 2));
    for (var i = 2; i < 5; i++) {
      children.add(
          _posFreqCell(base + i, 9, d.syaFreq, d.syaGrad, i - 1, isDark));
    }

    // SYA A (col 10): index 17, rowspan=5
    children.add(
        _posFreqCell(base, 10, d.syaFreq, d.syaGrad, 17, isDark, rowSpan: 5));

    // SC M (col 12): indices 0-4
    for (var i = 0; i < 5; i++) {
      children
          .add(_posFreqCell(base + i, 12, d.scFreq, d.scGrad, i, isDark));
    }
  }

  void _addSutta(List<Widget> children, bool isDark) {
    final d = data;
    const base = 7;

    children.add(_posVerticalLabel(base, 7, 'Sutta'));

    const labels = [
      'Dīgha', 'Majjhima', 'Saṃyutta', 'Aṅguttara',
      'Khuddaka 1', 'Khuddaka 2', 'Khuddaka 3',
    ];
    for (var i = 0; i < labels.length; i++) {
      children.add(_posRowLabel(base + i, labels[i]));
    }

    // CST M (col 2): indices 5-11
    for (var i = 0; i < 7; i++) {
      children.add(
          _posFreqCell(base + i, 2, d.cstFreq, d.cstGrad, 5 + i, isDark));
    }

    // CST A (col 3): indices 24-30
    for (var i = 0; i < 7; i++) {
      children.add(
          _posFreqCell(base + i, 3, d.cstFreq, d.cstGrad, 24 + i, isDark));
    }

    // CST Ṭ (col 4): indices 34-38, with voids at Khuddaka 1 (row 4) and Khuddaka 2 (row 5)
    children.add(
        _posFreqCell(base, 4, d.cstFreq, d.cstGrad, 34, isDark)); // Dīgha
    children.add(
        _posFreqCell(base + 1, 4, d.cstFreq, d.cstGrad, 35, isDark)); // Majjhima
    children.add(
        _posFreqCell(base + 2, 4, d.cstFreq, d.cstGrad, 36, isDark)); // Saṃyutta
    children.add(
        _posFreqCell(base + 3, 4, d.cstFreq, d.cstGrad, 37, isDark)); // Aṅguttara
    children.add(_posVoidCell(base + 4, 4)); // Khuddaka 1 — void
    children.add(_posVoidCell(base + 5, 4)); // Khuddaka 2 — void
    children.add(
        _posFreqCell(base + 6, 4, d.cstFreq, d.cstGrad, 38, isDark)); // Khuddaka 3

    // BJT M (col 6): indices 5-11
    for (var i = 0; i < 7; i++) {
      children.add(
          _posFreqCell(base + i, 6, d.bjtFreq, d.bjtGrad, 5 + i, isDark));
    }

    // BJT A (col 7): indices 24-30
    for (var i = 0; i < 7; i++) {
      children.add(
          _posFreqCell(base + i, 7, d.bjtFreq, d.bjtGrad, 24 + i, isDark));
    }

    // SYA M (col 9): indices 4-10
    for (var i = 0; i < 7; i++) {
      children.add(
          _posFreqCell(base + i, 9, d.syaFreq, d.syaGrad, 4 + i, isDark));
    }

    // SYA A (col 10): indices 18-24
    for (var i = 0; i < 7; i++) {
      children.add(
          _posFreqCell(base + i, 10, d.syaFreq, d.syaGrad, 18 + i, isDark));
    }

    // SC M (col 12): indices 5-11
    for (var i = 0; i < 7; i++) {
      children.add(
          _posFreqCell(base + i, 12, d.scFreq, d.scGrad, 5 + i, isDark));
    }
  }

  void _addAbhidhamma(List<Widget> children, bool isDark) {
    final d = data;
    const base = 14;

    children.add(_posVerticalLabel(base, 7, 'Abhidhamma'));

    const labels = [
      'Dhammasaṅgaṇī', 'Vibhaṅga', 'Dhātukathā', 'Puggalapaññatti',
      'Kathāvatthu', 'Yamaka', 'Paṭṭhāna',
    ];
    for (var i = 0; i < labels.length; i++) {
      children.add(_posRowLabel(base + i, labels[i]));
    }

    // CST M (col 2): indices 12-18
    for (var i = 0; i < 7; i++) {
      children.add(
          _posFreqCell(base + i, 2, d.cstFreq, d.cstGrad, 12 + i, isDark));
    }

    // CST A (col 3): index 31, rowspan=7
    children.add(_posFreqCell(base, 3, d.cstFreq, d.cstGrad, 31, isDark,
        rowSpan: 7));

    // CST Ṭ (col 4): index 39, rowspan=7
    children.add(_posFreqCell(base, 4, d.cstFreq, d.cstGrad, 39, isDark,
        rowSpan: 7));

    // BJT M (col 6): indices 12-18
    for (var i = 0; i < 7; i++) {
      children.add(
          _posFreqCell(base + i, 6, d.bjtFreq, d.bjtGrad, 12 + i, isDark));
    }

    // BJT A (col 7): indices 31-37
    for (var i = 0; i < 7; i++) {
      children.add(
          _posFreqCell(base + i, 7, d.bjtFreq, d.bjtGrad, 31 + i, isDark));
    }

    // SYA M (col 9): indices 11-16, with rowspan=2 at index 13 (Dhātukathā+Puggalapaññatti)
    children.add(
        _posFreqCell(base, 9, d.syaFreq, d.syaGrad, 11, isDark)); // Dhammasaṅgaṇī
    children.add(
        _posFreqCell(base + 1, 9, d.syaFreq, d.syaGrad, 12, isDark)); // Vibhaṅga
    children.add(_posFreqCell(base + 2, 9, d.syaFreq, d.syaGrad, 13, isDark,
        rowSpan: 2)); // Dhātukathā+Puggalapaññatti
    children.add(
        _posFreqCell(base + 4, 9, d.syaFreq, d.syaGrad, 14, isDark)); // Kathāvatthu
    children.add(
        _posFreqCell(base + 5, 9, d.syaFreq, d.syaGrad, 15, isDark)); // Yamaka
    children.add(
        _posFreqCell(base + 6, 9, d.syaFreq, d.syaGrad, 16, isDark)); // Paṭṭhāna

    // SYA A (col 10): index 25, rowspan=7
    children.add(_posFreqCell(base, 10, d.syaFreq, d.syaGrad, 25, isDark,
        rowSpan: 7));

    // SC M (col 12): indices 12-18
    for (var i = 0; i < 7; i++) {
      children.add(
          _posFreqCell(base + i, 12, d.scFreq, d.scGrad, 12 + i, isDark));
    }
  }

  void _addAnna(List<Widget> children, bool isDark) {
    final d = data;
    const base = 21;

    children.add(_posVerticalLabel(base, 9, 'Aññā'));

    // Visuddhimagga (row 21) — full row with voids
    children.add(_posRowLabel(base, 'Visuddhimagga'));
    children.add(_posVoidCell(base, 2)); // CST M void
    children.add(
        _posFreqCell(base, 3, d.cstFreq, d.cstGrad, 32, isDark)); // CST A
    children.add(
        _posFreqCell(base, 4, d.cstFreq, d.cstGrad, 40, isDark)); // CST Ṭ
    children.add(_posVoidCell(base, 6)); // BJT M void
    children.add(
        _posFreqCell(base, 7, d.bjtFreq, d.bjtGrad, 38, isDark)); // BJT A
    children.add(_posVoidCell(base, 9)); // SYA M void
    children.add(
        _posFreqCell(base, 10, d.syaFreq, d.syaGrad, 26, isDark)); // SYA A
    children.add(_posVoidCell(base, 12)); // SC M void

    // Rows 22-29: CST-only (void CST M, void CST A, CstṬ value)
    const annaLabels = [
      'Leḍī Sayāḍo', 'Buddhavandanā', 'Vaṃsa', 'Byākaraṇa',
      'Pucchavissajjanā', 'Nīti', 'Pakiṇṇaka', 'Sihaḷa',
    ];
    for (var i = 0; i < annaLabels.length; i++) {
      final row = base + 1 + i;
      children.add(_posRowLabel(row, annaLabels[i]));
      children.add(_posVoidCell(row, 2)); // CST M void
      children.add(_posVoidCell(row, 3)); // CST A void
      children.add(_posFreqCell(
          row, 4, d.cstFreq, d.cstGrad, 41 + i, isDark)); // CST Ṭ
    }
  }
}
