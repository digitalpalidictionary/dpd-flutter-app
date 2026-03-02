import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../database/database.dart';
import '../models/lookup_results.dart';
import '../providers/autocomplete_provider.dart';
import '../providers/history_provider.dart';
import '../providers/search_provider.dart';
import '../providers/secondary_results_provider.dart';
import '../providers/settings_provider.dart';
import '../theme/dpd_colors.dart';
import '../utils/velthuis.dart';
import '../widgets/accordion_card.dart';
import '../widgets/autocomplete_dropdown.dart';
import '../widgets/double_tap_search_wrapper.dart';
import '../widgets/entry_bottom_sheet.dart';
import '../widgets/inline_entry_card.dart';
import '../widgets/inline_root_card.dart';
import '../widgets/secondary/secondary_result_cards.dart';
import '../widgets/history_panel.dart';
import '../widgets/word_card.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  final _layerLink = LayerLink();
  Timer? _debounce;
  Timer? _autocompleteDebounce;
  OverlayEntry? _overlayEntry;

  @override
  void dispose() {
    _removeOverlay();
    _controller.dispose();
    _debounce?.cancel();
    _autocompleteDebounce?.cancel();
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

    setState(() {});

    _autocompleteDebounce?.cancel();
    _autocompleteDebounce = Timer(const Duration(milliseconds: 150), () {
      _updateAutocomplete(converted.trim());
    });

    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      ref.read(searchQueryProvider.notifier).state = converted.trim();
    });
  }

  void _onSearch() {
    _removeOverlay();
    _autocompleteDebounce?.cancel();
    _debounce?.cancel();
    final query = _controller.text.trim();
    ref.read(searchQueryProvider.notifier).state = query;
    if (query.isNotEmpty) {
      ref.read(historyProvider.notifier).add(query);
    }
    FocusScope.of(context).unfocus();
  }

  void _onClear() {
    _controller.clear();
    _removeOverlay();
    _autocompleteDebounce?.cancel();
    _debounce?.cancel();
    ref.read(searchQueryProvider.notifier).state = '';
    setState(() {});
  }

  void _updateAutocomplete(String query) {
    if (query.length < 2) {
      _removeOverlay();
      return;
    }
    final suggestions = ref.read(autocompleteSuggestionsProvider(query));
    if (suggestions.isEmpty) {
      _removeOverlay();
      return;
    }
    _showOverlay(suggestions);
  }

  void _showOverlay(List<String> suggestions) {
    _removeOverlay();
    final overlay = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox;
    final width = renderBox.size.width;

    _overlayEntry = OverlayEntry(
      builder: (_) => Stack(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: _removeOverlay,
          ),
          Positioned(
            width: width,
            child: AutocompleteDropdown(
              suggestions: suggestions,
              onSelected: _onSuggestionSelected,
              layerLink: _layerLink,
              width: width - 16,
            ),
          ),
        ],
      ),
    );
    overlay.insert(_overlayEntry!);
  }

  void _onSuggestionSelected(String term) {
    _controller.text = term;
    _controller.selection = TextSelection.collapsed(offset: term.length);
    _removeOverlay();
    _autocompleteDebounce?.cancel();
    _debounce?.cancel();
    ref.read(searchQueryProvider.notifier).state = term;
    ref.read(historyProvider.notifier).add(term);
    setState(() {});
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry?.dispose();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final query = ref.watch(searchQueryProvider);
    final exactAsync = ref.watch(exactResultsProvider(query));
    final partialAsync = ref.watch(partialResultsProvider(query));

    // Sync the controller with the provider ONLY when the provider actually changes
    // (e.g. via double-tap search). This avoids fighting with active typing.
    ref.listen<String>(searchQueryProvider, (previous, next) {
      if (next != _controller.text) {
        _controller.text = next;
        _controller.selection = TextSelection.collapsed(offset: next.length);
      }
    });

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header: logo + title + settings
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: Row(
                children: [
                  SvgPicture.asset(
                    isDark
                        ? 'assets/images/dpd-logo-dark.svg'
                        : 'assets/images/dpd-logo.svg',
                    height: 30,
                    width: 30,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Digital Pāḷi Dictionary',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings),
                    onPressed: () => Navigator.pushNamed(context, '/settings'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Search bar + buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  Expanded(
                    child: CompositedTransformTarget(
                      link: _layerLink,
                      child: TextField(
                        controller: _controller,
                        autofocus: false,
                        onChanged: _onChanged,
                        onSubmitted: (_) => _onSearch(),
                        style: theme.textTheme.titleMedium,
                        decoration: InputDecoration(
                          hintText: 'Search Pāḷi...',
                          hintStyle: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.4,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: DpdColors.borderRadius,
                            borderSide: BorderSide(
                              color: theme.colorScheme.primary,
                              width: 1.5,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: DpdColors.borderRadius,
                            borderSide: BorderSide(
                              color: theme.colorScheme.primary,
                              width: 2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  _BarIconButton(
                    icon: Icons.search,
                    onPressed: _onSearch,
                  ),
                  _BarIconButton(
                    icon: Icons.close,
                    onPressed: _controller.text.isEmpty ? null : _onClear,
                  ),
                  _BarIconButton(
                    icon: Icons.arrow_back,
                    onPressed: ref.watch(canGoBackProvider) ? () {
                      ref.read(historyProvider.notifier).goBack();
                      final entry = ref.read(historyProvider).currentEntry;
                      if (entry != null) {
                        ref.read(searchQueryProvider.notifier).state = entry;
                      }
                    } : null,
                  ),
                  _BarIconButton(
                    icon: Icons.arrow_forward,
                    onPressed: ref.watch(canGoForwardProvider) ? () {
                      ref.read(historyProvider.notifier).goForward();
                      final entry = ref.read(historyProvider).currentEntry;
                      if (entry != null) {
                        ref.read(searchQueryProvider.notifier).state = entry;
                      }
                    } : null,
                  ),
                ],
              ),
            ),

            // Results
            Expanded(
              child: DoubleTapSearchWrapper(
                child: _buildBody(context, query, exactAsync, partialAsync),
              ),
            ),

            const HistoryPanel(),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    String query,
    AsyncValue<List<DpdHeadwordWithRoot>> exactAsync,
    AsyncValue<List<DpdHeadwordWithRoot>> partialAsync,
  ) {
    if (query.isEmpty) return const _EmptyPrompt();

    final exact = exactAsync.valueOrNull ?? [];
    final exactIds = exact.map((e) => e.headword.id).toSet();
    final partial = (partialAsync.valueOrNull ?? [])
        .where((e) => !exactIds.contains(e.headword.id))
        .toList();
    final exactLoading = exactAsync.isLoading;
    final partialLoading = partialAsync.isLoading;

    final rootAsync = ref.watch(rootResultsProvider(query));
    final roots = rootAsync.valueOrNull ?? [];

    final secondaryAsync = ref.watch(secondaryResultsProvider(query));
    final secondary = secondaryAsync.valueOrNull ?? [];

    if (exactLoading && exact.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (exactAsync.hasError && exact.isEmpty) {
      return Center(child: Text('Error: ${exactAsync.error}'));
    }

    if (exact.isEmpty &&
        partial.isEmpty &&
        roots.isEmpty &&
        secondary.isEmpty &&
        !partialLoading) {
      return _NoResults(query: query);
    }

    final mode = ref.watch(settingsProvider).displayMode;
    return _SplitResultsList(
      exact: exact,
      partial: partial,
      partialLoading: partialLoading,
      roots: roots,
      secondary: secondary,
      mode: mode,
    );
  }
}

class _BarIconButton extends StatelessWidget {
  const _BarIconButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: SizedBox(
        width: 40,
        height: 40,
        child: Material(
          color: enabled
              ? DpdColors.primary
              : DpdColors.primary.withValues(alpha: 0.4),
          borderRadius: DpdColors.borderRadius,
          elevation: enabled ? 2 : 0,
          child: InkWell(
            borderRadius: DpdColors.borderRadius,
            onTap: onPressed,
            child: Icon(
              icon,
              size: 20,
              color: enabled
                  ? DpdColors.light
                  : DpdColors.light.withValues(alpha: 0.5),
            ),
          ),
        ),
      ),
    );
  }
}

class _SplitResultsList extends StatelessWidget {
  const _SplitResultsList({
    required this.exact,
    required this.partial,
    required this.partialLoading,
    required this.roots,
    required this.secondary,
    required this.mode,
  });

  final List<DpdHeadwordWithRoot> exact;
  final List<DpdHeadwordWithRoot> partial;
  final bool partialLoading;
  final List<RootWithFamilies> roots;
  final List<Object> secondary;
  final DisplayMode mode;

  @override
  Widget build(BuildContext context) {
    final hasExact = exact.isNotEmpty;
    final hasPartial = partial.isNotEmpty;
    final hasRoots = roots.isNotEmpty;
    final hasSecondary = secondary.isNotEmpty;
    final showRootDivider = hasRoots && hasExact;
    final showPartialDivider =
        (hasExact || hasRoots || hasSecondary) && (hasPartial || partialLoading);

    final itemCount =
        exact.length +
        (showRootDivider ? 1 : 0) +
        roots.length +
        secondary.length +
        (showPartialDivider ? 1 : 0) +
        partial.length +
        (partialLoading ? 1 : 0);

    return ListView.separated(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      itemCount: itemCount,
      separatorBuilder: (context, index) => const SizedBox.shrink(),
      itemBuilder: (context, index) {
        // Exact headword matches first
        if (index < exact.length) {
          return _buildItem(context, exact[index]);
        }
        index -= exact.length;

        // Root results divider
        if (showRootDivider && index == 0) {
          return const _RootResultsDivider();
        }
        if (showRootDivider) index -= 1;

        // Root matches
        if (index < roots.length) {
          return _buildRootItem(context, roots[index]);
        }
        index -= roots.length;

        // Secondary result cards (abbreviations, deconstructor, grammar, help, EPD, variant, spelling, see)
        if (index < secondary.length) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: _buildSecondaryItem(secondary[index]),
          );
        }
        index -= secondary.length;

        // Partial matches divider
        if (showPartialDivider && index == 0) {
          return const _MoreResultsDivider();
        }
        if (showPartialDivider) index -= 1;

        // Partial headword matches
        if (index < partial.length) {
          return _buildItem(context, partial[index]);
        }
        index -= partial.length;

        if (partialLoading && index == 0) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }
        if (partialLoading) index -= 1;

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildSecondaryItem(Object result) {
    return switch (result) {
      DeconstructorResult r => DeconstructorCard(result: r),
      GrammarDictResult r => GrammarDictCard(result: r),
      AbbreviationResult r => AbbreviationCard(result: r),
      HelpResult r => HelpCard(result: r),
      EpdResult r => EpdCard(result: r),
      VariantResult r => VariantCard(result: r),
      SpellingResult r => SpellingCard(result: r),
      SeeResult r => SeeCard(result: r),
      _ => const SizedBox.shrink(),
    };
  }

  Widget _buildItem(BuildContext context, DpdHeadwordWithRoot hw) {
    return switch (mode) {
      DisplayMode.inline => InlineEntryCard(headword: hw),
      DisplayMode.accordion => AccordionCard(headword: hw),
      DisplayMode.bottomSheet => WordCard(
        headword: hw,
        onTap: () => _showBottomSheet(context, hw),
      ),
    };
  }

  Widget _buildRootItem(BuildContext context, RootWithFamilies rwf) {
    return switch (mode) {
      DisplayMode.inline => InlineRootCard(rwf: rwf),
      _ => _RootResultCard(rwf: rwf),
    };
  }

  void _showBottomSheet(BuildContext context, DpdHeadwordWithRoot headword) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.95,
        builder: (_, controller) =>
            EntryBottomSheet(headword: headword, scrollController: controller),
      ),
    );
  }
}

class _MoreResultsDivider extends StatelessWidget {
  const _MoreResultsDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Text(
        'more results',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
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

class _RootResultsDivider extends StatelessWidget {
  const _RootResultsDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Text(
        'root results',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _RootResultCard extends StatelessWidget {
  const _RootResultCard({required this.rwf});

  final RootWithFamilies rwf;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final root = rwf.root;
    final baseStyle = theme.textTheme.bodyMedium?.copyWith(height: 1.5);
    final boldStyle = baseStyle?.copyWith(fontWeight: FontWeight.w700);
    final grayStyle = baseStyle?.copyWith(color: Colors.grey);
    final rootClean = root.root.replaceAll('√', '');

    return InkWell(
      onTap: () => Navigator.pushNamed(context, '/root', arguments: root.root),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.primary, width: 2),
          borderRadius: DpdColors.borderRadius,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        child: RichText(
          text: TextSpan(
            style: baseStyle,
            children: [
              const TextSpan(text: 'root. '),
              TextSpan(text: rootClean, style: boldStyle),
              if (root.rootHasVerb.isNotEmpty)
                TextSpan(
                  text: root.rootHasVerb,
                  style: baseStyle?.copyWith(
                    fontSize: (baseStyle.fontSize ?? 14) * 0.7,
                    fontFeatures: [const FontFeature.superscripts()],
                  ),
                ),
              TextSpan(text: ' ${root.rootGroup} '),
              TextSpan(text: root.rootSign),
              TextSpan(text: ' (${root.rootMeaning})'),
              TextSpan(text: ' ${rwf.count}', style: grayStyle),
            ],
          ),
        ),
      ),
    );
  }
}

