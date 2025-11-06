import 'package:flutter_test/flutter_test.dart';
import 'package:trackerapp/src/Providers/finance_provider.dart';
import 'package:trackerapp/src/models/transactions.dart';

void main() {
  test('Add transaction increases list length and balance updates', () async {
    final provider = FinanceProvider();
    await provider.loadTransactions();

    final initialBalance = provider.balance;

    await provider.addTransaction(
      MoneyTransaction(
        title: 'Tea',
        amount: 20,
        category: 'Food',
        date: DateTime.now(),
        isIncome: false,
      ),
    );

    expect(provider.transactions.length, greaterThan(0));
    expect(provider.balance, lessThan(initialBalance));
  });
}
