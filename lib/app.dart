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
      outline: DpdColors.grayTransparent,
      outlineVariant: DpdColors.grayDark,
      error: Colors.red,
      onError: Colors.white,
    );

    TextTheme buildTextTheme(TextTheme base) {
      final themed = settings.useSerifFont
          ? GoogleFonts.notoSerifTextTheme(base)
          : GoogleFonts.interTextTheme(base);
      // Material 3 bodyMedium default is 14sp
      const baseSize = 14.0;
      return themed.copyWith(
        // h3 equivalent — headword titles at 130%
        titleLarge: themed.titleLarge?.copyWith(
          fontSize: baseSize * 1.3,
          height: 1.3,
          fontWeight: FontWeight.w700,
        ),
        // Default body text — line-height 150%
        bodyLarge: themed.bodyLarge?.copyWith(height: 1.5),
        bodyMedium: themed.bodyMedium?.copyWith(height: 1.5),
        bodySmall: themed.bodySmall?.copyWith(height: 1.5),
        // Button text — 80% size
        labelSmall: themed.labelSmall?.copyWith(fontSize: baseSize * 0.8),
        labelMedium: themed.labelMedium?.copyWith(fontSize: baseSize * 0.8),
      );
    }

    return MaterialApp(
      title: 'DPD',
      debugShowCheckedModeBanner: false,
      themeMode: settings.themeMode,
      theme: ThemeData(
        colorScheme: lightScheme,
        scaffoldBackgroundColor: DpdColors.light,
        textTheme: buildTextTheme(
          ThemeData(colorScheme: lightScheme).textTheme,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: darkScheme,
        scaffoldBackgroundColor: DpdColors.dark,
        textTheme: buildTextTheme(
          ThemeData.dark().copyWith(colorScheme: darkScheme).textTheme,
        ),
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
