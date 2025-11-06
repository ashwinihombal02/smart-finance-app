import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'Add_Edit_Trans.dart';
import '../src/Providers/finance_provider.dart';
import 'package:intl/intl.dart';

class TransactionsPage extends StatelessWidget {
  const TransactionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FinanceProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('All Transactions')),
      body: provider.transactions.isEmpty
          ? const Center(child: Text('No transactions yet'))
          : ListView.builder(
              itemCount: provider.transactions.length,
              itemBuilder: (context, index) {
                final t = provider.transactions[index];
                return Dismissible(
                  key: ValueKey(t.id),
                  background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.only(left: 20),
                      child: const Icon(Icons.delete)),
                  secondaryBackground: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      child: const Icon(Icons.delete)),
                  onDismissed: (_) async {
                    // store a copy for undo
                    final removed = t;
                    await provider.deleteTransaction(t.id!);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Transaction deleted'),
                        action: SnackBarAction(
                          label: 'UNDO',
                          onPressed: () async {
                            await provider
                                .addTransaction(removed.copyWith(id: null));
                          },
                        ),
                      ),
                    );
                  },
                  child: ListTile(
                    leading:
                        CircleAvatar(child: Text(t.category[0].toUpperCase())),
                    title: Text(t.title),
                    subtitle: Text(DateFormat.yMMMd().format(t.date)),
                    trailing: Text(
                        (t.isIncome ? '+' : '-') +
                            '₹${t.amount.toStringAsFixed(2)}',
                        style: TextStyle(
                            color: t.isIncome ? Colors.green : Colors.red)),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  AddEditTransactionPage(editTransaction: t)));
                    },
                  ),
                );
              },
            ),
    );
  }
}
