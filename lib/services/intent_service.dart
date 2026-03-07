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
      return text?.trim().isEmpty == true ? null : text?.trim();
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
        .map((t) => t.trim());
  }
}
