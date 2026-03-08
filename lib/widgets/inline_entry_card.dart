import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/database.dart';
import '../providers/settings_provider.dart';
import '../utils/text_filters.dart';
import 'entry_content.dart';
import 'entry_sections_mixin.dart';
import 'family_state_mixin.dart';

class InlineEntryCard extends ConsumerStatefulWidget {
  const InlineEntryCard({super.key, required this.headword});

  final DpdHeadwordWithRoot headword;

  @override
  ConsumerState<InlineEntryCard> createState() => _InlineEntryCardState();
}

class _InlineEntryCardState extends ConsumerState<InlineEntryCard>
    with FamilyStateMixin<InlineEntryCard>, EntrySectionsMixin<InlineEntryCard> {
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

  @override
  void didUpdateWidget(InlineEntryCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.headword.id != widget.headword.id) {
      resetFrequencyCache();
    }
  }

  @override
  Widget build(BuildContext context) {
    final niggahitaMode =
        ref.watch(settingsProvider.select((s) => s.niggahitaMode));
    final filterMode = NiggahitaFilterMode.values[niggahitaMode.index];
    String n(String t) => filterNiggahita(t, mode: filterMode);
    final theme = Theme.of(context);
    final h = widget.headword;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
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
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}
