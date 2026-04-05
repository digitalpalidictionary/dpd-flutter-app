import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/history_provider.dart';
import '../providers/search_provider.dart';
import '../providers/settings_provider.dart';

class TapSearchWrapper extends ConsumerStatefulWidget {
  final Widget child;
  final bool shouldPop;

  const TapSearchWrapper({
    super.key,
    required this.child,
    this.shouldPop = false,
  });

  @override
  ConsumerState<TapSearchWrapper> createState() => _TapSearchWrapperState();
}

class _TapSearchWrapperState extends ConsumerState<TapSearchWrapper> {
  final _selectionAreaKey = GlobalKey<SelectionAreaState>();
  SelectedContent? _currentSelection;
  int _lastTapTime = 0;
  bool _awaitingSelection = false;
  bool _suppressContextMenu = false;
  Timer? _fallbackTimer;

  Offset? _downPosition;
  int _downTime = 0;

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
    final tapMode = ref.read(settingsProvider).tapMode;
    final now = DateTime.now().millisecondsSinceEpoch;

    if (tapMode == TapMode.singleTap) {
      _downPosition = event.position;
      _downTime = now;
    } else {
      final delta = now - _lastTapTime;
      if (delta < 500) {
        _awaitingSelection = true;
        _suppressContextMenu = true;
        _fallbackTimer?.cancel();

        if (_currentSelection != null && _currentSelection!.plainText.isNotEmpty) {
          _awaitingSelection = false;
          _executeSearch(_currentSelection!.plainText);
        } else {
          _fallbackTimer = Timer(const Duration(milliseconds: 400), () {
            if (_awaitingSelection && mounted) {
              _awaitingSelection = false;
              if (_currentSelection != null && _currentSelection!.plainText.isNotEmpty) {
                _executeSearch(_currentSelection!.plainText);
              }
            }
          });
        }
      }
    }
    _lastTapTime = now;
  }

  void _handlePointerUp(PointerUpEvent event) {
    if (ref.read(settingsProvider).tapMode != TapMode.singleTap) return;
    if (_downPosition == null) return;

    final elapsed = DateTime.now().millisecondsSinceEpoch - _downTime;
    final distance = (event.position - _downPosition!).distance;
    _downPosition = null;

    // Ignore long-presses and drags
    if (elapsed > 300 || distance > 20) return;

    final word = _getWordAtPosition(event.position);
    if (word != null && word.isNotEmpty) {
      _suppressContextMenu = true;
      _executeSearch(word);
    }
  }

  String? _getWordAtPosition(Offset globalPosition) {
    final result = HitTestResult();
    final view = View.of(context);
    WidgetsBinding.instance.hitTestInView(result, globalPosition, view.viewId);

    for (final entry in result.path) {
      final target = entry.target;
      if (target is RenderParagraph) {
        if (_isInsideTappable(target)) return null;
        final localPosition = target.globalToLocal(globalPosition);
        final textPosition = target.getPositionForOffset(localPosition);
        final text = target.text.toPlainText();
        return _extractWordAt(text, textPosition.offset);
      }
    }
    return null;
  }

  bool _isInsideTappable(RenderObject node) {
    RenderObject? current = node.parent;
    final selectionAreaRO = _selectionAreaKey.currentContext?.findRenderObject();
    while (current != null) {
      if (identical(current, selectionAreaRO)) return false;
      final config = SemanticsConfiguration();
      // ignore: invalid_use_of_protected_member
      current.describeSemanticsConfiguration(config);
      if (config.onTap != null) return true;
      current = current.parent;
    }
    return false;
  }

  String _extractWordAt(String text, int offset) {
    if (offset < 0 || offset >= text.length) return '';

    int start = offset;
    int end = offset;

    while (start > 0 && !_isWordBoundary(text[start - 1])) {
      start--;
    }
    while (end < text.length && !_isWordBoundary(text[end])) {
      end++;
    }

    return text.substring(start, end);
  }

  bool _isWordBoundary(String char) {
    return char == ' ' || char == '\n' || char == '\t' || char == '\r';
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _suppressContextMenu = false;
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
      onPointerUp: _handlePointerUp,
      child: SelectionArea(
        key: _selectionAreaKey,
        onSelectionChanged: _handleSelectionChanged,
        contextMenuBuilder: (context, selectableRegionState) {
          if (_suppressContextMenu) return const SizedBox.shrink();
          return AdaptiveTextSelectionToolbar.selectableRegion(
            selectableRegionState: selectableRegionState,
          );
        },
        child: widget.child,
      ),
    );
  }
}
