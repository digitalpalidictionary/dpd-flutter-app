import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/database.dart';
import '../providers/database_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/double_tap_search_wrapper.dart';
import '../widgets/entry_content.dart';
import '../widgets/entry_sections_mixin.dart';
import '../widgets/family_state_mixin.dart';
import '../widgets/feedback_footer.dart';

final _entryProvider = FutureProvider.autoDispose
    .family<DpdHeadwordWithRoot?, int>((ref, id) {
      return ref.watch(daoProvider).getById(id);
    });

class EntryScreen extends ConsumerWidget {
  const EntryScreen({super.key, required this.headwordId});

  final int headwordId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entry = ref.watch(_entryProvider(headwordId));

    return entry.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('Error: $e')),
      ),
      data: (headword) {
        if (headword == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Entry not found')),
          );
        }
        return _EntryView(headword: headword);
      },
    );
  }
}

class _EntryView extends ConsumerStatefulWidget {
  const _EntryView({required this.headword});

  final DpdHeadwordWithRoot headword;

  @override
  ConsumerState<_EntryView> createState() => _EntryViewState();
}

class _EntryViewState extends ConsumerState<_EntryView>
    with FamilyStateMixin<_EntryView>, EntrySectionsMixin<_EntryView> {
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final h = widget.headword;

    return Scaffold(
      bottomNavigationBar: const FeedbackFooter(),
      body: DoubleTapSearchWrapper(
        shouldPop: true,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    h.lemma1,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (h.pos != null)
                    Text(
                      posGrammarLine(h),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                ],
              ),
            ),
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  EntrySummaryBox(headword: h),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(7, 4, 7, 3),
                    child: Wrap(
                      spacing: 0,
                      runSpacing: 0,
                      children: [
                        ...buildCoreSectionButtons(h),
                        if (h.notes != null && h.notes!.isNotEmpty)
                          DpdSectionButton(
                            label: 'notes',
                            isActive: isOpen('notes'),
                            onTap: () => toggleSection('notes'),
                          ),
                      ],
                    ),
                  ),
                  ...buildCoreSections(h),
                  if (isOpen('notes') && h.notes != null && h.notes!.isNotEmpty)
                    DpdSectionContainer(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                        child: Text(h.notes!),
                      ),
                    ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
