import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'screens/intro_page.dart';

import 'state/app_state.dart';
import 'state/my_drawings_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  uploadedImagesNotifier.value = await loadMyDrawings();

  // Persist on changes (web implementation uses localStorage).
  uploadedImagesNotifier.addListener(() {
    // Fire-and-forget; non-web is a no-op.
    // ignore: discarded_futures
    saveMyDrawings(uploadedImagesNotifier.value);
  });

  runApp(const ColorYourMindApp());
}

class ColorYourMindApp extends StatelessWidget {
  const ColorYourMindApp({super.key});

  ThemeData _buildTheme(Brightness brightness) {
    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.purple,
        brightness: brightness,
      ),
    );

    final cs = base.colorScheme;
    return base.copyWith(
      scaffoldBackgroundColor: cs.surface,
      cardTheme: CardThemeData(
        color: cs.surface,
        surfaceTintColor: cs.surfaceTint,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cs.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(color: cs.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(color: cs.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(color: cs.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: appLocaleNotifier,
      builder: (context, locale, child) {
        return MaterialApp(
          title: 'Color Your Mind',
          debugShowCheckedModeBanner: false,
          theme: _buildTheme(Brightness.light),
          darkTheme: _buildTheme(Brightness.dark),
          themeMode: ThemeMode.system,
          locale: locale,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', 'US'),
            Locale('ko', 'KR'),
          ],
          home: const IntroPage(),
        );
      },
    );
  }
}
