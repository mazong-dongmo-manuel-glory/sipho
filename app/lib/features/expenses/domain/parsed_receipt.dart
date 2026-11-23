import 'dart:convert';

import 'package:sipho/features/expenses/domain/expense_category.dart';

/// What Gemini read on a receipt. Missing fields stay null.
class ParsedReceipt {
  const ParsedReceipt({
    required this.isReceipt,
    this.merchant,
    this.date,
    this.currency,
    this.totalCents,
    this.category,
    this.confidence = 0,
  });

  final bool isReceipt;
  final String? merchant;
  final String? date;
  final String? currency;
  final int? totalCents;
  final String? category;
  final double confidence;

  static const empty = ParsedReceipt(isReceipt: false);

  bool get needsReview =>
      !isReceipt || confidence < 0.7 || totalCents == null || date == null;

  static const allowedCategories = [
    'rent',
    'internet',
    'energy',
    'phone',
    'groceries',
    'transport',
    'restaurants',
    'shopping',
    'family',
  ];

  /// Parses a model JSON object. Unknown categories and impossible amounts
  /// are dropped instead of kept.
  factory ParsedReceipt.fromModelJson(Map<String, dynamic> json) {
    final category = json['suggestedCategory'];
    final cents = json['totalCents'];
    final date = json['date'];
    final currency = json['currency'];
    final merchant = json['merchant'];
    final confidence = json['confidence'];
    return ParsedReceipt(
      isReceipt: json['isReceipt'] == true,
      merchant: _shortText(merchant, 50),
      date: _isoDate(date),
      currency: _currency(currency),
      totalCents: _cents(cents),
      category: category is String && allowedCategories.contains(category)
          ? category
          : null,
      confidence:
          confidence is num ? confidence.toDouble().clamp(0, 1).toDouble() : 0,
    );
  }

  static ParsedReceipt? tryParse(String raw) {
    final start = raw.indexOf('{');
    final end = raw.lastIndexOf('}');
    if (start < 0 || end <= start) return null;
    try {
      final decoded = jsonDecode(raw.substring(start, end + 1));
      if (decoded is! Map) return null;
      return ParsedReceipt.fromModelJson(Map<String, dynamic>.from(decoded));
    } catch (_) {
      return null;
    }
  }
}

String? _shortText(Object? value, int max) {
  if (value is! String) return null;
  final trimmed = value.trim();
  if (trimmed.isEmpty) return null;
  return trimmed.length <= max ? trimmed : trimmed.substring(0, max);
}

String? _isoDate(Object? value) {
  if (value is! String) return null;
  final match = RegExp(r'^\d{4}-\d{2}-\d{2}$').firstMatch(value.trim());
  if (match == null) return null;
  final parts = value.trim().split('-');
  final year = int.tryParse(parts[0]);
  final month = int.tryParse(parts[1]);
  final day = int.tryParse(parts[2]);
  if (year == null || month == null || day == null) return null;
  if (month < 1 || month > 12 || day < 1 || day > 31) return null;
  return value.trim();
}

String? _currency(Object? value) {
  if (value is! String) return null;
  final code = value.trim().toUpperCase();
  if (!RegExp(r'^[A-Z]{3}$').hasMatch(code)) return null;
  return code;
}

int? _cents(Object? value) {
  if (value is! num) return null;
  final cents = value.toInt();
  if (cents <= 0 || cents >= 10000000) return null;
  return cents;
}

/// Keeps the category list used by the model aligned with the keypad.
bool receiptCategoriesMatchQuickAdd() {
  final quick = kQuickExpenseCategories.map((category) => category.id).toList();
  if (quick.length != ParsedReceipt.allowedCategories.length) return false;
  for (var i = 0; i < quick.length; i++) {
    if (quick[i] != ParsedReceipt.allowedCategories[i]) return false;
  }
  return true;
}
