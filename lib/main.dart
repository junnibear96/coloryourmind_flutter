import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'screens/intro_page.dart';

import 'state/app_state.dart';
import 'state/my_drawings_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  uploadedImagesNotifier.value = await loadMyDrawings();
  runApp(const ColorYourMindApp());
}

class ColorYourMindApp extends StatelessWidget {
  const ColorYourMindApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: appLocaleNotifier,
      builder: (context, locale, child) {
        return MaterialApp(
          title: 'Color Your Mind',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple),
            useMaterial3: true,
          ),
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
