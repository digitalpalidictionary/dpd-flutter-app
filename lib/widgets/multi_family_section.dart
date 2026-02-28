import 'package:flutter/material.dart';

import '../models/family_data.dart';
import '../theme/dpd_colors.dart';
import 'entry_content.dart';
import 'family_table.dart';

/// A single sub-family entry for multi-family display.
class FamilySubSection {
  const FamilySubSection({
    required this.key,
    required this.header,
    required this.entries,
    required this.footerConfig,
  });

  final String key;
  final Widget header;
  final List<FamilyEntry> entries;
  final FamilyFooterConfig footerConfig;
}

/// Renders multiple sub-families (for compound families or sets).
///
/// When there is more than one sub-family, shows a "jump to" navigation
/// header listing all family keys, then renders each sub-family with an
/// overline divider and a ⤴ back-to-top link.
class MultiFamilySection extends StatefulWidget {
  const MultiFamilySection({super.key, required this.subSections});

  final List<FamilySubSection> subSections;

  @override
  State<MultiFamilySection> createState() => _MultiFamilySectionState();
}

class _MultiFamilySectionState extends State<MultiFamilySection> {
  final _scrollKey = GlobalKey();
  final List<GlobalKey> _sectionKeys = [];

  @override
  void initState() {
    super.initState();
    _sectionKeys.addAll(
      List.generate(widget.subSections.length, (_) => GlobalKey()),
    );
  }

  void _scrollToSection(int index) {
    final ctx = _sectionKeys[index].currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(ctx, duration: const Duration(milliseconds: 300));
    }
  }

  void _scrollToTop() {
    final ctx = _scrollKey.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(ctx, duration: const Duration(milliseconds: 300));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.subSections.length == 1) {
      final s = widget.subSections.first;
      return FamilyTableWidget(
        header: s.header,
        entries: s.entries,
        footerConfig: s.footerConfig,
      );
    }

    return Column(
      key: _scrollKey,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _JumpToNav(
          keys: widget.subSections.map((s) => s.key).toList(),
          onTap: _scrollToSection,
        ),
        for (int i = 0; i < widget.subSections.length; i++) ...[
          _SubFamilyBlock(
            key: _sectionKeys[i],
            subSection: widget.subSections[i],
            onBackToTop: _scrollToTop,
            showBackLink: i > 0,
          ),
        ],
      ],
    );
  }
}

class _JumpToNav extends StatelessWidget {
  const _JumpToNav({required this.keys, required this.onTap});

  final List<String> keys;
  final void Function(int) onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Wrap(
        spacing: 4,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            'jump to:',
            style: TextStyle(
              fontSize: 12,
              color: DpdColors.primaryText,
              fontStyle: FontStyle.italic,
            ),
          ),
          for (int i = 0; i < keys.length; i++)
            GestureDetector(
              onTap: () => onTap(i),
              child: Text(
                keys[i],
                style: TextStyle(
                  fontSize: 12,
                  color: DpdColors.primaryText,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SubFamilyBlock extends StatelessWidget {
  const _SubFamilyBlock({
    super.key,
    required this.subSection,
    required this.onBackToTop,
    required this.showBackLink,
  });

  final FamilySubSection subSection;
  final VoidCallback onBackToTop;
  final bool showBackLink;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showBackLink) _BackToTopLink(onTap: onBackToTop),
        DpdSectionContainer(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _OverlineHeading(child: subSection.header),
                const SizedBox(height: 8),
                if (subSection.entries.isNotEmpty)
                  _FamilySubTable(entries: subSection.entries),
                const SizedBox(height: 4),
                DpdFooter(
                  messagePrefix: subSection.footerConfig.messagePrefix,
                  linkText: subSection.footerConfig.linkText,
                  urlBuilder: subSection.footerConfig.urlBuilder,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _OverlineHeading extends StatelessWidget {
  const _OverlineHeading({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 4, bottom: 4),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: DpdColors.primary, width: 1),
          bottom: BorderSide(color: DpdColors.primary, width: 1),
        ),
      ),
      child: DefaultTextStyle.merge(
        style: const TextStyle(fontWeight: FontWeight.bold),
        child: child,
      ),
    );
  }
}

class _BackToTopLink extends StatelessWidget {
  const _BackToTopLink({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: GestureDetector(
        onTap: onTap,
        child: Text(
          '⤴ back to top',
          style: TextStyle(
            fontSize: 12,
            color: DpdColors.primaryText,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }
}

class _FamilySubTable extends StatelessWidget {
  const _FamilySubTable({required this.entries});

  final List<FamilyEntry> entries;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final boldStyle = theme.textTheme.bodyMedium?.copyWith(
      fontWeight: FontWeight.bold,
    );
    final regularStyle = theme.textTheme.bodyMedium;

    return Table(
      columnWidths: const {
        0: IntrinsicColumnWidth(),
        1: IntrinsicColumnWidth(),
        2: FlexColumnWidth(),
        3: IntrinsicColumnWidth(),
      },
      children: entries.map((entry) {
        return TableRow(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 8, bottom: 2),
              child: Text(entry.lemma, style: boldStyle),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8, bottom: 2),
              child: Text(entry.pos, style: boldStyle),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8, bottom: 2),
              child: Text(entry.meaning, style: regularStyle),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text(
                entry.completion,
                style: regularStyle?.copyWith(color: DpdColors.gray),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}
