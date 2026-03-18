import 'dart:async';
import 'dart:io' show Platform;

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
import '../widgets/feedback_footer.dart';
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

enum _InfoContent { bibliography, thanks }

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  final _layerLink = LayerLink();
  final _helpLayerLink = LayerLink();
  final _infoLayerLink = LayerLink();
  Timer? _debounce;
  Timer? _autocompleteDebounce;
  OverlayEntry? _overlayEntry;
  OverlayEntry? _helpOverlayEntry;
  OverlayEntry? _infoOverlayEntry;
  bool _showHelpPopup = false;
  bool _showSettingsPanel = false;
  _InfoContent? _activeInfo;

  @override
  void dispose() {
    _removeOverlay();
    _removeHelpOverlay();
    _removeInfoOverlay();
    _focusNode.dispose();
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
      _updateAutocomplete(converted);
    });

    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      ref.read(searchQueryProvider.notifier).state = converted;
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
    _focusNode.requestFocus();
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
                dbVersion: ref.read(dbUpdateProvider).localVersion,
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
      bottomNavigationBar: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [_DownloadFooter(), FeedbackFooter()],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
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
                    icon: const Icon(Icons.history),
                    onPressed: () => showHistoryOverlay(context),
                  ),
                  IconButton(
                    icon: Icon(
                      _showSettingsPanel ? Icons.settings : Icons.settings_outlined,
                    ),
                    onPressed: Platform.isLinux
                        ? () => setState(() => _showSettingsPanel = !_showSettingsPanel)
                        : () => showSettingsOverlay(context),
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
                      child: CompositedTransformTarget(
                        link: _helpLayerLink,
                        child: TextField(
                          controller: _controller,
                          focusNode: _focusNode,
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
                  _BarIconButton(icon: Icons.search, onPressed: _onSearch, tooltip: 'Search'),
                  _BarIconButton(
                    icon: Icons.close,
                    onPressed: _controller.text.isEmpty ? null : _onClear,
                    tooltip: 'Clear',
                  ),
                  Builder(builder: (context) {
                    final history = ref.watch(historyProvider);
                    final backIndex = history.currentIndex + 1;
                    final backWord = backIndex < history.entries.length
                        ? history.entries[backIndex].query
                        : null;
                    final fwdIndex = history.currentIndex - 1;
                    final fwdWord = fwdIndex >= 0 && fwdIndex < history.entries.length
                        ? history.entries[fwdIndex].query
                        : null;
                    return Row(children: [
                      _BarIconButton(
                        icon: Icons.arrow_back,
                        tooltip: backWord != null ? '← $backWord' : 'Previous search',
                        onPressed: history.canGoBack
                            ? () {
                                ref.read(historyProvider.notifier).goBack();
                                final entry = ref.read(historyProvider).currentEntry;
                                if (entry != null) {
                                  ref.read(searchQueryProvider.notifier).state = entry.query;
                                }
                              }
                            : null,
                      ),
                      _BarIconButton(
                        icon: Icons.arrow_forward,
                        tooltip: fwdWord != null ? '$fwdWord →' : 'Next search',
                        onPressed: history.canGoForward
                            ? () {
                                ref.read(historyProvider.notifier).goForward();
                                final entry = ref.read(historyProvider).currentEntry;
                                if (entry != null) {
                                  ref.read(searchQueryProvider.notifier).state = entry.query;
                                }
                              }
                            : null,
                      ),
                    ]);
                  }),
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

          ],
            ),
            if (_showSettingsPanel)
              Positioned(
                top: 0,
                right: 0,
                bottom: 0,
                width: 440,
                child: Material(
                  elevation: 8,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 8, 8, 0),
                        child: Align(
                          alignment: Alignment.topRight,
                          child: IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => setState(() => _showSettingsPanel = false),
                          ),
                        ),
                      ),
                      const Expanded(child: SettingsContent()),
                    ],
                  ),
                ),
              ),
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

    final settings = ref.watch(settingsProvider);

    if (exact.isEmpty &&
        partial.isEmpty &&
        roots.isEmpty &&
        secondary.isEmpty &&
        !partialLoading) {
      return _buildFuzzyFallback(context, query, settings.displayMode);
    }

    final summaryEntries = buildSummaryEntries(exact, roots, secondary);
    return _SplitResultsList(
      exact: exact,
      partial: partial,
      partialLoading: partialLoading,
      roots: roots,
      secondary: secondary,
      summaryEntries: summaryEntries,
      showSummary: settings.showSummary && settings.displayMode != DisplayMode.compact,
      mode: settings.displayMode,
    );
  }

  Widget _buildFuzzyFallback(BuildContext context, String query, DisplayMode mode) {
    final fuzzyAsync = ref.watch(fuzzyResultsProvider(query));
    if (fuzzyAsync.isLoading) return const Center(child: CircularProgressIndicator());
    if (fuzzyAsync.hasError) return Center(child: Text('Error: ${fuzzyAsync.error}'));
    final results = fuzzyAsync.valueOrNull ?? [];
    if (results.isEmpty) return _NoResults(query: query);
    final theme = Theme.of(context);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Icon(Icons.info_outline, size: 16, color: theme.colorScheme.outline),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'No exact match. Showing similar results.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(child: _FlatResultsList(results: results, mode: mode)),
      ],
    );
  }
}

// ── Info popup ────────────────────────────────────────────────────────────────

class _InfoPopup extends ConsumerWidget {
  const _InfoPopup({
    required this.onSelect,
    required this.onExternalLink,
    this.dbVersion,
  });

  final void Function(_InfoContent) onSelect;
  final void Function(String url) onExternalLink;
  final String? dbVersion;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appVersion = ref.watch(appVersionProvider).valueOrNull;
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.phone_android, size: 16, color: theme.textTheme.bodyMedium?.color),
                  const SizedBox(width: 8),
                  Text(
                    'App v${appVersion ?? "…"}',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            divider,
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.storage_outlined, size: 16, color: theme.textTheme.bodyMedium?.color),
                  const SizedBox(width: 8),
                  Text(
                    'Database ${dbVersion ?? "unknown"}',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            divider,
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
  const _BarIconButton({required this.icon, required this.onPressed, this.tooltip});

  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Tooltip(
        message: tooltip ?? '',
        decoration: BoxDecoration(
          color: DpdColors.primaryAlt,
          borderRadius: DpdColors.borderRadius,
        ),
        textStyle: TextStyle(color: DpdColors.light, fontSize: 12),
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
      ),
    );
  }
}

class _FlatResultsList extends StatelessWidget {
  const _FlatResultsList({required this.results, required this.mode});

  final List<DpdHeadwordWithRoot> results;
  final DisplayMode mode;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      cacheExtent: 5000,
      itemCount: results.length,
      itemBuilder: (context, i) {
        final hw = results[i];
        return switch (mode) {
          DisplayMode.classic => InlineEntryCard(headword: hw),
          DisplayMode.compact => AccordionCard(headword: hw),
        };
      },
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
    final showPartialDivider =
        (hasExact || hasRoots || hasSecondary) &&
        (hasPartial || widget.partialLoading);

    final itemCount =
        (hasSummary ? 1 : 0) +
        widget.exact.length +
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
          return _MoreResultsDivider(isCompact: widget.mode == DisplayMode.compact);
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
    if (widget.mode != DisplayMode.compact) {
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

    final (title, compactChild, expandedChild) = switch (result) {
      GrammarDictResult r => (
        'grammar: ${r.headword}',
        _CompactGrammarTable(entries: r.entries) as Widget,
        GrammarDictCard(result: r) as Widget,
      ),
      DeconstructorResult r => (
        'deconstructor: ${r.headword}',
        _CompactTextLines(lines: r.deconstructions) as Widget,
        DeconstructorCard(result: r) as Widget,
      ),
      AbbreviationResult r => (
        r.headword,
        _CompactTextLines(lines: [r.meaning]) as Widget,
        AbbreviationCard(result: r) as Widget,
      ),
      HelpResult r => (
        r.headword,
        _CompactTextLines(lines: [r.helpText]) as Widget,
        HelpCard(result: r) as Widget,
      ),
      EpdResult r => (
        'English: ${r.headword}',
        _CompactEpdList(entries: r.entries) as Widget,
        EpdCard(result: r) as Widget,
      ),
      VariantResult r => (
        'variants: ${r.headword}',
        _CompactVariantSummary(variants: r.variants) as Widget,
        VariantCard(result: r) as Widget,
      ),
      SpellingResult r => (
        'spelling: ${r.headword}',
        _CompactTextLines(lines: r.spellings.map((s) => 'incorrect spelling of $s').toList()) as Widget,
        SpellingCard(result: r) as Widget,
      ),
      SeeResult r => (
        'see: ${r.headword}',
        _CompactTextLines(lines: r.seeHeadwords.map((s) => 'see $s').toList()) as Widget,
        SeeCard(result: r) as Widget,
      ),
      _ => ('', const SizedBox.shrink() as Widget, const SizedBox.shrink() as Widget),
    };

    return _AccordionSecondaryCard(
      title: title,
      compactChild: compactChild,
      expandedChild: expandedChild,
    );
  }

  Widget _buildItem(BuildContext context, DpdHeadwordWithRoot hw) {
    return switch (widget.mode) {
      DisplayMode.classic => InlineEntryCard(headword: hw),
      DisplayMode.compact => AccordionCard(headword: hw),
    };
  }

  Widget _buildRootItem(BuildContext context, RootWithFamilies rwf) {
    return switch (widget.mode) {
      DisplayMode.classic => InlineRootCard(rwf: rwf),
      DisplayMode.compact => AccordionRootCard(rwf: rwf),
    };
  }
}

class _MoreResultsDivider extends StatelessWidget {
  const _MoreResultsDivider({this.isCompact = false});

  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textStyle = isCompact
        ? theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface)
        : theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.onSurface);
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
          Text('more results', style: textStyle),
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

class _AccordionSecondaryCard extends StatefulWidget {
  const _AccordionSecondaryCard({
    required this.title,
    required this.compactChild,
    required this.expandedChild,
  });

  final String title;
  final Widget compactChild;
  final Widget expandedChild;

  @override
  State<_AccordionSecondaryCard> createState() => _AccordionSecondaryCardState();
}

class _AccordionSecondaryCardState extends State<_AccordionSecondaryCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final boldStyle = theme.textTheme.bodyMedium?.copyWith(
      height: 1.5,
      fontWeight: FontWeight.w700,
      color: theme.colorScheme.primary,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: _isExpanded
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => setState(() => _isExpanded = false),
                  child: widget.expandedChild,
                ),
              ),
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => setState(() => _isExpanded = true),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(4, 6, 4, 6),
                    child: Text(widget.title, style: boldStyle),
                  ),
                ),
              ),
              widget.compactChild,
            ],
          ),
    );
  }
}

class _CompactGrammarTable extends StatelessWidget {
  const _CompactGrammarTable({required this.entries});

  final List<GrammarDictEntry> entries;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5);
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final e in entries)
            Text(
              '${e.components.where((c) => c.isNotEmpty).join(' ')} of ${e.headword}',
              style: style,
            ),
        ],
      ),
    );
  }
}

class _CompactTextLines extends StatelessWidget {
  const _CompactTextLines({required this.lines});

  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5);
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [for (final line in lines) Text(line, style: style)],
      ),
    );
  }
}

class _CompactEpdList extends StatelessWidget {
  const _CompactEpdList({required this.entries});

  final List<EpdEntry> entries;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5);
    final boldStyle = style?.copyWith(fontWeight: FontWeight.w700);
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final e in entries)
            Text.rich(TextSpan(style: style, children: [
              TextSpan(text: e.headword, style: boldStyle),
              if (e.posInfo.isNotEmpty) TextSpan(text: ' ${e.posInfo}.'),
              TextSpan(text: ' ${e.meaning}.'),
            ])),
        ],
      ),
    );
  }
}

class _CompactVariantSummary extends StatelessWidget {
  const _CompactVariantSummary({required this.variants});

  final Map<String, Map<String, List<List<String>>>> variants;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5);
    final lines = <String>[];
    for (final corpus in variants.keys) {
      for (final book in variants[corpus]!.keys) {
        for (final entry in variants[corpus]![book]!) {
          lines.add('$corpus $book: ${entry[1]}');
        }
      }
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [for (final line in lines) Text(line, style: style)],
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



class _DownloadFooter extends ConsumerWidget {
  const _DownloadFooter();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final updateState = ref.watch(dbUpdateProvider);
    final theme = Theme.of(context);

    final status = updateState.status;
    if (status != DbStatus.downloading && status != DbStatus.extracting) {
      return const SizedBox.shrink();
    }

    final percent = updateState.progress.clamp(0.0, 1.0);
    final release = updateState.releaseInfo;
    final sizeLabel = release != null
        ? ' (${DatabaseUpdateService().formatBytes(release.size)})'
        : '';
    final label = status == DbStatus.extracting
        ? 'Applying update…'
        : 'Downloading… ${(percent * 100).toStringAsFixed(0)}%$sizeLabel';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        LinearProgressIndicator(
          value: status == DbStatus.extracting ? null : percent,
          backgroundColor: theme.colorScheme.outlineVariant,
          color: DpdColors.primary,
          minHeight: 3,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 6, bottom: 6),
          child: Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ),
      ],
    );
  }
}
