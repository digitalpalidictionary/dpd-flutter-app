import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'providers/settings_provider.dart';
import 'providers/search_provider.dart';
import 'services/intent_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final intentText = await IntentService.getInitialText();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
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
      ref.read(searchQueryProvider.notifier).state = query;
    });
    return const DpdApp();
  }
}
