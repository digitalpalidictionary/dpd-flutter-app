import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/database.dart';
import '../database/dpd_headword_extensions.dart';
import '../providers/settings_provider.dart';
import '../theme/dpd_colors.dart';
import '../utils/text_filters.dart';
import 'entry_content.dart';
import 'entry_sections_mixin.dart';
import 'family_state_mixin.dart';

enum _CardState { compact, buttonsVisible }

class AccordionCard extends ConsumerStatefulWidget {
  const AccordionCard({super.key, required this.headword});

  final DpdHeadwordWithRoot headword;

  @override
  ConsumerState<AccordionCard> createState() => _AccordionCardState();
}

class _AccordionCardState extends ConsumerState<AccordionCard>
    with FamilyStateMixin<AccordionCard>, EntrySectionsMixin<AccordionCard> {
  _CardState _cardState = _CardState.compact;

  @override
  DpdHeadwordWithRoot get familyHeadword => widget.headword;

  @override
  DpdHeadwordWithRoot get sectionHeadword => widget.headword;

  @override
  void initState() {
    super.initState();
    ref.listenManual(settingsProvider, handleSettingsChange);
    initSectionState();
  }

  void _toggleCard() {
    setState(() {
      _cardState = _cardState == _CardState.compact
          ? _CardState.buttonsVisible
          : _CardState.compact;
    });
  }

  @override
  Widget build(BuildContext context) {
    final niggahitaMode =
        ref.watch(settingsProvider.select((s) => s.niggahitaMode));
    final filterMode = NiggahitaFilterMode.values[niggahitaMode.index];
    String n(String t) => filterNiggahita(t, mode: filterMode);
    final theme = Theme.of(context);
    final h = widget.headword;
    final isExpanded = _cardState == _CardState.buttonsVisible;

    final showApostrophe = ref.watch(
      settingsProvider.select((s) => s.showSandhiApostrophe),
    );
    String f(String? text) => filterNiggahita(
      filterApostrophe(text ?? '', show: showApostrophe),
      mode: filterMode,
    );

    final hw = h.headword;
    final hasMeaning1 = hw.meaning1 != null && hw.meaning1!.isNotEmpty;
    final summary = hw.constructionSummary;
    final baseStyle = theme.textTheme.bodyMedium?.copyWith(height: 1.5);
    final boldStyle = baseStyle?.copyWith(fontWeight: FontWeight.w700);
    final grayStyle = baseStyle?.copyWith(color: DpdColors.gray);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _toggleCard,
              child: isExpanded
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 10, 12, 1),
                        child: Text(
                          n(h.lemma1),
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      EntrySummaryBox(headword: h),
                    ],
                  )
                : Padding(
                    padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
                    child: Text.rich(
                      TextSpan(
                        style: baseStyle,
                        children: [
                          TextSpan(
                            text: '${n(h.lemma1)}  ',
                            style: boldStyle?.copyWith(
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          if (hw.pos != null && hw.pos!.isNotEmpty)
                            TextSpan(text: '${f(hw.pos)}. '),
                          if (hw.plusCase != null && hw.plusCase!.isNotEmpty)
                            TextSpan(text: '(${f(hw.plusCase)}) '),
                          if (hasMeaning1) ...[
                            TextSpan(text: f(hw.meaning1), style: boldStyle),
                            if (hw.meaningLit != null && hw.meaningLit!.isNotEmpty)
                              TextSpan(text: '; lit. ${f(hw.meaningLit)}'),
                          ] else if (hw.meaning2 != null && hw.meaning2!.isNotEmpty) ...[
                            if (hw.meaning2!.contains('; lit.'))
                              TextSpan(text: f(hw.meaning2))
                            else if (hw.meaningLit != null && hw.meaningLit!.isNotEmpty)
                              TextSpan(text: '${f(hw.meaning2)}; lit. ${f(hw.meaningLit)}')
                            else
                              TextSpan(text: f(hw.meaning2)),
                          ],
                          if (summary.isNotEmpty) TextSpan(text: ' [${f(summary)}]'),
                          TextSpan(text: ' ${hw.degreeOfCompletion}', style: grayStyle),
                        ],
                      ),
                    ),
                  ),
            ),
          ),

          if (isExpanded) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(7, 2, 7, 3),
              child: Wrap(
                spacing: 0,
                runSpacing: 0,
                children: [
                  ...buildCoreSectionButtons(h),
                  ...buildExtraSectionButtons(h),
                ],
              ),
            ),
            ...buildCoreSections(h),
            ...buildExtraSections(h),
          ],
        ],
      ),
    );
  }
}
