import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'providers/settings_provider.dart';
import 'providers/search_provider.dart';
import 'services/foreground_download_service.dart';
import 'services/intent_service.dart';
import 'utils/transliteration.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  ForegroundDownloadService.initialize();
  initTransliteration();

  debugPrint('[DPD] main() called with args: $args');

  final prefs = await SharedPreferences.getInstance();

  String? intentText;
  if (args.isNotEmpty && args.first.trim().isNotEmpty) {
    intentText = args.first.trim();
    debugPrint('[DPD] CLI arg intent text: "$intentText"');
  }
  intentText ??= await IntentService.getInitialText();
  debugPrint('[DPD] Final intent text: "$intentText"');

  IntentService.initLookupHandler();
  debugPrint('[DPD] Lookup handler initialized');

  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: intentText != null
          ? _IntentBoot(query: intentText)
          : const DpdApp(),
    ),
  );
}

/// When launched via ACTION_PROCESS_TEXT, pre-fill the search query.
class _IntentBoot extends ConsumerWidget {
  const _IntentBoot({required this.query});

  final String query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(externalSearchHandlerProvider).apply(query);
    });
    return const DpdApp();
  }
}
