import 'package:flutter/material.dart';

import '../theme/dpd_colors.dart';

class VelthuisHelpPopup extends StatelessWidget {
  const VelthuisHelpPopup({super.key});

  static const _conversions = [
    ('aa', 'ā'),
    ('ii', 'ī'),
    ('uu', 'ū'),
    ('"n', 'ṅ'),
    ('~n', 'ñ'),
    ('.t', 'ṭ'),
    ('.d', 'ḍ'),
    ('.n', 'ṇ'),
    ('.m', 'ṃ'),
    ('.l', 'ḷ'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      elevation: 4,
      borderRadius: DpdColors.borderRadius,
      color: isDark ? DpdColors.darkShade : DpdColors.light,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.primary, width: 1.5),
          borderRadius: DpdColors.borderRadius,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Velthuis typing:',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Table(
              columnWidths: const {
                0: FixedColumnWidth(40),
                1: FixedColumnWidth(24),
                2: FixedColumnWidth(40),
              },
              children: _conversions.map((item) {
                return TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Text(
                        item.$1,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Text('→', style: theme.textTheme.bodyMedium),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Text(
                        item.$2,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
