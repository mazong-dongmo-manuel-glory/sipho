import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sipho/app/l10n/app_localizations.dart';
import 'package:sipho/app/theme/app_colors.dart';
import 'package:sipho/app/theme/app_spacing.dart';
import 'package:sipho/core/money/money_formatter.dart';
import 'package:sipho/core/widgets/sipho_art.dart';
import 'package:sipho/core/widgets/sipho_button_3d.dart';
import 'package:sipho/features/expenses/presentation/expense_category_label.dart';
import 'package:sipho/features/finance/presentation/finance_providers.dart';
import 'package:sipho/features/recap/domain/month_recap.dart';

class MonthlyRecapScreen extends ConsumerStatefulWidget {
  const MonthlyRecapScreen({super.key});

  @override
  ConsumerState<MonthlyRecapScreen> createState() => _MonthlyRecapScreenState();
}

class _MonthlyRecapScreenState extends ConsumerState<MonthlyRecapScreen> {
  final _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final now = DateTime.now();
    final monthKey = currentMonthKey();
    final previous = DateTime(now.year, now.month - 1);
    final currentTx =
        ref.watch(transactionsForMonthProvider(monthKey)).valueOrNull ?? const [];
    final previousTx = ref
            .watch(transactionsForMonthProvider(monthKeyOf(previous)))
            .valueOrNull ??
        const [];
    final currency =
        ref.watch(userFinanceProvider).valueOrNull?.currency ?? 'CAD';
    final facts = buildMonthRecap(
      current: [
        for (final tx in currentTx)
          (
            category: tx.category,
            amountCents: tx.amountCents,
            amountMainCents: tx.amountMainCents,
            feeCents: tx.feeCents,
          ),
      ],
      previous: [
        for (final tx in previousTx)
          (
            category: tx.category,
            amountCents: tx.amountCents,
            amountMainCents: tx.amountMainCents,
            feeCents: tx.feeCents,
          ),
      ],
    );
    final locale = Localizations.localeOf(context).toString();
    final monthName = DateFormat.MMMM(locale).format(now);
    final savedLabel = MoneyFormatter(locale).formatCents(facts.savedCents, currency);
    final focusLabel = facts.focusCategory == null
        ? ''
        : expenseCategoryLabel(l10n, facts.focusCategory!);
    final pages = facts.expenseCount == 0
        ? [
            _Page(
              background: AppColors.primaryDark,
              ink: Colors.white,
              track: AppColors.recapTrack,
              weave: AppColors.weaveGreen,
              buttonColor: Colors.white,
              buttonText: AppColors.primaryDark,
              body: _Empty(l10n),
            ),
          ]
        : [
            _Page(
              background: AppColors.primaryDark,
              ink: Colors.white,
              track: AppColors.recapTrack,
              weave: AppColors.weaveGreen,
              buttonColor: Colors.white,
              buttonText: AppColors.primaryDark,
              body: _Spent(
                title: l10n.recapSpentTitleMonth(monthName),
                count: '${facts.expenseCount}',
                label: l10n.recapSpentLabel,
              ),
            ),
            _Page(
              background: AppColors.accent,
              ink: AppColors.primaryDark,
              track: AppColors.recapGoldTrack,
              weave: AppColors.weaveGold,
              buttonColor: AppColors.primaryDark,
              buttonText: Colors.white,
              body: _Progress(
                title: l10n.recapProgressTitle,
                category: focusLabel,
                value: facts.focusImproved
                    ? l10n.recapFocusDrop(facts.focusPercent)
                    : l10n.recapFocusShare(facts.focusPercent),
                caption: l10n.recapProgressCaption,
              ),
            ),
            _Page(
              background: AppColors.primary,
              ink: Colors.white,
              track: Colors.white.withValues(alpha: 0.45),
              weave: AppColors.weaveGreen,
              buttonColor: Colors.white,
              buttonText: AppColors.primaryDark,
              body: _Saved(
                title: l10n.recapSavedTitle,
                value: savedLabel,
                label: l10n.recapSavedLabel,
              ),
            ),
          ];
    final safePage = _page >= pages.length ? 0 : _page;
    final current = pages[safePage];
    return Scaffold(
      backgroundColor: current.background,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.pagePadding),
              child: Row(
                children: [
                  for (var i = 0; i < pages.length; i++) ...[
                    Expanded(
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: i == safePage ? current.ink : current.track,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                    if (i != pages.length - 1) const SizedBox(width: 7),
                  ],
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: pages.length,
                onPageChanged: (index) => setState(() => _page = index),
                itemBuilder: (context, index) {
                  final page = pages[index];
                  return Stack(
                    children: [
                      Positioned.fill(child: _Weave(color: page.weave)),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.pagePadding,
                          28,
                          AppSpacing.pagePadding,
                          0,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.recapKickerMonth(monthName),
                              style: TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: page.ink,
                              ),
                            ),
                            const SizedBox(height: 28),
                            Expanded(child: page.body),
                            SiphoButton3D(
                              label: l10n.recapShare,
                              onPressed: () => Share.share(
                                l10n.recapShareReal(
                                  monthName,
                                  facts.expenseCount,
                                  savedLabel,
                                ),
                              ),
                              color: page.buttonColor,
                              textColor: page.buttonText,
                              shadowColor: AppColors.primaryDark,
                              height: 52,
                              borderRadius: figmaButtonRadius,
                            ),
                            const SizedBox(height: 12),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Page {
  const _Page({
    required this.background,
    required this.ink,
    required this.track,
    required this.weave,
    required this.buttonColor,
    required this.buttonText,
    required this.body,
  });

  final Color background;
  final Color ink;
  final Color track;
  final Color weave;
  final Color buttonColor;
  final Color buttonText;
  final Widget body;
}

class _Spent extends StatelessWidget {
  const _Spent({
    required this.title,
    required this.count,
    required this.label,
  });

  final String title;
  final String count;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 34,
            fontWeight: FontWeight.w900,
            height: 1.2,
            color: Colors.white,
          ),
        ),
        Text(
          count,
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 112,
            fontWeight: FontWeight.w900,
            height: 1.05,
            color: AppColors.accent,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 32,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
        const Spacer(),
        const Center(child: SiphoArt.proud(frame: 193)),
        const SizedBox(height: 12),
      ],
    );
  }
}

class _Progress extends StatelessWidget {
  const _Progress({
    required this.title,
    required this.category,
    required this.value,
    required this.caption,
  });

  final String title;
  final String category;
  final String value;
  final String caption;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 34,
            fontWeight: FontWeight.w900,
            height: 1.2,
            color: AppColors.primaryDark,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          category,
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 30,
            fontWeight: FontWeight.w800,
            color: AppColors.primaryDark,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 64,
            fontWeight: FontWeight.w900,
            height: 1.05,
            color: AppColors.primaryDark,
          ),
        ),
        const Spacer(),
        const Center(
          child: SizedBox(
            width: 220,
            height: 180,
            child: _DancingBird(),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            caption,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryDark,
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _Saved extends StatelessWidget {
  const _Saved({
    required this.title,
    required this.value,
    required this.label,
  });

  final String title;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 34,
            fontWeight: FontWeight.w900,
            height: 1.2,
            color: Colors.white,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 56,
            fontWeight: FontWeight.w900,
            height: 1.05,
            color: AppColors.accent,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 30,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
        const Spacer(),
        const Center(child: SiphoArt.celebrating(frame: 220)),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty(this.l10n);

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.recapEmptyTitle,
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 34,
            fontWeight: FontWeight.w900,
            height: 1.2,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          l10n.recapEmptyBody,
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            height: 1.3,
            color: Colors.white,
          ),
        ),
        const Spacer(),
        const Center(child: SiphoArt.happy(frame: 120)),
      ],
    );
  }
}


class _DancingBird extends StatelessWidget {
  const _DancingBird();

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -12 * math.pi / 180,
      child: SvgPicture.asset(
        'assets/images/sipho_dancing.svg',
        width: 190,
        height: 165,
      ),
    );
  }
}

class _Weave extends StatelessWidget {
  const _Weave({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (var i = 0; i < 6; i++)
            Positioned(
              left: -20 + i * 67,
              top: 40,
              child: Transform.rotate(
                angle: -18 * math.pi / 180,
                child: Container(
                  width: 2,
                  height: 430,
                  color: color.withValues(alpha: 0.28),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
