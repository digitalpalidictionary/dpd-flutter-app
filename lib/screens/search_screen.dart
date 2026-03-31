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
import '../providers/dict_provider.dart';
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
import '../widgets/dict_html_card.dart';
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
  bool _showHistoryPanel = false;
  final _historyButtonKey = GlobalKey();
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

    // Initialize dict visibility from meta (no-op after first run)
    ref.listen<AsyncValue<List<DictMetaData>>>(dictMetaAllProvider, (_, next) {
      if (next.hasValue) {
        ref.read(dictVisibilityProvider.notifier).initFromMeta(next.value!);
      }
    });

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
                    child: Tooltip(
                      message: 'Information',
                      decoration: BoxDecoration(
                        color: DpdColors.primaryAlt,
                        borderRadius: DpdColors.borderRadius,
                      ),
                      textStyle: TextStyle(color: DpdColors.light, fontSize: 12),
                      child: IconButton(
                        icon: Icon(
                          _activeInfo != null ? Icons.info : Icons.info_outline,
                        ),
                        onPressed: _onInfoButtonPressed,
                      ),
                    ),
                  ),
                  Tooltip(
                    key: _historyButtonKey,
                    message: 'Search history',
                    decoration: BoxDecoration(
                      color: DpdColors.primaryAlt,
                      borderRadius: DpdColors.borderRadius,
                    ),
                    textStyle: TextStyle(color: DpdColors.light, fontSize: 12),
                    child: IconButton(
                      icon: Icon(
                        _showHistoryPanel ? Icons.history_toggle_off : Icons.history,
                      ),
                      onPressed: Platform.isLinux
                          ? () => setState(() {
                              _showHistoryPanel = !_showHistoryPanel;
                              if (_showHistoryPanel) _showSettingsPanel = false;
                            })
                          : () => showHistoryOverlay(context),
                    ),
                  ),
                  Tooltip(
                    message: 'Settings',
                    decoration: BoxDecoration(
                      color: DpdColors.primaryAlt,
                      borderRadius: DpdColors.borderRadius,
                    ),
                    textStyle: TextStyle(color: DpdColors.light, fontSize: 12),
                    child: IconButton(
                      icon: Icon(
                        _showSettingsPanel ? Icons.settings : Icons.settings_outlined,
                      ),
                      onPressed: Platform.isLinux
                          ? () => setState(() {
                              _showSettingsPanel = !_showSettingsPanel;
                              if (_showSettingsPanel) _showHistoryPanel = false;
                            })
                          : () => showSettingsOverlay(context),
                    ),
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
            if (_showHistoryPanel)
              Positioned(
                top: 0,
                right: 0,
                bottom: 0,
                width: 440,
                child: Material(
                  elevation: 8,
                  child: Column(
                    children: [
                      Builder(builder: (context) {
                        final screenWidth = MediaQuery.of(context).size.width;
                        final buttonBox = _historyButtonKey.currentContext
                            ?.findRenderObject() as RenderBox?;
                        final rightPadding = buttonBox != null
                            ? screenWidth -
                                buttonBox.localToGlobal(Offset.zero).dx -
                                buttonBox.size.width
                            : 8.0;
                        return Padding(
                          padding: EdgeInsets.fromLTRB(0, 8, rightPadding, 0),
                          child: Align(
                            alignment: Alignment.topRight,
                            child: IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () =>
                                  setState(() => _showHistoryPanel = false),
                            ),
                          ),
                        );
                      }),
                      Expanded(
                        child: HistoryContent(
                          onClose: () => setState(() => _showHistoryPanel = false),
                        ),
                      ),
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

    final dictAsync = ref.watch(dictResultsProvider(query));
    final dictSearch = dictAsync.valueOrNull ?? const DictSearchResults();
    final dictExact = dictSearch.exact;
    final dictPartial = dictSearch.partial;
    final dictFuzzy = dictSearch.fuzzy;

    if (exactLoading && exact.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (exactAsync.hasError && exact.isEmpty) {
      return Center(child: Text('Error: ${exactAsync.error}'));
    }

    final settings = ref.watch(settingsProvider);

    final fuzzyAsync = ref.watch(fuzzyResultsProvider(query));
    final exactAndPartialIds = {
      ...exactIds,
      ...partial.map((e) => e.headword.id),
    };
    final fuzzyRaw = (fuzzyAsync.valueOrNull ?? [])
        .where((e) => !exactAndPartialIds.contains(e.headword.id))
        .toList();

    final visibleExact = settings.showExactResults ? exact : <DpdHeadwordWithRoot>[];
    final visiblePartial = settings.showPartialResults ? partial : <DpdHeadwordWithRoot>[];
    final visibleFuzzy = settings.showFuzzyResults ? fuzzyRaw : <DpdHeadwordWithRoot>[];
    final visibleDictExact = settings.showExactResults ? dictExact : <DictResult>[];
    final visibleDictPartial = settings.showPartialResults ? dictPartial : <DictResult>[];
    final visibleDictFuzzy = settings.showFuzzyResults ? dictFuzzy : <DictResult>[];

    if (visibleExact.isEmpty &&
        visiblePartial.isEmpty &&
        roots.isEmpty &&
        secondary.isEmpty &&
        visibleDictExact.isEmpty &&
        visibleDictPartial.isEmpty &&
        visibleDictFuzzy.isEmpty &&
        visibleFuzzy.isEmpty &&
        !partialLoading &&
        !fuzzyAsync.isLoading &&
        !dictAsync.isLoading) {
      return _NoResults(query: query);
    }

    final visibility = ref.watch(dictVisibilityProvider);
    final summaryEntries = ref.watch(summaryEntriesProvider(query));
    return _SplitResultsList(
      exact: visibleExact,
      partial: visiblePartial,
      partialLoading: partialLoading,
      roots: roots,
      secondary: secondary,
      dictExact: visibleDictExact,
      dictPartial: visibleDictPartial,
      dictFuzzy: visibleDictFuzzy,
      summaryEntries: summaryEntries,
      showSummary: settings.showSummary && settings.displayMode != DisplayMode.compact,
      mode: settings.displayMode,
      visibility: visibility,
      fuzzy: visibleFuzzy,
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


class _SplitResultsList extends StatefulWidget {
  const _SplitResultsList({
    required this.exact,
    required this.partial,
    required this.partialLoading,
    required this.roots,
    required this.secondary,
    required this.dictExact,
    required this.dictPartial,
    required this.dictFuzzy,
    required this.summaryEntries,
    required this.showSummary,
    required this.mode,
    required this.visibility,
    this.fuzzy = const [],
  });

  final List<DpdHeadwordWithRoot> exact;
  final List<DpdHeadwordWithRoot> partial;
  final bool partialLoading;
  final List<RootWithFamilies> roots;
  final List<Object> secondary;
  final List<DictResult> dictExact;
  final List<DictResult> dictPartial;
  final List<DictResult> dictFuzzy;
  final List<SummaryEntry> summaryEntries;
  final bool showSummary;
  final DisplayMode mode;
  final DictVisibility visibility;
  final List<DpdHeadwordWithRoot> fuzzy;

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

  Object? _secondaryForSource(String sourceId) => switch (sourceId) {
    'dpd_abbreviations' =>
      widget.secondary.whereType<AbbreviationResult>().firstOrNull,
    'dpd_deconstructor' =>
      widget.secondary.whereType<DeconstructorResult>().firstOrNull,
    'dpd_grammar' =>
      widget.secondary.whereType<GrammarDictResult>().firstOrNull,
    'dpd_help' => widget.secondary.whereType<HelpResult>().firstOrNull,
    'dpd_epd' => widget.secondary.whereType<EpdResult>().firstOrNull,
    'dpd_variants' => widget.secondary.whereType<VariantResult>().firstOrNull,
    'dpd_spelling' => widget.secondary.whereType<SpellingResult>().firstOrNull,
    'dpd_see' => widget.secondary.whereType<SeeResult>().firstOrNull,
    _ => null,
  };

  @override
  Widget build(BuildContext context) {
    final enabled = widget.visibility.enabled;
    final order = widget.visibility.order;

    final tier1 = <Widget>[];
    final tier2 = <Widget>[];
    final tier3 = <Widget>[];

    for (final sourceId in order) {
      if (!enabled.contains(sourceId)) continue;

      switch (sourceId) {
        case 'dpd_summary':
          if (widget.showSummary && widget.summaryEntries.isNotEmpty) {
            tier1.add(SummarySection(
              entries: widget.summaryEntries,
              onTap: _scrollToEntry,
            ));
          }
        case 'dpd_headwords':
          for (final hw in widget.exact) {
            tier1.add(KeyedSubtree(
              key: _keyFor('hw_${hw.headword.id}'),
              child: _buildItem(context, hw),
            ));
          }
          for (final hw in widget.partial) {
            tier2.add(_buildItem(context, hw));
          }
          for (final hw in widget.fuzzy) {
            tier3.add(_buildItem(context, hw));
          }
        case 'dpd_roots':
          for (final rwf in widget.roots) {
            tier1.add(KeyedSubtree(
              key: _keyFor('root_${rwf.root.root}'),
              child: _buildRootItem(context, rwf),
            ));
          }
        case 'dpd_abbreviations':
        case 'dpd_deconstructor':
        case 'dpd_grammar':
        case 'dpd_help':
        case 'dpd_epd':
        case 'dpd_variants':
        case 'dpd_spelling':
        case 'dpd_see':
          final result = _secondaryForSource(sourceId);
          if (result != null) {
            final secId = _secondaryTargetId(result);
            tier1.add(KeyedSubtree(
              key: secId.isNotEmpty ? _keyFor(secId) : null,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: _buildSecondaryItem(result),
              ),
            ));
          }
        default:
          final exactResult =
              widget.dictExact.where((dr) => dr.dictId == sourceId).firstOrNull;
          if (exactResult != null) {
            tier1.add(Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: DictHtmlCard(
                dictId: exactResult.dictId,
                dictName: exactResult.dictName,
                entries: exactResult.entries,
              ),
            ));
          }
          final partialResult =
              widget.dictPartial.where((dr) => dr.dictId == sourceId).firstOrNull;
          if (partialResult != null) {
            tier2.add(Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: DictHtmlCard(
                dictId: partialResult.dictId,
                dictName: partialResult.dictName,
                entries: partialResult.entries,
              ),
            ));
          }
          final fuzzyResult =
              widget.dictFuzzy.where((dr) => dr.dictId == sourceId).firstOrNull;
          if (fuzzyResult != null) {
            tier3.add(Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: DictHtmlCard(
                dictId: fuzzyResult.dictId,
                dictName: fuzzyResult.dictName,
                entries: fuzzyResult.entries,
              ),
            ));
          }
      }
    }

    final showPartialLoading =
        widget.partialLoading && enabled.contains('dpd_headwords');
    final showPartialDivider = tier2.isNotEmpty || showPartialLoading;
    final showFuzzyDivider = tier3.isNotEmpty;

    final allItems = [
      ...tier1,
      if (showPartialDivider)
        _TierDivider(label: 'Partial Results', isCompact: widget.mode == DisplayMode.compact),
      ...tier2,
      if (showPartialLoading)
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
      if (showFuzzyDivider)
        _TierDivider(label: 'Fuzzy Results', isCompact: widget.mode == DisplayMode.compact),
      ...tier3,
    ];

    return ListView.separated(
      controller: _scrollController,
      cacheExtent: 5000,
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      itemCount: allItems.length,
      separatorBuilder: (context, index) => const SizedBox.shrink(),
      itemBuilder: (context, index) => allItems[index],
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

class _TierDivider extends StatelessWidget {
  const _TierDivider({required this.label, this.isCompact = false});

  final String label;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = isDark
        ? HSLColor.fromAHSL(1, 198, 1, 0.18).toColor()
        : HSLColor.fromAHSL(1, 198, 1, 0.82).toColor();
    final textColor = theme.colorScheme.onSurface;
    final textStyle = isCompact
        ? theme.textTheme.bodySmall?.copyWith(
            color: textColor,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          )
        : theme.textTheme.bodyMedium?.copyWith(
            color: textColor,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          );
    return Container(
      width: double.infinity,
      color: bgColor,
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: EdgeInsets.symmetric(
        horizontal: 16,
        vertical: isCompact ? 6 : 8,
      ),
      child: Text(label, style: textStyle),
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
