import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/l10n/app_localizations.dart';
import 'app/routes.dart';
import 'core/firebase/firebase_bootstrap.dart';
import 'core/theme/sipho_theme.dart';
import 'features/coach/presentation/coach_popup_host.dart';
import 'features/notifications/data/device_registration.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await bootstrapFirebase();
  runApp(
    const ProviderScope(
      child: SiphoApp(),
    ),
  );
}

class SiphoApp extends ConsumerStatefulWidget {
  const SiphoApp({super.key});

  @override
  ConsumerState<SiphoApp> createState() => _SiphoAppState();
}

class _SiphoAppState extends ConsumerState<SiphoApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(deviceRegistrationProvider).ensureListening();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Sipho',
      debugShowCheckedModeBanner: false,
      theme: SiphoTheme.lightTheme,
      darkTheme: SiphoTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: siphoRouter,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) {
        return Stack(
          children: [
            if (child != null) Positioned.fill(child: child),
            const CoachPopupHost(),
          ],
        );
      },
    );
  }
}
