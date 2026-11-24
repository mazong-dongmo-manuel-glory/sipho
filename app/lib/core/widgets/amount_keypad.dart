import 'package:flutter/material.dart';
import '../theme/sipho_palette.dart';
import '../theme/sipho_typography.dart';

/// Clavier numérique géant (Figma saisie express / montant du socle).
class AmountKeypad extends StatelessWidget {
  final ValueChanged<String> onKeyTap;

  const AmountKeypad({super.key, required this.onKeyTap});

  static const keys = [
    ['1', '2', '3'],
    ['4', '5', '6'],
    ['7', '8', '9'],
    [',', '0', '⌫'],
  ];

  @override
  Widget build(BuildContext context) {
    final keyBg = SiphoPalette.surface(context);
    final keyFg = SiphoPalette.textPrimary(context);
    return Column(
      children: keys.map((row) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            children: row.map((k) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: SizedBox(
                    height: 47,
                    child: Material(
                      color: keyBg,
                      borderRadius: BorderRadius.circular(14),
                      child: InkWell(
                        onTap: () => onKeyTap(k),
                        borderRadius: BorderRadius.circular(14),
                        child: Center(
                          child: k == '⌫'
                              ? Icon(Icons.backspace_outlined, color: keyFg, size: 22)
                              : Text(
                                  k,
                                  style: SiphoTypography.amountHero.copyWith(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w800,
                                    color: keyFg,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }
}

/// Helpers de saisie montant en chaîne « 0 » / « 18,50 ».
mixin AmountInputMixin<T extends StatefulWidget> on State<T> {
  String amountString = '0';

  void onAmountKey(String key) {
    setState(() {
      if (key == '⌫') {
        amountString = amountString.length > 1 ? amountString.substring(0, amountString.length - 1) : '0';
      } else if (key == ',') {
        if (!amountString.contains(',')) amountString += ',';
      } else if (amountString == '0') {
        amountString = key;
      } else {
        amountString += key;
      }
    });
  }

  double get amountMajor => double.tryParse(amountString.replaceAll(',', '.')) ?? 0;
  int get amountCents => (amountMajor * 100).round();
}
