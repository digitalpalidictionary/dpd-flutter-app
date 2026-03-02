import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/history_provider.dart';
import '../providers/search_provider.dart';

class DoubleTapSearchWrapper extends ConsumerStatefulWidget {
  final Widget child;
  final bool shouldPop;

  const DoubleTapSearchWrapper({
    super.key,
    required this.child,
    this.shouldPop = false,
  });

  @override
  ConsumerState<DoubleTapSearchWrapper> createState() => _DoubleTapSearchWrapperState();
}

class _DoubleTapSearchWrapperState extends ConsumerState<DoubleTapSearchWrapper> {
  final _selectionAreaKey = GlobalKey<SelectionAreaState>();
  SelectedContent? _currentSelection;
  int _lastTapTime = 0;
  bool _awaitingSelection = false;
  Timer? _fallbackTimer;

  @override
  void dispose() {
    _fallbackTimer?.cancel();
    super.dispose();
  }

  void _handleSelectionChanged(SelectedContent? selection) {
    _currentSelection = selection;

    if (_awaitingSelection && selection != null && selection.plainText.isNotEmpty) {
      _awaitingSelection = false;
      _fallbackTimer?.cancel();
      _executeSearch(selection.plainText);
    }
  }

  void _handlePointerDown(PointerDownEvent event) {
    final now = DateTime.now().millisecondsSinceEpoch;
    final delta = now - _lastTapTime;

    if (delta < 300) {
      _awaitingSelection = true;
      _fallbackTimer?.cancel();

      // If selection is already available (updated before pointer-down), use it
      if (_currentSelection != null && _currentSelection!.plainText.isNotEmpty) {
        _awaitingSelection = false;
        _executeSearch(_currentSelection!.plainText);
      } else {
        // Fallback: if onSelectionChanged doesn't fire within 300ms, try anyway
        _fallbackTimer = Timer(const Duration(milliseconds: 300), () {
          if (_awaitingSelection && mounted) {
            _awaitingSelection = false;
            if (_currentSelection != null && _currentSelection!.plainText.isNotEmpty) {
              _executeSearch(_currentSelection!.plainText);
            }
          }
        });
      }
    }
    _lastTapTime = now;
  }

  /// Exact ported cleaning logic from DPD Web App / paliLookup.js
  String _cleanPali(String word) {
    if (word.isEmpty) return '';

    return word
        .replaceFirst(RegExp(r'''^[\s''—.–।॥|…"""]+'''), '')
        .replaceFirst(RegExp(r'''[\s'',—.—–।॥|""…:;"]+$'''), '')
        .replaceAll(RegExp(r'''[''''""""]+'''), "'")
        .trim();
  }

  void _executeSearch(String rawText) {
    final selectedText = _cleanPali(rawText);
    if (selectedText.isEmpty || !mounted) return;

    // Defer to next frame so SelectionArea finishes processing its
    // selectable list before we trigger a rebuild (avoids
    // ConcurrentModificationError in _flushInactiveSelections).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _selectionAreaKey.currentState?.selectableRegion.clearSelection();
      ref.read(searchQueryProvider.notifier).state = selectedText;
      ref.read(historyProvider.notifier).add(selectedText);

      if (widget.shouldPop) {
        final navigator = Navigator.of(context);
        if (navigator.canPop()) {
          navigator.pop();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: _handlePointerDown,
      child: SelectionArea(
        key: _selectionAreaKey,
        onSelectionChanged: _handleSelectionChanged,
        contextMenuBuilder: (context, selectableRegionState) => const SizedBox.shrink(),
        child: widget.child,
      ),
    );
  }
}
