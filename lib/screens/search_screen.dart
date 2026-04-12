import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../database/database.dart';
import '../providers/autocomplete_provider.dart';
import '../providers/dict_provider.dart';
import '../providers/history_provider.dart';
import '../providers/search_provider.dart';
import '../providers/secondary_results_provider.dart';
import '../providers/database_update_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/summary_provider.dart';
import '../theme/dpd_colors.dart';
import '../utils/transliteration.dart';
import '../utils/velthuis.dart';
import '../utils/back_navigation.dart';
import '../utils/history_recording.dart';
import '../utils/search_timing.dart';
import '../widgets/autocomplete_dropdown.dart';
import '../widgets/download_footer.dart';
import '../widgets/empty_prompt.dart';
import '../widgets/feedback_footer.dart';
import '../widgets/history_panel.dart';
import '../widgets/info_popup.dart';
import '../widgets/settings_panel.dart';
import '../widgets/split_results_list.dart';
import '../widgets/tap_search_wrapper.dart';
import '../widgets/velthuis_help_popup.dart';

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
  bool _suppressProviderSync = false;
  final _historyButtonKey = GlobalKey();
  InfoContent? _activeInfo;

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

  void _setSearchQuery(String query) {
    _suppressProviderSync = true;
    ref.read(searchQueryProvider.notifier).state = query;
    _suppressProviderSync = false;
  }

  void _onChanged(String raw) {
    final converted = velthuis(raw);
    if (converted != raw) {
      _controller.value = TextEditingValue(
        text: converted,
        selection: TextSelection.collapsed(offset: converted.length),
      );
    }
    final query = toRoman(converted);
    setState(() {});
    _autocompleteDebounce?.cancel();
    _autocompleteDebounce = Timer(const Duration(milliseconds: 150), () {
      _updateAutocomplete(query);
    });
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _setSearchQuery(query);
    });
  }

  void _onSearch() {
    _removeOverlay();
    _hideVelthuisHelp();
    _autocompleteDebounce?.cancel();
    _debounce?.cancel();
    final query = toRoman(_controller.text.trim());
    _setSearchQuery(query);
    if (shouldRecordCommittedSearch(query)) {
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
    if (shouldRecordCommittedSearch(term)) {
      ref.read(historyProvider.notifier).add(term);
    }
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
              child: InfoPopup(
                dbVersion: ref.read(dbUpdateProvider).localVersion,
                onSelect: (content) {
                  _removeInfoOverlay();
                  setState(() => _activeInfo = content);
                },
                onExternalLink: (url) {
                  _removeInfoOverlay();
                  launchUrl(
                    Uri.parse(url),
                    mode: LaunchMode.externalApplication,
                  );
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

  AndroidBackAction _androidBackAction() {
    final history = ref.read(historyProvider);
    return resolveAndroidBackAction(
      isAndroid: Platform.isAndroid,
      hasAutocompleteOverlay: _overlayEntry != null,
      hasHelpPopup: _showHelpPopup,
      hasInfoOverlay: _infoOverlayEntry != null,
      hasActiveInfoView: _activeInfo != null,
      canGoBackInHistory: history.canGoBack,
    );
  }

  bool _hasActiveBackInterceptState() {
    return Platform.isAndroid ||
        _androidBackAction() != AndroidBackAction.exitApp;
  }

  void _dismissBackOverlays() {
    _removeOverlay();
    _removeInfoOverlay();
    setState(() => _activeInfo = null);
    _hideVelthuisHelp();
  }

  void _handleAndroidBackPress(BuildContext context) {
    switch (_androidBackAction()) {
      case AndroidBackAction.dismissOverlay:
        _dismissBackOverlays();
      case AndroidBackAction.navigateHistoryBack:
        ref.read(historyProvider.notifier).goBack();
        final entry = ref.read(historyProvider).currentEntry;
        if (entry != null) {
          ref.read(searchQueryProvider.notifier).state = entry.query;
        }
      case AndroidBackAction.exitApp:
        showDialog<void>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Exit'),
            content: const Text('Would you really like to exit?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  SystemNavigator.pop();
                },
                child: const Text('Exit'),
              ),
            ],
          ),
        );
    }
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

    // Sync the controller only for external provider changes (double-tap, intent).
    // Local changes from typing/_onSearch set _suppressProviderSync to skip this.
    // When searchBarTextProvider is set, use it for display (preserves original
    // script from share intents) instead of the romanized lookup query.
    ref.listen<String>(searchQueryProvider, (previous, next) {
      if (!_suppressProviderSync && next != _controller.text) {
        final displayText = ref.read(searchBarTextProvider);
        final textToShow = displayText ?? next;
        _controller.text = textToShow;
        _controller.selection = TextSelection.collapsed(
          offset: textToShow.length,
        );
        if (displayText != null) {
          ref.read(searchBarTextProvider.notifier).state = null;
        }
      }
    });

    return PopScope(
      canPop: !_hasActiveBackInterceptState(),
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _handleAndroidBackPress(context);
      },
      child: Scaffold(
        bottomNavigationBar: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [DownloadFooter(), FeedbackFooter()],
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
                            textStyle: TextStyle(
                              color: DpdColors.light,
                              fontSize: 12,
                            ),
                            child: IconButton(
                              icon: Icon(
                                _activeInfo != null
                                    ? Icons.info
                                    : Icons.info_outline,
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
                          textStyle: TextStyle(
                            color: DpdColors.light,
                            fontSize: 12,
                          ),
                          child: IconButton(
                            icon: Icon(
                              _showHistoryPanel
                                  ? Icons.history_toggle_off
                                  : Icons.history,
                            ),
                            onPressed: Platform.isLinux
                                ? () => setState(() {
                                    _showHistoryPanel = !_showHistoryPanel;
                                    if (_showHistoryPanel) {
                                      _showSettingsPanel = false;
                                    }
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
                          textStyle: TextStyle(
                            color: DpdColors.light,
                            fontSize: 12,
                          ),
                          child: IconButton(
                            icon: Icon(
                              _showSettingsPanel
                                  ? Icons.settings
                                  : Icons.settings_outlined,
                            ),
                            onPressed: Platform.isLinux
                                ? () => setState(() {
                                    _showSettingsPanel = !_showSettingsPanel;
                                    if (_showSettingsPanel) {
                                      _showHistoryPanel = false;
                                    }
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
                                  hintStyle: theme.textTheme.titleMedium
                                      ?.copyWith(
                                        color: theme.colorScheme.onSurface
                                            .withValues(alpha: 0.4),
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
                                      color: theme.colorScheme.onSurface
                                          .withValues(alpha: 0.6),
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
                        _BarIconButton(
                          icon: Icons.search,
                          onPressed: _onSearch,
                          tooltip: 'Search',
                        ),
                        _BarIconButton(
                          icon: Icons.close,
                          onPressed: _controller.text.isEmpty ? null : _onClear,
                          tooltip: 'Clear',
                        ),
                        Builder(
                          builder: (context) {
                            final history = ref.watch(historyProvider);
                            final backIndex = history.currentIndex + 1;
                            final backWord = backIndex < history.entries.length
                                ? history.entries[backIndex].query
                                : null;
                            final fwdIndex = history.currentIndex - 1;
                            final fwdWord =
                                fwdIndex >= 0 &&
                                    fwdIndex < history.entries.length
                                ? history.entries[fwdIndex].query
                                : null;
                            return Row(
                              children: [
                                _BarIconButton(
                                  icon: Icons.arrow_back,
                                  tooltip: backWord != null
                                      ? '← $backWord'
                                      : 'Previous search',
                                  onPressed: history.canGoBack
                                      ? () {
                                          ref
                                              .read(historyProvider.notifier)
                                              .goBack();
                                          final entry = ref
                                              .read(historyProvider)
                                              .currentEntry;
                                          if (entry != null) {
                                            ref
                                                .read(
                                                  searchQueryProvider.notifier,
                                                )
                                                .state = entry
                                                .query;
                                          }
                                        }
                                      : null,
                                ),
                                _BarIconButton(
                                  icon: Icons.arrow_forward,
                                  tooltip: fwdWord != null
                                      ? '$fwdWord →'
                                      : 'Next search',
                                  onPressed: history.canGoForward
                                      ? () {
                                          ref
                                              .read(historyProvider.notifier)
                                              .goForward();
                                          final entry = ref
                                              .read(historyProvider)
                                              .currentEntry;
                                          if (entry != null) {
                                            ref
                                                .read(
                                                  searchQueryProvider.notifier,
                                                )
                                                .state = entry
                                                .query;
                                          }
                                        }
                                      : null,
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  // Main content: info view or search results
                  Expanded(
                    child: _activeInfo != null
                        ? InfoContentView(content: _activeInfo!)
                        : TapSearchWrapper(
                            child: _buildBody(
                              context,
                              query,
                              exactAsync,
                              partialAsync,
                            ),
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
                              onPressed: () =>
                                  setState(() => _showSettingsPanel = false),
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
                        Builder(
                          builder: (context) {
                            final screenWidth = MediaQuery.of(
                              context,
                            ).size.width;
                            final buttonBox =
                                _historyButtonKey.currentContext
                                        ?.findRenderObject()
                                    as RenderBox?;
                            final rightPadding = buttonBox != null
                                ? screenWidth -
                                      buttonBox.localToGlobal(Offset.zero).dx -
                                      buttonBox.size.width
                                : 8.0;
                            return Padding(
                              padding: EdgeInsets.fromLTRB(
                                0,
                                8,
                                rightPadding,
                                0,
                              ),
                              child: Align(
                                alignment: Alignment.topRight,
                                child: IconButton(
                                  icon: const Icon(Icons.close),
                                  onPressed: () =>
                                      setState(() => _showHistoryPanel = false),
                                ),
                              ),
                            );
                          },
                        ),
                        Expanded(
                          child: HistoryContent(
                            onClose: () =>
                                setState(() => _showHistoryPanel = false),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
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
    if (query.isEmpty) return const EmptyPrompt();

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

    final visibleExact = settings.showExactResults
        ? exact
        : <DpdHeadwordWithRoot>[];
    final visiblePartial = settings.showPartialResults
        ? partial
        : <DpdHeadwordWithRoot>[];
    final visibleFuzzy = settings.showFuzzyResults
        ? fuzzyRaw
        : <DpdHeadwordWithRoot>[];
    final visibleDictExact = settings.showExactResults
        ? dictExact
        : <DictResult>[];
    final visibleDictPartial = settings.showPartialResults
        ? dictPartial
        : <DictResult>[];
    final visibleDictFuzzy = settings.showFuzzyResults
        ? dictFuzzy
        : <DictResult>[];

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
      return NoResultsWithSuggestions(query: query);
    }

    final visibility = ref.watch(dictVisibilityProvider);
    final summaryEntries = ref.watch(summaryEntriesProvider(query));

    if (enableSearchTiming) {
      final timing = SearchTimingData(query: query);
      timing.startRenderTimer();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        timing.endRenderTimer();
        timing.recordTotalSearchTime(
          DateTime.now().difference(timing.startedAt),
        );
        recordTiming(timing);
      });
    }

    return SplitResultsList(
      exact: visibleExact,
      partial: visiblePartial,
      partialLoading: partialLoading,
      roots: roots,
      secondary: secondary,
      dictExact: visibleDictExact,
      dictPartial: visibleDictPartial,
      dictFuzzy: visibleDictFuzzy,
      summaryEntries: summaryEntries,
      showSummary:
          settings.showSummary && settings.displayMode != DisplayMode.compact,
      mode: settings.displayMode,
      visibility: visibility,
      fuzzy: visibleFuzzy,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _BarIconButton extends StatelessWidget {
  const _BarIconButton({
    required this.icon,
    required this.onPressed,
    this.tooltip,
  });

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
