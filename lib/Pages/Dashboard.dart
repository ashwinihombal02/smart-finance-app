import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
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
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFEFFFEF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Builder(
          builder: (context) => GestureDetector(
            onTap: () {
              // Opens the drawer
              Scaffold.of(context).openDrawer();
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 24,
                    height: 2,
                    color: Colors.black87,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 24,
                    height: 2,
                    color: Colors.black87,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 24,
                    height: 2,
                    color: Colors.black87,
                  ),
                ],
              ),
            ),
          ),
        ),
        title: Text(
          'Smart Finance',
          style: GoogleFonts.poppins(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: MediaQuery.of(context).size.width * 0.05,
          ),
        ),
        actions: const [
          SizedBox(width: 10), // Remove notification icon here
        ],
      ),

      drawer: _buildDrawer(context),
      floatingActionButton: _buildFloatingActionButtons(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: RefreshIndicator(
        onRefresh: () async => await provider.loadTransactions(),
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: size.width * 0.05,
              vertical: size.height * 0.015,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderSection(size),
                SizedBox(height: size.height * 0.02),
                _buildBalanceCard(context, provider, formatter, size),
                SizedBox(height: size.height * 0.02),
                _buildBudgetOverview(provider, formatter, size),
                SizedBox(height: size.height * 0.02),
                _buildRecentTransactions(provider, formatter, context, size),
                SizedBox(height: size.height * 0.02),
                _buildPieChart(expensesByCategory, size),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection(Size size) {
    return Text(
      "A Finance Tracker For You",
      style: GoogleFonts.poppins(
        fontSize: size.width * 0.065,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Drawer _buildDrawer(BuildContext context) {
    return Drawer(
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(25), bottomRight: Radius.circular(25))),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                Colors.green.shade400,
                Colors.greenAccent.shade200
              ]),
            ),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                'Menu',
                style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
          _drawerTile(
              icon: Icons.dashboard,
              text: 'Dashboard',
              onTap: () => Navigator.pop(context)),
          _drawerTile(
            icon: Icons.list_alt_rounded,
            text: 'Transactions',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TransactionsPage()),
            ),
          ),
          _drawerTile(
            icon: Icons.pie_chart_rounded,
            text: 'Budgets',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BudgetPage()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _drawerTile(
      {required IconData icon,
        required String text,
        required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.green.shade600),
      title: Text(text, style: GoogleFonts.poppins(fontSize: 16)),
      onTap: onTap,
    );
  }

  Widget _buildFloatingActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Transactions button
        FloatingActionButton.extended(
          heroTag: "transactions_fab",
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TransactionsPage()),
          ),
          backgroundColor: Colors.white,
          icon: const Icon(Icons.swap_horiz_rounded, color: Colors.teal),
          label: Text("Transactions",
              style: GoogleFonts.poppins(
                  color: Colors.teal, fontWeight: FontWeight.w600)),
        ),
        const SizedBox(width: 12),
        // Add Transaction button
        FloatingActionButton.extended(
          heroTag: "add_fab",
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddEditTransactionPage()),
          ),
          backgroundColor: Colors.greenAccent.shade400,
          icon: const Icon(Icons.add_rounded, color: Colors.black),
          label: Text("Add",
              style: GoogleFonts.poppins(
                  color: Colors.black, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildBalanceCard(BuildContext context, FinanceProvider provider,
      NumberFormat formatter, Size size) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5))
        ],
      ),
      padding: EdgeInsets.all(size.width * 0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Wallet Balance',
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600, fontSize: size.width * 0.045)),
          const SizedBox(height: 8),
          Text(formatter.format(provider.balance),
              style: GoogleFonts.poppins(
                  fontSize: size.width * 0.085,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade700)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _miniStat('Income', provider.totalIncome, Colors.green, size),
              _miniStat('Expense', provider.totalExpense, Colors.red, size),
            ],
          )
        ],
      ),
    );
  }

  Widget _miniStat(
      String label, double value, Color color, Size size) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500, fontSize: size.width * 0.035)),
        Text(
          NumberFormat.currency(symbol: '₹').format(value),
          style: GoogleFonts.poppins(
              color: color,
              fontSize: size.width * 0.04,
              fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildBudgetOverview(
      FinanceProvider provider, NumberFormat formatter, Size size) {
    if (provider.budgets.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Budget Overview',
            style: GoogleFonts.poppins(
                fontSize: size.width * 0.045, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        ...provider.budgets.map((b) {
          final spent = provider.getTotalExpenseByCategory(b.category);
          final percent = spent / b.monthlyLimit;
          Color barColor;
          if (percent < 0.7) {
            barColor = Colors.greenAccent.shade400;
          } else if (percent < 1) {
            barColor = Colors.orangeAccent.shade200;
          } else {
            barColor = Colors.redAccent.shade200;
          }

          return Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 4))
              ],
            ),
            padding: EdgeInsets.all(size.width * 0.04),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(b.category,
                    style: GoogleFonts.poppins(
                        fontSize: size.width * 0.04,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: percent > 1 ? 1 : percent,
                    backgroundColor: Colors.grey.shade200,
                    color: barColor,
                    minHeight: 10,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Spent: ${formatter.format(spent)} / ${formatter.format(b.monthlyLimit)}',
                  style: GoogleFonts.poppins(color: barColor, fontSize: 13),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildRecentTransactions(FinanceProvider provider,
      NumberFormat formatter, BuildContext context, Size size) {
    final recent = provider.transactions.take(6).toList();

    if (recent.isEmpty) {
      return Text('No recent transactions yet.',
          style: GoogleFonts.poppins(fontSize: size.width * 0.035));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Recent Transactions',
            style: GoogleFonts.poppins(
                fontSize: size.width * 0.045, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        ...recent.map((t) {
          final amount = t.amount ?? 0.0;
          final isIncome = t.isIncome ?? false;
          final sign = isIncome ? '+' : '-';
          final amountText = formatter.format(amount);
          final title = t.title ?? '';
          final categoryLetter =
          (t.category?.isNotEmpty ?? false) ? t.category![0].toUpperCase() : '?';
          final dateText =
          t.date != null ? DateFormat.yMMMd().format(t.date!) : '';

          return Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 3))
              ],
            ),
            child: ListTile(
              leading: CircleAvatar(
                radius: size.width * 0.06,
                backgroundColor:
                isIncome ? Colors.greenAccent.shade400 : Colors.redAccent,
                child: Text(categoryLetter,
                    style: const TextStyle(color: Colors.white)),
              ),
              title: Text(title, style: GoogleFonts.poppins(fontSize: size.width * 0.04)),
              subtitle: Text(dateText, style: GoogleFonts.poppins(fontSize: size.width * 0.032)),
              trailing: Text(
                '$sign$amountText',
                style: GoogleFonts.poppins(
                    color: isIncome ? Colors.green : Colors.red,
                    fontWeight: FontWeight.w600,
                    fontSize: size.width * 0.038),
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

  Widget _buildPieChart(Map<String, double> data, Size size) {
    final filteredData = {...data}..removeWhere((key, value) => value == 0);
    if (filteredData.isEmpty) {
      return Text('No expense data available.',
          style: GoogleFonts.poppins(fontSize: size.width * 0.035));
    }

    final total = filteredData.values.fold<double>(0.0, (sum, value) => sum + value);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Expenses by Category',
            style: GoogleFonts.poppins(
                fontSize: size.width * 0.045, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        LayoutBuilder(
          builder: (context, constraints) {
            // Keep chart small and responsive
            final chartSize = constraints.maxWidth * 0.5; // 50% of available width
            final radius = chartSize * 0.4;
            final centerRadius = chartSize * 0.2;
            final fontSize = chartSize * 0.08;

            return SizedBox(
              height: chartSize,
              width: chartSize,
              child: PieChart(
                PieChartData(
                  sections: filteredData.entries.map((e) {
                    final percentage = (e.value / total) * 100;
                    final color = Colors.primaries[
                    filteredData.keys.toList().indexOf(e.key) %
                        Colors.primaries.length];
                    return PieChartSectionData(
                      color: color.shade400,
                      value: e.value,
                      title: '${e.key}\n${percentage.toStringAsFixed(1)}%',
                      radius: radius,
                      titleStyle: GoogleFonts.poppins(
                        fontSize: fontSize,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  }).toList(),
                  sectionsSpace: 2,
                  centerSpaceRadius: centerRadius,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
