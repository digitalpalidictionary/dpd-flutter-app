import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/settings_provider.dart';

/// Wraps [child] in a [MediaQuery] whose [TextScaler] is driven by the
/// user's "Results font size" setting. Use only around results / entry /
/// root content roots so UI chrome stays at its designed size.
class ContentTextScale extends ConsumerWidget {
  const ContentTextScale({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fontSize = ref.watch(settingsProvider.select((s) => s.fontSize));
    final scale = fontSize / 16.0;
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: TextScaler.linear(scale),
      ),
      child: child,
    );
  }
}
