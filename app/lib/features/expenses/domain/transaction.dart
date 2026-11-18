class SiphoTransaction {
  const SiphoTransaction({
    required this.id,
    required this.amountCents,
    required this.currency,
    this.amountMainCents,
    this.fxRate,
    required this.category,
    this.merchant,
    this.note,
    required this.date,
    this.source = 'manual',
    this.receiptPath,
    this.fixedExpenseId,
    required this.createdAt,
  });

  final String id;
  final int amountCents;
  final String currency;
  final int? amountMainCents;
  final double? fxRate;
  final String category;
  final String? merchant;
  final String? note;
  final String date; // ISO YYYY-MM-DD
  final String source; // manual | receipt | bank
  final String? receiptPath;
  final String? fixedExpenseId;
  final DateTime createdAt;

  factory SiphoTransaction.fromJson(Map<String, dynamic> json) =>
      SiphoTransaction(
        id: json['id'] as String? ?? '',
        amountCents: (json['amountCents'] as num?)?.toInt() ?? 0,
        currency: (json['currency'] as String?) ?? 'CAD',
        amountMainCents: (json['amountMainCents'] as num?)?.toInt(),
        fxRate: (json['fxRate'] as num?)?.toDouble(),
        category: json['category'] as String? ?? 'other',
        merchant: json['merchant'] as String?,
        note: json['note'] as String?,
        date: json['date'] as String? ?? '',
        source: json['source'] as String? ?? 'manual',
        receiptPath: json['receiptPath'] as String?,
        fixedExpenseId: json['fixedExpenseId'] as String?,
        createdAt: json['createdAt'] is DateTime
            ? json['createdAt'] as DateTime
            : DateTime.tryParse('${json['createdAt']}') ?? DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'amountCents': amountCents,
        'currency': currency,
        'amountMainCents': amountMainCents,
        'fxRate': fxRate,
        'category': category,
        'merchant': merchant,
        'note': note,
        'date': date,
        'source': source,
        'receiptPath': receiptPath,
        'fixedExpenseId': fixedExpenseId,
        'createdAt': createdAt.toIso8601String(),
      };

  SiphoTransaction copyWith({
    String? id,
    int? amountCents,
    String? currency,
    int? amountMainCents,
    double? fxRate,
    String? category,
    String? merchant,
    String? note,
    String? date,
    String? source,
    String? receiptPath,
    String? fixedExpenseId,
    DateTime? createdAt,
  }) =>
      SiphoTransaction(
        id: id ?? this.id,
        amountCents: amountCents ?? this.amountCents,
        currency: currency ?? this.currency,
        amountMainCents: amountMainCents ?? this.amountMainCents,
        fxRate: fxRate ?? this.fxRate,
        category: category ?? this.category,
        merchant: merchant ?? this.merchant,
        note: note ?? this.note,
        date: date ?? this.date,
        source: source ?? this.source,
        receiptPath: receiptPath ?? this.receiptPath,
        fixedExpenseId: fixedExpenseId ?? this.fixedExpenseId,
        createdAt: createdAt ?? this.createdAt,
      );
}
