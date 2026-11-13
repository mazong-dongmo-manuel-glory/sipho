import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sipho/app/l10n/app_localizations.dart';
import 'package:sipho/app/router.dart';
import 'package:sipho/app/theme/app_theme.dart';
import 'package:sipho/features/notifications/presentation/notification_binder.dart';

class SiphoApp extends ConsumerWidget {
  const SiphoApp({super.key, required this.flavor});

  final String flavor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'Sipho',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      routerConfig: router,
      builder: (context, child) => Stack(
        children: [
          if (child != null) Positioned.fill(child: child),
          const NotificationBinder(),
        ],
      ),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
