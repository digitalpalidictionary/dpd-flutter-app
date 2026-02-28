import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/database.dart';
import '../providers/search_provider.dart';
import '../providers/settings_provider.dart';
import '../utils/velthuis.dart';
import '../widgets/accordion_card.dart';
import '../widgets/entry_bottom_sheet.dart';
import '../widgets/inline_entry_card.dart';
import '../widgets/word_card.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _controller.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onChanged(String raw) {
    final converted = velthuis(raw);
    if (converted != raw) {
      _controller.value = TextEditingValue(
        text: converted,
        selection: TextSelection.collapsed(offset: converted.length),
      );
    }
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      ref.read(searchQueryProvider.notifier).state = converted.trim();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final query = ref.watch(searchQueryProvider);
    final results = ref.watch(searchResultsProvider(query));

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: false,
          onChanged: _onChanged,
          style: theme.textTheme.titleMedium,
          decoration: InputDecoration(
            hintText: 'Search Pāḷi...',
            hintStyle: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(7),
              borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(7),
              borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        ),
        actions: [
          if (_controller.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _controller.clear();
                ref.read(searchQueryProvider.notifier).state = '';
              },
            ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
        ],
      ),
      body: results.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (headwords) => _buildResults(context, query, headwords),
      ),
    );
  }

  Widget _buildResults(
    BuildContext context,
    String query,
    List<DpdHeadword> headwords,
  ) {
    if (query.isEmpty) {
      return const _EmptyPrompt();
    }
    if (headwords.isEmpty) {
      return _NoResults(query: query);
    }

    final mode = ref.watch(settingsProvider).displayMode;
    return switch (mode) {
      DisplayMode.inline => _InlineList(headwords: headwords),
      DisplayMode.accordion => _AccordionList(headwords: headwords),
      DisplayMode.bottomSheet => _BottomSheetList(headwords: headwords),
    };
  }
}

class _InlineList extends StatelessWidget {
  const _InlineList({required this.headwords});

  final List<DpdHeadword> headwords;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      itemCount: headwords.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (_, i) => InlineEntryCard(headword: headwords[i]),
    );
  }
}

class _AccordionList extends StatelessWidget {
  const _AccordionList({required this.headwords});

  final List<DpdHeadword> headwords;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      itemCount: headwords.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (_, i) => AccordionCard(headword: headwords[i]),
    );
  }
}

class _BottomSheetList extends StatelessWidget {
  const _BottomSheetList({required this.headwords});

  final List<DpdHeadword> headwords;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      itemCount: headwords.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (_, i) => WordCard(
        headword: headwords[i],
        onTap: () => _showBottomSheet(context, headwords[i]),
      ),
    );
  }

  void _showBottomSheet(BuildContext context, DpdHeadword headword) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.95,
        builder: (_, controller) => EntryBottomSheet(
          headword: headword,
          scrollController: controller,
        ),
      ),
    );
  }
}

class _EmptyPrompt extends StatelessWidget {
  const _EmptyPrompt();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.search,
            size: 64,
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'Type a Pāḷi word to begin',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
        ],
      ),
    );
  }
}

class _NoResults extends StatelessWidget {
  const _NoResults({required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'No results for "$query"',
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
      ),
    );
  }
}
