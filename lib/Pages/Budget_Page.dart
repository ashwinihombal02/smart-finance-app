import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../src/Providers/finance_provider.dart';
import '../src/models/budget_models.dart';

class BudgetPage extends StatelessWidget {
  const BudgetPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FinanceProvider>(context);
    return Scaffold(
      appBar: AppBar(title: const Text("Budgets")),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _showAddBudgetDialog(context, provider),
      ),
      body: ListView(
        children: provider.budgets.map((b) {
          return Card(
            child: ListTile(
              title: Text(b.category),
              subtitle: Text("Limit: ₹${b.monthlyLimit.toStringAsFixed(0)}"),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _showAddBudgetDialog(BuildContext context, FinanceProvider provider) {
    final catCtrl = TextEditingController();
    final limitCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add Budget"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: catCtrl, decoration: const InputDecoration(labelText: "Category")),
            TextField(controller: limitCtrl, decoration: const InputDecoration(labelText: "Monthly Limit"), keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              provider.addBudget(Budget(
                category: catCtrl.text.trim(),
                monthlyLimit: double.tryParse(limitCtrl.text.trim()) ?? 0.0,
              ));
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }
}
