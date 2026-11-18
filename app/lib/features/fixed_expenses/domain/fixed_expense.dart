class FixedExpense {
  const FixedExpense({
    required this.id,
    required this.name,
    required this.category,
    required this.icon,
    required this.amountCents,
    required this.dueDay,
    this.payMode = 'auto',
    this.type = 'bill',
    this.active = true,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String category;
  final String icon;
  final int amountCents;
  final int dueDay;
  final String payMode; // auto | manual
  final String type; // bill | envelope
  final bool active;
  final DateTime createdAt;

  factory FixedExpense.fromJson(Map<String, dynamic> json) => FixedExpense(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        category: json['category'] as String? ?? 'other',
        icon: json['icon'] as String? ?? '',
        amountCents: (json['amountCents'] as num?)?.toInt() ?? 0,
        dueDay: (json['dueDay'] as num?)?.toInt() ?? 1,
        payMode: json['payMode'] as String? ?? 'auto',
        type: json['type'] as String? ?? 'bill',
        active: json['active'] as bool? ?? true,
        createdAt: json['createdAt'] is DateTime
            ? json['createdAt'] as DateTime
            : DateTime.tryParse('${json['createdAt']}') ?? DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category,
        'icon': icon,
        'amountCents': amountCents,
        'dueDay': dueDay,
        'payMode': payMode,
        'type': type,
        'active': active,
        'createdAt': createdAt.toIso8601String(),
      };

  FixedExpense copyWith({
    String? id,
    String? name,
    String? category,
    String? icon,
    int? amountCents,
    int? dueDay,
    String? payMode,
    String? type,
    bool? active,
    DateTime? createdAt,
  }) =>
      FixedExpense(
        id: id ?? this.id,
        name: name ?? this.name,
        category: category ?? this.category,
        icon: icon ?? this.icon,
        amountCents: amountCents ?? this.amountCents,
        dueDay: dueDay ?? this.dueDay,
        payMode: payMode ?? this.payMode,
        type: type ?? this.type,
        active: active ?? this.active,
        createdAt: createdAt ?? this.createdAt,
      );
}
