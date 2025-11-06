import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../src/Providers/finance_provider.dart';
import 'Add_Edit_Trans.dart';
import 'Transaction_Page.dart';
import 'Budget_Page.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FinanceProvider>(context);
    final formatter = NumberFormat.currency(symbol: '₹');
    final expensesByCategory = provider.expensesByCategory;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Finance'),
        backgroundColor: Colors.teal,
      ),
      drawer: _buildDrawer(context),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        onPressed: () =>
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddEditTransactionPage()),
            ),
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: () async => await provider.loadTransactions(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBalanceCard(context, provider, formatter),
              const SizedBox(height: 20),
              _buildBudgetOverview(provider, formatter),
              const SizedBox(height: 20),
              _buildRecentTransactions(provider, formatter, context),
              const SizedBox(height: 20),
              _buildPieChart(expensesByCategory),
            ],
          ),
        ),
      ),
    );
  }

  Drawer _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.teal),
            child: Text(
                'Menu', style: TextStyle(color: Colors.white, fontSize: 24)),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.list),
            title: const Text('Transactions'),
            onTap: () =>
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TransactionsPage()),
                ),
          ),
          ListTile(
            leading: const Icon(Icons.pie_chart),
            title: const Text('Budgets'),
            onTap: () =>
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const BudgetPage()),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard(BuildContext context, FinanceProvider provider,
      NumberFormat formatter) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Current Balance',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(formatter.format(provider.balance),
                style: const TextStyle(fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Income: ${formatter.format(provider.totalIncome)}',
                    style: const TextStyle(color: Colors.green)),
                Text('Expense: ${formatter.format(provider.totalExpense)}',
                    style: const TextStyle(color: Colors.red)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetOverview(FinanceProvider provider,
      NumberFormat formatter) {
    if (provider.budgets.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Budget Overview',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        ...provider.budgets.map((b) {
          final spent = provider.getTotalExpenseByCategory(b.category);
          final percent = spent / b.monthlyLimit;
          Color barColor;
          if (percent < 0.7) {
            barColor = Colors.green;
          } else if (percent < 1) {
            barColor = Colors.orange;
          } else {
            barColor = Colors.red;
          }

          return Card(
            child: ListTile(
              title: Text(b.category),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 6),
                  LinearProgressIndicator(
                    value: percent > 1 ? 1 : percent,
                    backgroundColor: Colors.grey.shade200,
                    color: barColor,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Spent: ${formatter.format(spent)} / ${formatter.format(
                        b.monthlyLimit)}',
                    style: TextStyle(color: barColor),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildRecentTransactions(FinanceProvider provider,
      NumberFormat formatter, BuildContext context) {
    final recent = provider.transactions.take(8).toList();

    if (recent.isEmpty) {
      return const Text('No recent transactions yet.');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Recent Transactions',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        ...recent.map((t) {
          final amount = t.amount ?? 0.0;
          final isIncome = t.isIncome ?? false;
          final sign = isIncome ? '+' : '-';
          final amountText = formatter.format(amount);
          final title = t.title ?? '';
          final categoryLetter = (t.category?.isNotEmpty ?? false)
              ? t.category![0].toUpperCase()
              : '?';
          final dateText = t.date != null ? DateFormat.yMMMd().format(t.date!) : '';


          return Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: isIncome ? Colors.green : Colors.red,
                child: Text(
                  categoryLetter,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              title: Text(title),
              subtitle: dateText.isNotEmpty ? Text(dateText) : null,
              trailing: Text(
                '$sign$amountText', // <-- Null-safe
                style: TextStyle(color: isIncome ? Colors.green : Colors.red),
              ),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddEditTransactionPage(editTransaction: t),
                ),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildPieChart(Map<String, double> data) {

    final filteredData = data..removeWhere((key, value) => value == 0);

    if (filteredData.isEmpty) {
      return const Text('No expense data available.');
    }

    final total = filteredData.values.fold<double>(
      0.0,
          (sum, value) => sum + (value ?? 0.0),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Expenses by Category',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 250,
          child: PieChart(
            PieChartData(
              sections: filteredData.entries.map((e) {
                final percentage = (e.value / total) * 100;
                final color = Colors.primaries[
                filteredData.keys.toList().indexOf(e.key) %
                    Colors.primaries.length];

                return PieChartSectionData(
                  color: color,
                  value: e.value,
                  title: '${e.key}\n${percentage.toStringAsFixed(1)}%',
                  radius: 70,
                  titleStyle: const TextStyle(
                    fontSize: 11,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }).toList(),
              sectionsSpace: 2,
              centerSpaceRadius: 40,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 6,
          children: filteredData.keys.map((category) {
            final color = Colors.primaries[
            filteredData.keys.toList().indexOf(category) %
                Colors.primaries.length];
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 12, height: 12, color: color),
                const SizedBox(width: 6),
                Text(category, style: const TextStyle(fontSize: 13)),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}
