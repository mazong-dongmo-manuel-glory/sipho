import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/money/money.dart';
import '../../../core/theme/sipho_colors.dart';
import '../../../core/theme/sipho_typography.dart';
import '../../../core/widgets/category_chip.dart';
import '../../../core/widgets/sipho_button_3d.dart';
import '../../expenses/data/expenses_provider.dart';
import '../../gamification/data/game_state_provider.dart';

/// Frame 09 · Ajout express connecté à Riverpod.
class AddExpenseSheet extends ConsumerStatefulWidget {
  const AddExpenseSheet({super.key});

  @override
  ConsumerState<AddExpenseSheet> createState() => _AddExpenseSheetState();
}

class _AddExpenseSheetState extends ConsumerState<AddExpenseSheet> {
  String _amountString = '0';
  String _selectedCategory = 'Restos';
  String _selectedEmoji = '🍔';

  final List<(String, String)> _categories = const [
    ('Restos', '🍔'),
    ('Épicerie', '🛒'),
    ('Transport', '🚌'),
    ('Shopping', '🛍️'),
    ('Loisirs', '🎮'),
    ('Santé', '💊'),
    ('Famille', '💌'),
    ('Autre', '✨'),
  ];

  void _onKeyTap(String key) {
    setState(() {
      if (key == '⌫') {
        if (_amountString.length > 1) {
          _amountString = _amountString.substring(0, _amountString.length - 1);
        } else {
          _amountString = '0';
        }
      } else if (key == ',') {
        if (!_amountString.contains(',')) {
          _amountString += ',';
        }
      } else {
        if (_amountString == '0') {
          _amountString = key;
        } else {
          _amountString += key;
        }
      }
    });
  }

  void _submit() {
    final cleanAmount = _amountString.replaceAll(',', '.');
    final doubleAmount = double.tryParse(cleanAmount) ?? 0.0;
    if (doubleAmount <= 0) return;

    final money = Money.fromMajor(doubleAmount, 'CAD');

    // 1. Ajouter la dépense
    ref.read(expensesProvider.notifier).addExpense(
          title: '$_selectedCategory rapide',
          category: _selectedCategory,
          emoji: _selectedEmoji,
          amount: money,
        );

    // 2. Attribuer l'XP
    ref.read(gameStateProvider.notifier).addXp(5);

    // 3. Fermer et informer
    context.pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${money.format()} ajoutés en $_selectedCategory ! +5 XP 🎉'),
        backgroundColor: SiphoColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SiphoColors.surface,
      appBar: AppBar(
        title: const Text('Ajouter une dépense', style: SiphoTypography.title),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            children: [
              // Montant géant
              Center(
                child: Text(
                  '$_amountString \$ CAD',
                  style: SiphoTypography.amountHero.copyWith(
                    color: SiphoColors.primary,
                    fontSize: 48,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Catégories
              SizedBox(
                height: 48,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final cat = _categories[index];
                    return CategoryChip(
                      label: cat.$1,
                      emoji: cat.$2,
                      isSelected: _selectedCategory == cat.$1,
                      onTap: () => setState(() {
                        _selectedCategory = cat.$1;
                        _selectedEmoji = cat.$2;
                      }),
                    );
                  },
                ),
              ),
              const Spacer(),

              // Clavier numérique géant
              _Keypad(onKeyTap: _onKeyTap),
              const SizedBox(height: 20),

              // Bouton 3D AJOUTER
              SiphoButton3D(
                label: 'AJOUTER (+5 XP)',
                onPressed: _submit,
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}

class _Keypad extends StatelessWidget {
  final ValueChanged<String> onKeyTap;

  const _Keypad({required this.onKeyTap});

  @override
  Widget build(BuildContext context) {
    const keys = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      [',', '0', '⌫'],
    ];

    return Column(
      children: keys.map((row) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: row.map((k) {
              return SizedBox(
                width: 80,
                height: 56,
                child: TextButton(
                  onPressed: () => onKeyTap(k),
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFFF8FAFC),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: SiphoColors.border, width: 1.5),
                    ),
                  ),
                  child: Text(
                    k,
                    style: SiphoTypography.amountHero.copyWith(
                      fontSize: 24,
                      color: SiphoColors.textPrimary,
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
