class Budget {
  final int? id;
  final String category;
  final double monthlyLimit;

  Budget({
    this.id,
    required this.category,
    required this.monthlyLimit,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'category': category,
    'monthlyLimit': monthlyLimit,
  };

  factory Budget.fromMap(Map<String, dynamic> map) {
    return Budget(
      id: map['id'],
      category: map['category'],
      monthlyLimit: (map['monthlyLimit'] as num).toDouble(),
    );
  }

  Budget copyWith({
    int? id,
    String? category,
    double? monthlyLimit,
  }) {
    return Budget(
      id: id ?? this.id,
      category: category ?? this.category,
      monthlyLimit: monthlyLimit ?? this.monthlyLimit,
    );
  }
}
