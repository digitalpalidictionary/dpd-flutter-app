import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

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
import '../theme/dpd_palette.dart';
import '../utils/transliteration.dart';
import '../utils/velthuis.dart';
import '../utils/back_navigation.dart';
import '../utils/history_recording.dart';
import '../utils/search_timing.dart';
import '../utils/text_filters.dart';
import '../services/bubble_service.dart';
import '../widgets/autocomplete_dropdown.dart';
import '../widgets/bubble_toggle.dart';
import '../widgets/dpd_logo.dart';
import '../widgets/download_footer.dart';
import '../widgets/empty_prompt.dart';
import '../widgets/feedback_footer.dart';
import '../widgets/home_content.dart';
import '../widgets/history_panel.dart';
import '../widgets/info_popup.dart';
import '../widgets/settings_panel.dart';
import '../widgets/split_results_list.dart';
import '../widgets/content_text_scale.dart';
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
  bool _showHome = true;
  // Mirrors whether the autocomplete dropdown is on screen, inside setState so
  // the results area rebuilds when it changes. While suggestions are visible
  // the no-results verdict is withheld — the user is still mid-word.
  bool _suggestionsVisible = false;
  // Bumped by every action that should invalidate whatever autocomplete
  // fallback query is currently in flight: a new keystroke, or the user
  // committing/clearing/navigating away before the awaited tiers resolve.
  // `_updateAutocomplete` captures the value once, before its first await, and
  // abandons its result the moment the counter no longer matches — this is
  // what stops a stale query from reopening the dropdown after the user has
  // already moved on. Cancelling `_autocompleteDebounce` only stops a timer
  // that hasn't fired yet; it cannot stop one that already has and is
  // mid-`await`, which is why the counter exists at all.
  int _autocompleteGeneration = 0;
  final _historyButtonKey = GlobalKey();
  InfoContent? _activeInfo;

  @override
  void initState() {
    super.initState();
    // An external lookup (share/intent) can set the query before this screen
    // mounts, so the change-listener never fires for it. Seed the field once
    // the first frame is done (mutating providers during initState crashes).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _controller.text.isNotEmpty) return;
      final initialQuery = ref.read(searchQueryProvider);
      if (initialQuery.isEmpty) return;
      final displayText = ref.read(searchBarTextProvider);
      final textToShow = context.nigg(displayText ?? initialQuery);
      _controller.text = textToShow;
      _controller.selection =
          TextSelection.collapsed(offset: textToShow.length);
      if (displayText != null) {
        ref.read(searchBarTextProvider.notifier).state = null;
      }
    });
  }

  @override
  void dispose() {
    // Inline overlay cleanup — _removeOverlay() calls setState, which is not
    // allowed during dispose.
    _overlayEntry?.remove();
    _overlayEntry?.dispose();
    _overlayEntry = null;
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
    _autocompleteGeneration++;
    final converted = context.nigg(velthuis(raw));
    if (converted != raw) {
      _controller.value = TextEditingValue(
        text: converted,
        selection: TextSelection.collapsed(offset: converted.length),
      );
    }
    final query = canonicalNiggahita(
      toRoman(converted).replaceAll('?', '').replaceAll('!', ''),
    );
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
    _autocompleteGeneration++;
    _removeOverlay();
    _hideVelthuisHelp();
    _autocompleteDebounce?.cancel();
    _debounce?.cancel();
    final query = canonicalNiggahita(
      toRoman(_controller.text.trim()).replaceAll('?', '').replaceAll('!', ''),
    );
    _setSearchQuery(query);
    if (shouldRecordCommittedSearch(query)) {
      ref.read(historyProvider.notifier).navigateTo(query);
    }
    FocusScope.of(context).unfocus();
  }

  void _onClear() {
    _autocompleteGeneration++;
    _controller.clear();
    _removeOverlay();
    _autocompleteDebounce?.cancel();
    _debounce?.cancel();
    ref.read(searchQueryProvider.notifier).state = '';
    ref.read(historyProvider.notifier).resetPosition();
    _showHome = false;
    setState(() {});
    _focusNode.requestFocus();
  }

  void _searchFromHome(String query) {
    _autocompleteGeneration++;
    _removeOverlay();
    _autocompleteDebounce?.cancel();
    _debounce?.cancel();
    _controller.text = context.nigg(query);
    _setSearchQuery(query);
    if (shouldRecordCommittedSearch(query)) {
      ref.read(historyProvider.notifier).navigateTo(query);
    }
    FocusScope.of(context).unfocus();
    setState(() {});
  }

  void _goHome() {
    _autocompleteGeneration++;
    _removeOverlay();
    _autocompleteDebounce?.cancel();
    _debounce?.cancel();
    _controller.clear();
    ref.read(searchQueryProvider.notifier).state = '';
    _showHome = true;
    FocusScope.of(context).unfocus();
    setState(() {});
  }

  Future<void> _updateAutocomplete(String query) async {
    // Guard 3: short queries stay synchronous, same as today.
    if (query.length < 2) {
      _removeOverlay();
      return;
    }

    // Tier 1 — unchanged, and shown before any `await` in this function
    // (Guard 1) so its timing stays exactly as synchronous as today. Does
    // not `return` on a hit: the rescue tier below may still need to upgrade
    // this overlay a moment later.
    final suggestions = ref.read(autocompleteSuggestionsProvider(query));
    if (suggestions.isNotEmpty) {
      _showOverlay(suggestions);
    }

    // Guard 2: an empty tier 1 can mean "no match" or "index still loading".
    // Falling through while loading would hit the database on every
    // keystroke during startup. `searchIndexProvider` must stay a
    // FutureProvider for `.hasValue` to distinguish the two; if it ever
    // becomes synchronous, `hasValue` is always true and this guard stops
    // guarding. Only tier 1 can have answered anything by this point (index
    // not loaded means tier 1's own index is empty too), so it's safe to
    // bail out here exactly as before.
    if (!ref.read(searchIndexProvider).hasValue) {
      if (suggestions.isEmpty) _removeOverlay();
      return;
    }

    // Snapshot the generation now, before the first await. Any action that
    // should invalidate this call — a new keystroke, a committed search, a
    // clear, navigating home, or picking a suggestion — bumps the counter, so
    // a mismatch after an await means this call is stale and must not touch
    // the overlay, no matter what `_controller.text` says by then.
    final requestGeneration = _autocompleteGeneration;

    // Tier 0 rescue — a genuine exact fuzzy-key match (the user typed an
    // inflected form differing from a real lookup key only by a folded
    // diacritic, aspirate, or doubled consonant, e.g. "kammam" for
    // "kammaṃ"). Tier 1 can't find this: its index holds bare lemmas only,
    // and a lemma's own collapsed key ("kama") can be *shorter* than the
    // inflected query's ("kamam"), so it never satisfies tier 1's prefix
    // rule. Runs after tier 1 has already been shown (if it had a hit) so
    // Guard 1's synchronous paint is preserved — this only ever upgrades the
    // overlay, never delays its first appearance.
    final rescueMatches = await ref.read(
      fuzzyExactSuggestionsProvider(query).future,
    );
    if (!mounted || _autocompleteGeneration != requestGeneration) return;
    if (rescueMatches.isNotEmpty) {
      if (kDebugMode) debugPrint('autocomplete: tier 0 (rescue) answered "$query"');
      final merged = [
        ...rescueMatches,
        ...suggestions.where((s) => !rescueMatches.contains(s)),
      ];
      _showOverlay(merged);
      return;
    }
    if (suggestions.isNotEmpty) return;

    // Tier 2 — enabled external dictionaries, only reached when tier 1 and
    // the rescue both found nothing.
    final dictMatches = await ref.read(dictSuggestionsProvider(query).future);
    if (!mounted || _autocompleteGeneration != requestGeneration) return;
    if (dictMatches.isNotEmpty) {
      if (kDebugMode) debugPrint('autocomplete: tier 2 (dict) answered "$query"');
      _showOverlay(dictMatches);
      return;
    }

    // Tier 3 — the lookup table, last resort: tried only when the headword
    // index, the rescue, and the external dictionaries all found nothing.
    final lookupMatches = await ref.read(
      lookupSuggestionsProvider(query).future,
    );
    if (!mounted || _autocompleteGeneration != requestGeneration) return;
    if (lookupMatches.isNotEmpty) {
      if (kDebugMode) debugPrint('autocomplete: tier 3 (lookup) answered "$query"');
      _showOverlay(lookupMatches);
      return;
    }

    _removeOverlay();
  }

  void _showOverlay(List<String> suggestions) {
    _removeOverlay();
    final overlay = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox;
    final width = renderBox.size.width;
    final shown = suggestions.map(context.nigg).toList();

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
              suggestions: shown,
              onSelected: _onSuggestionSelected,
              layerLink: _layerLink,
              width: width - 16,
            ),
          ),
        ],
      ),
    );
    overlay.insert(_overlayEntry!);
    if (!_suggestionsVisible) {
      setState(() => _suggestionsVisible = true);
    }
  }

  void _onSuggestionSelected(String term) {
    _autocompleteGeneration++;
    _controller.text = term;
    _controller.selection = TextSelection.collapsed(offset: term.length);
    _removeOverlay();
    _autocompleteDebounce?.cancel();
    _debounce?.cancel();
    final query = canonicalNiggahita(term);
    _setSearchQuery(query);
    if (shouldRecordCommittedSearch(query)) {
      ref.read(historyProvider.notifier).navigateTo(query);
    }
    setState(() {});
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry?.dispose();
    _overlayEntry = null;
    if (_suggestionsVisible && mounted) {
      setState(() => _suggestionsVisible = false);
    }
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
        final query = ref.read(historyProvider).currentQuery;
        if (query != null) {
          ref.read(searchQueryProvider.notifier).state = query;
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
    final palette = context.palette;
    final query = ref.watch(searchQueryProvider);
    final exactAsync = ref.watch(exactResultsProvider(query));
    final partialAsync = ref.watch(partialResultsProvider(query));

    // Re-render the field when the niggahita setting is toggled. The field is
    // written from callbacks, not from build, so nothing else would refresh it.
    // Both characters are one UTF-16 unit, so the selection stays valid.
    ref.listen<NiggahitaMode>(settingsProvider.select((s) => s.niggahitaMode), (
      _,
      _,
    ) {
      final current = _controller.text;
      if (current.isEmpty) return;
      final shown = context.nigg(canonicalNiggahita(current));
      if (shown == current) return;
      final selection = _controller.selection;
      _controller.text = shown;
      _controller.selection = selection;
    });

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
        final textToShow = context.nigg(displayText ?? next);
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
                        GestureDetector(
                          onTap: _goHome,
                          child: const DpdLogo(size: 30),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: GestureDetector(
                            onTap: _goHome,
                            child: Text(
                              'Digital Pāḷi Dictionary',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        CompositedTransformTarget(
                          link: _infoLayerLink,
                          child: Tooltip(
                            message: 'Information',
                            decoration: BoxDecoration(
                              color: palette.primaryAlt,
                              borderRadius: DpdColors.borderRadius,
                            ),
                            textStyle: TextStyle(
                              color: palette.light,
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
                            color: palette.primaryAlt,
                            borderRadius: DpdColors.borderRadius,
                          ),
                          textStyle: TextStyle(
                            color: palette.light,
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
                        if (Platform.isAndroid) const _BubbleHeaderButton(),
                        Tooltip(
                          message: 'Settings',
                          decoration: BoxDecoration(
                            color: palette.primaryAlt,
                            borderRadius: DpdColors.borderRadius,
                          ),
                          textStyle: TextStyle(
                            color: palette.light,
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
                                autocorrect: false,
                                // Keep suggestions enabled on Android so Gboard
                                // still exposes long-press diacritics.
                                enableSuggestions: true,
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
                          icon: Icons.close,
                          onPressed: (_controller.text.isNotEmpty || _showHome) ? _onClear : null,
                          tooltip: 'Clear',
                        ),
                        Builder(
                          builder: (context) {
                            final history = ref.watch(historyProvider);
                            final backWord = history.backQuery;
                            final fwdWord = history.forwardQuery;
                            return Row(
                              children: [
                                _BarIconButton(
                                  icon: Icons.arrow_back,
                                  tooltip: backWord != null
                                      ? context.nigg('← $backWord')
                                      : 'Previous search',
                                  onPressed: history.canGoBack
                                      ? () {
                                          ref
                                              .read(historyProvider.notifier)
                                              .goBack();
                                          final query = ref
                                              .read(historyProvider)
                                              .currentQuery;
                                          if (query != null) {
                                            ref
                                                .read(
                                                  searchQueryProvider.notifier,
                                                )
                                                .state = query;
                                          }
                                        }
                                      : null,
                                ),
                                _BarIconButton(
                                  icon: Icons.arrow_forward,
                                  tooltip: fwdWord != null
                                      ? context.nigg('$fwdWord →')
                                      : 'Next search',
                                  onPressed: history.canGoForward
                                      ? () {
                                          ref
                                              .read(historyProvider.notifier)
                                              .goForward();
                                          final query = ref
                                              .read(historyProvider)
                                              .currentQuery;
                                          if (query != null) {
                                            ref
                                                .read(
                                                  searchQueryProvider.notifier,
                                                )
                                                .state = query;
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
                        : ContentTextScale(
                            child: TapSearchWrapper(
                              child: _buildBody(
                                context,
                                query,
                                exactAsync,
                                partialAsync,
                              ),
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
    if (query.isEmpty) {
      return _showHome
          ? HomeContent(onSearch: _searchFromHome)
          : const EmptyPrompt();
    }

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

    final visiblePartial = settings.showPartialResults
        ? partial
        : <DpdHeadwordWithRoot>[];
    final visibleFuzzy = settings.showFuzzyResults
        ? fuzzyRaw
        : <DpdHeadwordWithRoot>[];
    final visibleDictPartial = settings.showPartialResults
        ? dictPartial
        : <DictResult>[];
    final visibleDictFuzzy = settings.showFuzzyResults
        ? dictFuzzy
        : <DictResult>[];

    if (exact.isEmpty &&
        visiblePartial.isEmpty &&
        roots.isEmpty &&
        secondary.isEmpty &&
        dictExact.isEmpty &&
        visibleDictPartial.isEmpty &&
        visibleDictFuzzy.isEmpty &&
        visibleFuzzy.isEmpty &&
        !partialLoading &&
        !fuzzyAsync.isLoading &&
        !dictAsync.isLoading) {
      // While the dropdown is offering completions the user is still mid-word,
      // so withhold the no-results verdict — declaring failure and suggesting
      // words at the same time is contradictory. The verdict appears as soon
      // as the dropdown closes (word finished, tapped, or no completions).
      if (_suggestionsVisible) {
        return const EmptyPrompt();
      }
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
      exact: exact,
      partial: visiblePartial,
      partialLoading: partialLoading,
      roots: roots,
      secondary: secondary,
      dictExact: dictExact,
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

// Header toggle for the system-wide floating lookup bubble. Shares
// bubbleOnProvider + the same action as the Settings toggle, so the two
// controls always agree and users can reach it either way.
class _BubbleHeaderButton extends ConsumerStatefulWidget {
  const _BubbleHeaderButton();

  @override
  ConsumerState<_BubbleHeaderButton> createState() =>
      _BubbleHeaderButtonState();
}

class _BubbleHeaderButtonState extends ConsumerState<_BubbleHeaderButton>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    refreshBubbleState(ref);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Re-sync after returning from the accessibility settings page.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) refreshBubbleState(ref);
  }

  // Keep the live bubble matching the app theme (light/dark/scheme changes).
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (ref.read(bubbleOnProvider)) {
      final primary = Theme.of(context).colorScheme.primary;
      BubbleService.setBubbleColors(
        primary.toARGB32(),
        DpdLogo.contrastOn(primary).toARGB32(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final on = ref.watch(bubbleOnProvider);
    return Tooltip(
      message: on ? 'Floating bubble on' : 'Floating bubble off',
      decoration: BoxDecoration(
        color: palette.primaryAlt,
        borderRadius: DpdColors.borderRadius,
      ),
      textStyle: TextStyle(color: palette.light, fontSize: 12),
      child: IconButton(
        icon: Icon(on ? Icons.touch_app : Icons.touch_app_outlined),
        onPressed: () => setBubbleOn(context, ref, !on),
      ),
    );
  }
}

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
          color: context.palette.primaryAlt,
          borderRadius: DpdColors.borderRadius,
        ),
        textStyle: TextStyle(color: context.palette.light, fontSize: 12),
        child: SizedBox(
          width: 40,
          height: 40,
          child: Material(
            color: enabled
                ? context.palette.primary
                : context.palette.primary.withValues(alpha: 0.4),
            borderRadius: DpdColors.borderRadius,
            elevation: enabled ? 2 : 0,
            child: InkWell(
              borderRadius: DpdColors.borderRadius,
              onTap: onPressed,
              child: Icon(
                icon,
                size: 20,
                color: enabled
                    ? context.palette.dark
                    : context.palette.dark.withValues(alpha: 0.5),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
