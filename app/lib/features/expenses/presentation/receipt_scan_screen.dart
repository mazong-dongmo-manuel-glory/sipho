import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sipho/app/l10n/app_localizations.dart';
import 'package:sipho/app/theme/app_colors.dart';
import 'package:sipho/core/ai/sipho_ai_client.dart';
import 'package:sipho/core/analytics/analytics_service.dart';
import 'package:sipho/core/animations/lottie_widget.dart';
import 'package:sipho/features/expenses/data/receipt_parser.dart';
import 'package:sipho/features/expenses/domain/parsed_receipt.dart';

class ReceiptScanScreen extends ConsumerStatefulWidget {
  const ReceiptScanScreen({super.key});

  @override
  ConsumerState<ReceiptScanScreen> createState() => _ReceiptScanScreenState();
}

class _ReceiptScanScreenState extends ConsumerState<ReceiptScanScreen> {
  bool _reading = false;

  Future<void> _pick(ImageSource source) async {
    if (_reading) return;
    final l10n = AppLocalizations.of(context);
    final picker = ImagePicker();
    XFile? file;
    try {
      file = await picker.pickImage(
        source: source,
        maxWidth: 1600,
        imageQuality: 80,
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.scanReadError)),
      );
      return;
    }
    if (file == null || !mounted) return;
    setState(() => _reading = true);
    try {
      final bytes = await file.readAsBytes();
      final parsed = await ref.read(receiptParserProvider).parse(bytes);
      try {
        await ref
            .read(analyticsServiceProvider)
            .logReceiptScanned(success: true);
      } catch (error) {
        debugPrint('Analytics receipt_scanned skipped: $error');
      }
      if (!mounted) return;
      await context.push('/expenses/validate', extra: parsed);
    } catch (error) {
      debugPrint('[SiphoAI] Receipt scan failed: $error');
      try {
        await ref
            .read(analyticsServiceProvider)
            .logReceiptScanned(success: false);
      } catch (analyticsError) {
        debugPrint('Analytics receipt_scanned skipped: $analyticsError');
      }
      if (!mounted) return;
      unawaited(
        showSiphoAiErrorSnackBar(
          context,
          error,
          l10n,
          fallback: l10n.scanReadError,
        ),
      );
      await context.push('/expenses/validate', extra: ParsedReceipt.empty);
    } finally {
      if (mounted) setState(() => _reading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.ink,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),
            Row(
              children: [
                GestureDetector(
                  onTap: () => context.pop(),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      '‹',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                Text(
                  l10n.scanTitle,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            Text(
              _reading ? l10n.scanReading : l10n.scanHint,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: 321,
              height: 407,
              decoration: BoxDecoration(
                color: AppColors.scanWell,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.accent, width: 3),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 233,
                    height: 306,
                    padding: const EdgeInsets.fromLTRB(18, 23, 18, 16),
                    decoration: BoxDecoration(
                      color: AppColors.ticketPaper,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Column(
                      children: [
                        Text(
                          'IGA',
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 30,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primaryDark,
                          ),
                        ),
                        SizedBox(height: 18),
                        _TicketLine('10 NOV. 2026'),
                        SizedBox(height: 14),
                        _TicketLine('Épicerie', trailing: '42,17'),
                        _TicketLine('TPS', trailing: '2,11'),
                        _TicketLine('TVQ', trailing: '4,21'),
                        _TicketLine('────────────────'),
                        _TicketLine('TOTAL', trailing: '48,49 \$'),
                      ],
                    ),
                  ),
                  const IgnorePointer(
                    child: LottieWidget(
                      assetPath: 'assets/animations/scan_laser.json',
                      width: 300,
                      height: 280,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.scanPrivacy,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 13,
                color: AppColors.mist,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: _reading ? null : () => _pick(ImageSource.camera),
              child: Container(
                width: 80,
                height: 80,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Container(
                  width: 64,
                  height: 64,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: AppColors.accent,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.photo_camera,
                    color: AppColors.primaryDark,
                    size: 28,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _reading ? null : () => _pick(ImageSource.gallery),
              child: Text(
                l10n.scanGallery,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }
}

class _TicketLine extends StatelessWidget {
  const _TicketLine(this.label, {this.trailing});

  final String label;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        if (trailing != null) ...[
          const Spacer(),
          Text(
            trailing!,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}
