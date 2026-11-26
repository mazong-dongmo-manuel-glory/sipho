import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../app/l10n/app_localizations.dart';
import '../../../core/feedback/feedback_cue.dart';
import '../../../core/feedback/feedback_service.dart';
import '../../../core/theme/sipho_colors.dart';
import '../../../core/theme/sipho_typography.dart';
import '../../../core/widgets/sipho_button_3d.dart';
import '../../../core/widgets/sipho_fill_scroll.dart';
import '../data/receipt_scan_service.dart';

/// Frame 11a · Scan · photo → Storage → `parseReceipt`.
class ScanScreen extends ConsumerStatefulWidget {
  const ScanScreen({super.key});

  @override
  ConsumerState<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends ConsumerState<ScanScreen> {
  bool _busy = false;
  String? _status;

  Future<void> _scan(ImageSource source) async {
    if (_busy) return;
    final l10n = AppLocalizations.of(context);
    setState(() {
      _busy = true;
      _status = null;
    });
    try {
      final service = ref.read(receiptScanServiceProvider);
      final file = await service.pick(source: source);
      if (file == null) {
        if (mounted) setState(() => _busy = false);
        return;
      }
      if (mounted) setState(() => _status = 'Lecture du ticket…');
      final parsed = await service.uploadAndParse(file);
      if (!mounted) return;
      ref.read(feedbackServiceProvider).play(SiphoCue.scanDone);
      context.push('/expenses/validate', extra: parsed.toExtra());
    } catch (e) {
      if (!mounted) return;
      ref.read(feedbackServiceProvider).play(SiphoCue.softError);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${l10n.authErrorGeneric}\n$e'),
          backgroundColor: SiphoColors.primaryDark,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
          _status = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: SiphoColors.primaryDark,
      body: SafeArea(
        child: SiphoFillScroll(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: _busy ? null : () => context.pop(),
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
              ),
              Text(
                l10n.scanTitle,
                textAlign: TextAlign.center,
                style: SiphoTypography.title.copyWith(
                  fontSize: 28,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.scanHint,
                textAlign: TextAlign.center,
                style: SiphoTypography.body.copyWith(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
              const Spacer(),
              Container(
                height: MediaQuery.sizeOf(context).height < 500 ? 160 : 320,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: SiphoColors.accentGold, width: 3),
                  color: Colors.black26,
                ),
                child: Center(
                  child: _busy
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const CircularProgressIndicator(color: Colors.white),
                            if (_status != null) ...[
                              const SizedBox(height: 16),
                              Text(
                                _status!,
                                textAlign: TextAlign.center,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: SiphoTypography.body.copyWith(color: Colors.white70),
                              ),
                            ],
                          ],
                        )
                      : const Icon(
                          Icons.document_scanner_outlined,
                          color: Colors.white54,
                          size: 64,
                        ),
                ),
              ),
              const Spacer(),
              Text(
                l10n.scanPrivacy,
                textAlign: TextAlign.center,
                style: SiphoTypography.label.copyWith(
                  color: Colors.white70,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 16),
              SiphoButton3D(
                label: _busy ? '…' : 'Prendre la photo',
                variant: SiphoButtonVariant.secondary,
                onPressed: _busy ? null : () => _scan(ImageSource.camera),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: _busy ? null : () => _scan(ImageSource.gallery),
                child: Text(
                  l10n.scanGallery,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: SiphoTypography.bodyBold.copyWith(color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
