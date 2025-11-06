import 'package:flutter/foundation.dart';

class MoneyTransaction {
  final int? id;
  final String title;
  final double amount;
  final String category;
  final DateTime date;
  final bool isIncome;

  MoneyTransaction({
    this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    required this.isIncome,
  });

  MoneyTransaction copyWith({
    int? id,
    String? title,
    double? amount,
    String? category,
    DateTime? date,
    bool? isIncome,
  }) {
    return MoneyTransaction(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      isIncome: isIncome ?? this.isIncome,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'category': category,
      'date': date.toIso8601String(),
      'isIncome': isIncome ? 1 : 0,
    };
  }

  factory MoneyTransaction.fromMap(Map<String, dynamic> map) {
    return MoneyTransaction(
      id: map['id'] as int?,
      title: map['title'],
      amount: (map['amount'] as num).toDouble(),
      category: map['category'],
      date: DateTime.parse(map['date']),
      isIncome: (map['isIncome'] as int) == 1,
    );
  }

  @override
  String toString() {
    return 'MoneyTransaction{id: $id, title: $title, amount: $amount, category: $category, date: $date, isIncome: $isIncome}';
  }
}
