import 'package:flutter/services.dart';

/// Handles Android ACTION_PROCESS_TEXT and ACTION_SEND intents.
class IntentService {
  static const _methodChannel = MethodChannel('net.dpdict.app/intent');
  static const _eventChannel = EventChannel('net.dpdict.app/intent/stream');

  /// Returns text from the cold-launch intent (either PROCESS_TEXT or SEND),
  /// or null if the app was launched normally.
  static Future<String?> getInitialText() async {
    try {
      final text = await _methodChannel.invokeMethod<String>('getInitialText');
      final cleaned = _clean(text);
      return cleaned == null || cleaned.isEmpty ? null : cleaned;
    } on MissingPluginException {
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Stream of texts delivered while the app is already running.
  static Stream<String> get intentStream {
    return _eventChannel
        .receiveBroadcastStream()
        .where((event) => event is String && event.trim().isNotEmpty)
        .cast<String>()
        .map((t) => _clean(t)!);
  }

  static String? _clean(String? text) {
    if (text == null) return null;
    var s = text.trim();
    if (s.length >= 2 &&
        (s.startsWith('"') && s.endsWith('"') ||
            s.startsWith("'") && s.endsWith("'") ||
            s.startsWith('\u201C') && s.endsWith('\u201D') ||
            s.startsWith('\u2018') && s.endsWith('\u2019'))) {
      s = s.substring(1, s.length - 1).trim();
    }
    return s;
  }
}
