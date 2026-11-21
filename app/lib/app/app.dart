import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sipho/app/l10n/app_localizations.dart';
import 'package:sipho/app/router.dart';
import 'package:sipho/app/theme/app_theme.dart';
import 'package:sipho/core/feedback/feedback_binder.dart';
import 'package:sipho/features/coach/presentation/coach_popup_host.dart';
import 'package:sipho/features/notifications/presentation/notification_binder.dart';

class SiphoApp extends ConsumerWidget {
  const SiphoApp({super.key, required this.flavor});

  final String flavor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'Sipho',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      // Cream brand screens hardcode light surfaces; following the OS dark mode
      // made status-bar icons white on cream (unreadable). Keep light until every
      // screen is theme-aware.
      themeMode: ThemeMode.light,
      routerConfig: router,
      builder: (context, child) {
        final overlay =
            AppTheme.overlayFor(Theme.of(context).brightness);
        // Apply immediately: AnnotatedRegion alone is often ignored by nested
        // Scaffolds on Android until the next frame / route change.
        SystemChrome.setSystemUIOverlayStyle(overlay);
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: overlay,
          child: Stack(
            children: [
              if (child != null) Positioned.fill(child: child),
              const NotificationBinder(),
              const FeedbackBinder(),
              const CoachPopupHost(),
            ],
          ),
        );
      },
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
