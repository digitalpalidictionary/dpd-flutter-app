import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'providers/settings_provider.dart';
import 'screens/entry_screen.dart';
import 'screens/search_screen.dart';
import 'screens/settings_screen.dart';
import 'theme/dpd_colors.dart';

class DpdApp extends ConsumerWidget {
  const DpdApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    final lightScheme = ColorScheme(
      brightness: Brightness.light,
      primary: DpdColors.primary,
      onPrimary: DpdColors.dark,
      secondary: DpdColors.primaryAlt,
      onSecondary: DpdColors.light,
      surface: DpdColors.light,
      onSurface: DpdColors.dark,
      surfaceContainerHighest: DpdColors.lightShade,
      outline: DpdColors.gray,
      outlineVariant: DpdColors.grayLight,
      error: Colors.red,
      onError: Colors.white,
    );

    final darkScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: DpdColors.primary,
      onPrimary: DpdColors.dark,
      secondary: DpdColors.primaryAlt,
      onSecondary: DpdColors.light,
      surface: DpdColors.dark,
      onSurface: DpdColors.light,
      surfaceContainerHighest: DpdColors.darkShade,
      outline: DpdColors.gray,
      outlineVariant: DpdColors.grayDark,
      error: Colors.red,
      onError: Colors.white,
    );

    TextTheme buildTextTheme(TextTheme base) => settings.useSerifFont
        ? GoogleFonts.notoSerifTextTheme(base)
        : GoogleFonts.interTextTheme(base);

    return MaterialApp(
      title: 'DPD',
      debugShowCheckedModeBanner: false,
      themeMode: settings.themeMode,
      theme: ThemeData(
        colorScheme: lightScheme,
        scaffoldBackgroundColor: DpdColors.light,
        textTheme: buildTextTheme(ThemeData(colorScheme: lightScheme).textTheme),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: darkScheme,
        scaffoldBackgroundColor: DpdColors.dark,
        textTheme: buildTextTheme(ThemeData.dark().copyWith(colorScheme: darkScheme).textTheme),
        useMaterial3: true,
      ),
      initialRoute: '/',
      onGenerateRoute: _onGenerateRoute,
    );
  }

  Route<dynamic>? _onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const SearchScreen());
      case '/entry':
        final id = settings.arguments as int;
        return MaterialPageRoute(builder: (_) => EntryScreen(headwordId: id));
      case '/settings':
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      default:
        return null;
    }
  }
}
