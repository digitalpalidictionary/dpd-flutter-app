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
  SelectedContent? _currentSelection;
  int _lastTapTime = 0;

  void _handleSelectionChanged(SelectedContent? selection) {
    _currentSelection = selection;
  }

  void _handlePointerDown(PointerDownEvent event) {
    final now = DateTime.now().millisecondsSinceEpoch;
    final delta = now - _lastTapTime;
    
    if (delta < 300) {
      _triggerSearch();
    }
    _lastTapTime = now;
  }

  /// Exact ported cleaning logic from DPD Web App / paliLookup.js
  String _cleanPali(String word) {
    if (word.isEmpty) return '';

    return word
        .replaceFirst(RegExp(r'''^[\s'‘—.–।॥|…"“”]+'''), '')
        .replaceFirst(RegExp(r'''[\s'‘,—.—–।॥|"“…:;”]+$'''), '')
        .replaceAll(RegExp(r'''[‘'’‘"“””]+'''), "'")
        .trim();
  }

  void _triggerSearch() {
    // Wait for the native SelectionArea to update its internal selection state
    Future.delayed(const Duration(milliseconds: 200), () {
      if (!mounted) return;
      
      if (_currentSelection != null) {
        final rawText = _currentSelection!.plainText;
        final selectedText = _cleanPali(rawText);
        
        if (selectedText.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              ref.read(searchQueryProvider.notifier).state = selectedText;
              ref.read(historyProvider.notifier).add(selectedText);

              if (widget.shouldPop) {
                final navigator = Navigator.of(context);
                if (navigator.canPop()) {
                  navigator.pop();
                }
              }
            }
          });
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
        onSelectionChanged: _handleSelectionChanged,
        contextMenuBuilder: (context, selectableRegionState) => const SizedBox.shrink(),
        child: widget.child,
      ),
    );
  }
}
