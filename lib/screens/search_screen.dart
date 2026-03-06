import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../data/help_data.dart';
import '../database/database.dart';
import '../models/help_results.dart';
import '../models/lookup_results.dart';
import '../providers/autocomplete_provider.dart';
import '../providers/history_provider.dart';
import '../providers/search_provider.dart';
import '../providers/secondary_results_provider.dart';
import '../providers/database_update_provider.dart';
import '../providers/settings_provider.dart';
import '../services/database_update_service.dart';
import '../theme/dpd_colors.dart';
import '../utils/velthuis.dart';
import '../widgets/accordion_card.dart';
import '../widgets/autocomplete_dropdown.dart';
import '../widgets/double_tap_search_wrapper.dart';
import '../widgets/entry_bottom_sheet.dart';
import '../widgets/inline_entry_card.dart';
import '../widgets/inline_root_card.dart';
import '../widgets/secondary/bibliography_card.dart';
import '../widgets/secondary/secondary_result_cards.dart';
import '../widgets/secondary/thanks_card.dart';
import '../widgets/history_panel.dart';
import '../widgets/settings_panel.dart';
import '../widgets/velthuis_help_popup.dart';
import '../models/summary_entry.dart';
import '../providers/summary_provider.dart';
import '../widgets/summary_section.dart';
import '../widgets/word_card.dart';

enum _InfoContent { bibliography, thanks }

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  final _layerLink = LayerLink();
  final _helpLayerLink = LayerLink();
  final _infoLayerLink = LayerLink();
  Timer? _debounce;
  Timer? _autocompleteDebounce;
  OverlayEntry? _overlayEntry;
  OverlayEntry? _helpOverlayEntry;
  OverlayEntry? _infoOverlayEntry;
  bool _showHelpPopup = false;
  _InfoContent? _activeInfo;

  @override
  void dispose() {
    _removeOverlay();
    _removeHelpOverlay();
    _removeInfoOverlay();
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
    _hideVelthuisHelp();
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
    ref.read(historyProvider.notifier).resetPosition();
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

  void _toggleHelpPopup() {
    setState(() {
      _showHelpPopup = !_showHelpPopup;
    });
    if (_showHelpPopup) {
      _showVelthuisHelp();
    } else {
      _removeHelpOverlay();
    }
  }

  void _showVelthuisHelp() {
    _removeHelpOverlay();
    final overlay = Overlay.of(context);
    _helpOverlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          GestureDetector(
            onTap: _hideVelthuisHelp,
            child: Container(color: Colors.transparent),
          ),
          CompositedTransformFollower(
            link: _helpLayerLink,
            targetAnchor: Alignment.bottomLeft,
            followerAnchor: Alignment.topLeft,
            child: VelthuisHelpPopup(),
          ),
        ],
      ),
    );
    overlay.insert(_helpOverlayEntry!);
  }

  void _hideVelthuisHelp() {
    setState(() {
      _showHelpPopup = false;
    });
    _removeHelpOverlay();
  }

  void _removeHelpOverlay() {
    _helpOverlayEntry?.remove();
    _helpOverlayEntry?.dispose();
    _helpOverlayEntry = null;
  }

  void _onInfoButtonPressed() {
    _removeInfoOverlay();
    if (_activeInfo != null) {
      setState(() => _activeInfo = null);
    } else {
      _showInfoPopup();
    }
  }

  void _showInfoPopup() {
    final overlay = Overlay.of(context);
    _infoOverlayEntry = OverlayEntry(
      builder: (_) => Stack(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: _removeInfoOverlay,
            child: const SizedBox.expand(),
          ),
          CompositedTransformFollower(
            link: _infoLayerLink,
            targetAnchor: Alignment.bottomRight,
            followerAnchor: Alignment.topRight,
            child: UnconstrainedBox(
              alignment: Alignment.topRight,
              child: _InfoPopup(
                onSelect: (content) {
                  _removeInfoOverlay();
                  setState(() => _activeInfo = content);
                },
                onExternalLink: (url) {
                  _removeInfoOverlay();
                  launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                },
              ),
            ),
          ),
        ],
      ),
    );
    overlay.insert(_infoOverlayEntry!);
  }

  void _removeInfoOverlay() {
    _infoOverlayEntry?.remove();
    _infoOverlayEntry?.dispose();
    _infoOverlayEntry = null;
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
                  CompositedTransformTarget(
                    link: _infoLayerLink,
                    child: IconButton(
                      icon: Icon(
                        _activeInfo != null ? Icons.info : Icons.info_outline,
                      ),
                      onPressed: _onInfoButtonPressed,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings),
                    onPressed: () => showSettingsOverlay(context),
                  ),
                ],
              ),
            ),

            const _UpdateBanner(),

            const SizedBox(height: 8),

            // Search bar + buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  Expanded(
                    child: CompositedTransformTarget(
                      link: _layerLink,
                      child: CompositedTransformTarget(
                        link: _helpLayerLink,
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
                            suffixIcon: IconButton(
                              icon: Icon(
                                Icons.help_outline,
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.6,
                                ),
                              ),
                              onPressed: _toggleHelpPopup,
                              tooltip: 'Velthuis typing help',
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  _BarIconButton(icon: Icons.search, onPressed: _onSearch),
                  _BarIconButton(
                    icon: Icons.close,
                    onPressed: _controller.text.isEmpty ? null : _onClear,
                  ),
                  _BarIconButton(
                    icon: Icons.arrow_back,
                    onPressed: ref.watch(canGoBackProvider)
                        ? () {
                            ref.read(historyProvider.notifier).goBack();
                            final entry = ref
                                .read(historyProvider)
                                .currentEntry;
                            if (entry != null) {
                              ref.read(searchQueryProvider.notifier).state =
                                  entry;
                            }
                          }
                        : null,
                  ),
                  _BarIconButton(
                    icon: Icons.arrow_forward,
                    onPressed: ref.watch(canGoForwardProvider)
                        ? () {
                            ref.read(historyProvider.notifier).goForward();
                            final entry = ref
                                .read(historyProvider)
                                .currentEntry;
                            if (entry != null) {
                              ref.read(searchQueryProvider.notifier).state =
                                  entry;
                            }
                          }
                        : null,
                  ),
                ],
              ),
            ),

            // Main content: info view or search results
            Expanded(
              child: _activeInfo != null
                  ? _InfoContentView(
                      content: _activeInfo!,
                      onClose: () => setState(() => _activeInfo = null),
                    )
                  : DoubleTapSearchWrapper(
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

    final settings = ref.watch(settingsProvider);
    final summaryEntries = buildSummaryEntries(exact, roots, secondary);
    return _SplitResultsList(
      exact: exact,
      partial: partial,
      partialLoading: partialLoading,
      roots: roots,
      secondary: secondary,
      summaryEntries: summaryEntries,
      showSummary: settings.showSummary,
      mode: settings.displayMode,
    );
  }
}

// ── Info popup ────────────────────────────────────────────────────────────────

class _InfoPopup extends StatelessWidget {
  const _InfoPopup({required this.onSelect, required this.onExternalLink});

  final void Function(_InfoContent) onSelect;
  final void Function(String url) onExternalLink;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final divider = Divider(height: 1, color: DpdColors.primary.withValues(alpha: 0.3));

    return Material(
      elevation: 4,
      borderRadius: DpdColors.borderRadius,
      color: isDark ? DpdColors.darkShade : DpdColors.light,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: DpdColors.primary, width: 1.5),
          borderRadius: DpdColors.borderRadius,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _InfoMenuItem(
              label: 'Bibliography',
              icon: Icons.menu_book_outlined,
              onTap: () => onSelect(_InfoContent.bibliography),
            ),
            divider,
            _InfoMenuItem(
              label: 'Thanks',
              icon: Icons.volunteer_activism_outlined,
              onTap: () => onSelect(_InfoContent.thanks),
            ),
            divider,
            _InfoMenuItem(
              label: 'DPD Website',
              icon: Icons.language,
              onTap: () => onExternalLink('https://dpdict.net'),
            ),
            divider,
            _InfoMenuItem(
              label: 'Documentation',
              icon: Icons.description_outlined,
              onTap: () => onExternalLink('https://docs.dpdict.net'),
            ),
            divider,
            _InfoMenuItem(
              label: 'Mailing List',
              icon: Icons.mail_outline,
              onTap: () => onExternalLink('https://forms.gle/gJ7ouhJriYREPm1s8'),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoMenuItem extends StatelessWidget {
  const _InfoMenuItem({required this.label, required this.onTap, required this.icon});

  final String label;
  final VoidCallback onTap;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyMedium;
    return InkWell(
      borderRadius: DpdColors.borderRadius,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: style?.color),
            const SizedBox(width: 8),
            Text(label, style: style),
          ],
        ),
      ),
    );
  }
}

// ── Info content view ─────────────────────────────────────────────────────────

class _InfoContentView extends StatefulWidget {
  const _InfoContentView({required this.content, required this.onClose});

  final _InfoContent content;
  final VoidCallback onClose;

  @override
  State<_InfoContentView> createState() => _InfoContentViewState();
}

class _InfoContentViewState extends State<_InfoContentView> {
  late Future<Widget> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  @override
  void didUpdateWidget(_InfoContentView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.content != widget.content) {
      setState(() => _future = _load());
    }
  }

  Future<Widget> _load() async {
    switch (widget.content) {
      case _InfoContent.bibliography:
        final cats = await loadBibliography();
        return BibliographyCard(result: BibliographyResult(categories: cats));
      case _InfoContent.thanks:
        final cats = await loadThanks();
        return ThanksCard(result: ThanksResult(categories: cats));
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Error: ${snapshot.error}',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          );
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(8),
          child: snapshot.data!,
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

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

class _SplitResultsList extends StatefulWidget {
  const _SplitResultsList({
    required this.exact,
    required this.partial,
    required this.partialLoading,
    required this.roots,
    required this.secondary,
    required this.summaryEntries,
    required this.showSummary,
    required this.mode,
  });

  final List<DpdHeadwordWithRoot> exact;
  final List<DpdHeadwordWithRoot> partial;
  final bool partialLoading;
  final List<RootWithFamilies> roots;
  final List<Object> secondary;
  final List<SummaryEntry> summaryEntries;
  final bool showSummary;
  final DisplayMode mode;

  @override
  State<_SplitResultsList> createState() => _SplitResultsListState();
}

class _SplitResultsListState extends State<_SplitResultsList> {
  final Map<String, GlobalKey> _itemKeys = {};
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  GlobalKey _keyFor(String id) =>
      _itemKeys.putIfAbsent(id, GlobalKey.new);

  void _scrollToEntry(String targetId) {
    final key = _itemKeys[targetId];
    if (key?.currentContext != null) {
      Scrollable.ensureVisible(
        key!.currentContext!,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        alignment: 0.1,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasSummary =
        widget.showSummary && widget.summaryEntries.isNotEmpty;
    final hasExact = widget.exact.isNotEmpty;
    final hasPartial = widget.partial.isNotEmpty;
    final hasRoots = widget.roots.isNotEmpty;
    final hasSecondary = widget.secondary.isNotEmpty;
    final showRootDivider = hasRoots && hasExact;
    final showPartialDivider =
        (hasExact || hasRoots || hasSecondary) &&
        (hasPartial || widget.partialLoading);

    final itemCount =
        (hasSummary ? 1 : 0) +
        widget.exact.length +
        (showRootDivider ? 1 : 0) +
        widget.roots.length +
        widget.secondary.length +
        (showPartialDivider ? 1 : 0) +
        widget.partial.length +
        (widget.partialLoading ? 1 : 0);

    return ListView.separated(
      controller: _scrollController,
      cacheExtent: 5000,
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      itemCount: itemCount,
      separatorBuilder: (context, index) => const SizedBox.shrink(),
      itemBuilder: (context, index) {
        // Summary section first
        if (hasSummary && index == 0) {
          return SummarySection(
            entries: widget.summaryEntries,
            onTap: _scrollToEntry,
          );
        }
        if (hasSummary) index -= 1;

        // Exact headword matches
        if (index < widget.exact.length) {
          final hw = widget.exact[index];
          return KeyedSubtree(
            key: _keyFor('hw_${hw.headword.id}'),
            child: _buildItem(context, hw),
          );
        }
        index -= widget.exact.length;

        // Root results divider
        if (showRootDivider && index == 0) {
          return const _RootResultsDivider();
        }
        if (showRootDivider) index -= 1;

        // Root matches
        if (index < widget.roots.length) {
          final rwf = widget.roots[index];
          return KeyedSubtree(
            key: _keyFor('root_${rwf.root.root}'),
            child: _buildRootItem(context, rwf),
          );
        }
        index -= widget.roots.length;

        // Secondary result cards (abbreviations, deconstructor, grammar, help, EPD, variant, spelling, see)
        if (index < widget.secondary.length) {
          final result = widget.secondary[index];
          final secId = _secondaryTargetId(result);
          return KeyedSubtree(
            key: secId.isNotEmpty ? _keyFor(secId) : null,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: _buildSecondaryItem(result),
            ),
          );
        }
        index -= widget.secondary.length;

        // Partial matches divider
        if (showPartialDivider && index == 0) {
          return const _MoreResultsDivider();
        }
        if (showPartialDivider) index -= 1;

        // Partial headword matches
        if (index < widget.partial.length) {
          return _buildItem(context, widget.partial[index]);
        }
        index -= widget.partial.length;

        if (widget.partialLoading && index == 0) {
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

        return const SizedBox.shrink();
      },
    );
  }

  String _secondaryTargetId(Object result) => switch (result) {
    SeeResult r => 'sec_see_${r.headword}',
    GrammarDictResult r => 'sec_grammar_${r.headword}',
    SpellingResult r => 'sec_spelling_${r.headword}',
    VariantResult r => 'sec_variant_${r.headword}',
    AbbreviationResult r => 'sec_abbrev_${r.headword}',
    EpdResult r => 'sec_epd_${r.headword}',
    DeconstructorResult r => 'sec_decon_${r.headword}',
    HelpResult r => 'sec_help_${r.headword}',
    _ => '',
  };

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
    return switch (widget.mode) {
      DisplayMode.classic => InlineEntryCard(headword: hw),
      DisplayMode.compact => AccordionCard(headword: hw),
      DisplayMode.bottomDrawer => WordCard(
        headword: hw,
        onTap: () => _showBottomSheet(context, hw),
      ),
    };
  }

  Widget _buildRootItem(BuildContext context, RootWithFamilies rwf) {
    return switch (widget.mode) {
      DisplayMode.classic => InlineRootCard(rwf: rwf),
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
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 12, 8, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(
            height: 1,
            color: DpdColors.primary.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 12),
          Text(
            'more results',
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Divider(
            height: 1,
            color: DpdColors.primary.withValues(alpha: 0.3),
          ),
        ],
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

class _UpdateBanner extends ConsumerWidget {
  const _UpdateBanner();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final updateState = ref.watch(dbUpdateProvider);
    final theme = Theme.of(context);

    final status = updateState.status;
    if (status != DbStatus.downloading && status != DbStatus.extracting) {
      return const SizedBox.shrink();
    }

    final percent = updateState.progress;
    final label = status == DbStatus.extracting
        ? 'Applying update…'
        : 'Updating database… ${(percent * 100).toStringAsFixed(0)}%';

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
      child: Card(
        color: DpdColors.primary.withValues(alpha: 0.1),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(label, style: theme.textTheme.bodySmall),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
