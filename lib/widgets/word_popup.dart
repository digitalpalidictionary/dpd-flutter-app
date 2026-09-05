import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/history_provider.dart';
import '../providers/search_provider.dart';
import '../theme/dpd_colors.dart';
import '../utils/history_recording.dart';
import '../utils/text_filters.dart';
import 'search_results_body.dart';
import 'tap_search_wrapper.dart';

/// Shows a word's DPD entries in a sheet over the current screen, without
/// disturbing the search bar or the page underneath. A tap on a word inside
/// the sheet swaps its contents to the new word rather than opening a second
/// sheet; there is no back stack.
///
/// [shouldPop] mirrors [TapSearchWrapper.shouldPop]: when the popup was
/// opened from a page that pops itself on a normal word search (the full
/// entry/root page), "Full search" must pop that page too, not just the
/// sheet — otherwise the search bar changes underneath a page that's still
/// showing the old word.
Future<void> showWordPopup(
  BuildContext context,
  String word, {
  bool shouldPop = false,
}) {
  final screenHeight = MediaQuery.of(context).size.height;
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(DpdColors.borderRadiusValue),
      ),
    ),
    builder: (context) {
      return SizedBox(
        height: screenHeight * 0.7,
        child: _WordPopupContent(initialWord: word, shouldPop: shouldPop),
      );
    },
  );
}

class _WordPopupContent extends ConsumerStatefulWidget {
  const _WordPopupContent({required this.initialWord, required this.shouldPop});

  final String initialWord;
  final bool shouldPop;

  @override
  ConsumerState<_WordPopupContent> createState() => _WordPopupContentState();
}

class _WordPopupContentState extends ConsumerState<_WordPopupContent> {
  late String _word;

  @override
  void initState() {
    super.initState();
    _word = widget.initialWord;
  }

  void _fullSearch() {
    final word = _word;
    final navigator = Navigator.of(context);
    ref.read(searchQueryProvider.notifier).state = word;
    if (shouldRecordCommittedSearch(word)) {
      ref.read(historyProvider.notifier).navigateTo(word);
    }
    if (navigator.canPop()) {
      navigator.pop();
    }
    if (widget.shouldPop && navigator.canPop()) {
      navigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Center(
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 8, 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  context.nigg(_word),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              TextButton(
                onPressed: _fullSearch,
                child: const Text('Full search'),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
        Expanded(
          child: TapSearchWrapper(
            onWordTap: (tapped) => setState(() => _word = tapped),
            child: SearchResultsBody(query: _word, allowSummary: false),
          ),
        ),
      ],
    );
  }
}
