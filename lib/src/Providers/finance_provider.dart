import 'dart:collection';
import 'package:flutter/material.dart';
import '../../db/db_helper.dart';
import '../models/transactions.dart';
import '../models/budget_models.dart';

class FinanceProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;

  List<MoneyTransaction> _transactions = [];
  UnmodifiableListView<MoneyTransaction> get transactions =>
      UnmodifiableListView(_transactions);

  double get totalIncome =>
      _transactions
          .where((t) => t.isIncome)
          .fold(0.0, (s, t) => s + (t.amount ?? 0.0));

  double get totalExpense =>
      _transactions
          .where((t) => !t.isIncome)
          .fold(0.0, (s, t) => s + (t.amount ?? 0.0));

  double get balance => totalIncome - totalExpense;

  double getTotalExpenseByCategory(String category) {
    return _transactions
        .where((t) => !t.isIncome && t.category == category)
        .fold(0.0, (sum, t) => sum + (t.amount ?? 0.0));
  }

  Map<String, double> get expensesByCategory {
    final Map<String, double> map = {};
    for (var t in _transactions.where((t) => !t.isIncome)) {
      map[t.category] = (map[t.category] ?? 0) + (t.amount ?? 0.0);
    }
    return map;
  }

  Future loadTransactions() async {
    _transactions = await _db.readAllTransactions();
    notifyListeners();
  }

  Future addTransaction(MoneyTransaction tx) async {
    final created = await _db.createTransaction(tx);
    _transactions.insert(0, created);
    notifyListeners();
  }

  Future updateTransaction(MoneyTransaction tx) async {
    await _db.updateTransaction(tx);
    final index = _transactions.indexWhere((e) => e.id == tx.id);
    if (index != -1) _transactions[index] = tx;
    notifyListeners();
  }

  Future deleteTransaction(int id) async {
    await _db.deleteTransaction(id);
    _transactions.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  List<Budget> _budgets = [];
  UnmodifiableListView<Budget> get budgets => UnmodifiableListView(_budgets);

  Future loadBudgets() async {
    _budgets = await _db.readAllBudgets();
    notifyListeners();
  }

  Future addBudget(Budget budget) async {
    final created = await _db.createBudget(budget);
    _budgets.add(created);
    notifyListeners();
  }

  Future updateBudget(Budget budget) async {
    await _db.updateBudget(budget);
    final index = _budgets.indexWhere((b) => b.id == budget.id);
    if (index != -1) _budgets[index] = budget;
    notifyListeners();
  }

  Future deleteBudget(int id) async {
    await _db.deleteBudget(id);
    _budgets.removeWhere((b) => b.id == id);
    notifyListeners();
  }
}
