import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/routes.dart';
import 'core/theme/sipho_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: SiphoApp(),
    ),
  );
}

class SiphoApp extends StatelessWidget {
  const SiphoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Sipho',
      debugShowCheckedModeBanner: false,
      theme: SiphoTheme.lightTheme,
      darkTheme: SiphoTheme.darkTheme,
      themeMode: ThemeMode.light,
      routerConfig: siphoRouter,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('fr', 'CA'),
        Locale('fr', 'FR'),
        Locale('en', 'CA'),
        Locale('en', 'US'),
      ],
    );
  }
}
