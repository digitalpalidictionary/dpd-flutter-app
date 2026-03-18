import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Handles Android ACTION_PROCESS_TEXT and ACTION_SEND intents,
/// and Linux global hotkey lookups via native method channel.
class IntentService {
  static const _methodChannel = MethodChannel('net.dpdict.app/intent');
  static const _eventChannel = EventChannel('net.dpdict.app/intent/stream');
  static const _lookupChannel = MethodChannel('net.dpdict.app/lookup');
  static final _lookupController = StreamController<String>.broadcast();

  /// Sets up the handler for words sent from a second app instance (Linux).
  static void initLookupHandler() {
    debugPrint('[DPD] IntentService: setting up lookupWord handler on channel "net.dpdict.app/lookup"');
    _lookupChannel.setMethodCallHandler((call) async {
      debugPrint('[DPD] IntentService: received method call: ${call.method}, args: ${call.arguments} (${call.arguments.runtimeType})');
      if (call.method == 'lookupWord' && call.arguments is String) {
        final cleaned = _clean(call.arguments as String);
        debugPrint('[DPD] IntentService: cleaned word: "$cleaned"');
        if (cleaned != null && cleaned.isNotEmpty) {
          debugPrint('[DPD] IntentService: adding "$cleaned" to lookupStream');
          _lookupController.add(cleaned);
        }
      }
    });
  }

  /// Stream of words sent from second-instance launches (Linux hotkey).
  static Stream<String> get lookupStream => _lookupController.stream;

  static Future<bool> bindHotkey(String accelerator) async {
    try {
      debugPrint('[DPD] IntentService: bindHotkey("$accelerator")');
      final result = await _lookupChannel.invokeMethod<bool>('bindHotkey', accelerator);
      debugPrint('[DPD] IntentService: bindHotkey result: $result');
      return result ?? false;
    } catch (e) {
      debugPrint('[DPD] IntentService: bindHotkey failed: $e');
      return false;
    }
  }

  static Future<void> unbindHotkey() async {
    try {
      await _lookupChannel.invokeMethod('unbindHotkey');
    } catch (_) {}
  }

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

  static final _urlPattern = RegExp(r'https?://\S+', caseSensitive: false);
  static final _quotePattern = RegExp(
    r'''["'\u201C\u201D\u2018\u2019]''',
  );

  static String? _clean(String? text) {
    if (text == null) return null;
    var s = text.replaceAll(_urlPattern, '').trim();
    s = s.replaceAll(_quotePattern, '').trim();
    return s;
  }
}
