import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../src/Providers/finance_provider.dart';
import 'Add_Edit_Trans.dart';

class TransactionsPage extends StatelessWidget {
  const TransactionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FinanceProvider>(context);
    final transactions = provider.transactions;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),
      appBar: AppBar(
        automaticallyImplyLeading: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: 22),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'All Transactions',
          style: GoogleFonts.poppins(
              color: Colors.white, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF43CEA2), Color(0xFF185A9D)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 4,
      ),

      // Replace the body with this version:
      body: transactions.isEmpty
          ? Column(
        children: [
          Expanded(child: _buildEmptyState()),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Tip: Swipe a transaction left or right to delete it.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      )
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final t = transactions[index];
                return Dismissible(
                  key: ValueKey(t.id),
                  direction: DismissDirection.horizontal,
                  background: Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.shade400,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(left: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  secondaryBackground: Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.shade400,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (_) async {
                    final removed = t;
                    await provider.deleteTransaction(t.id!);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: Colors.grey.shade800,
                        content: Text(
                          'Transaction deleted',
                          style: GoogleFonts.poppins(color: Colors.white),
                        ),
                        action: SnackBarAction(
                          label: 'UNDO',
                          textColor: Colors.tealAccent,
                          onPressed: () async {
                            await provider.addTransaction(
                              removed.copyWith(id: null),
                            );
                          },
                        ),
                      ),
                    );
                  },
                  child: _buildTransactionTile(context, t),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Tip: Swipe a transaction left or right to delete it.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),

      // ===== FLOATING BUTTON =====
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const AddEditTransactionPage()));
        },
        backgroundColor: const Color(0xFF43CEA2),
        child: const Icon(Icons.add_rounded, size: 32),
      ),
    );
  }

  // --- Transaction List Tile ---
  Widget _buildTransactionTile(BuildContext context, dynamic t) {
    final isIncome = t.isIncome;
    final color = isIncome ? Colors.greenAccent.shade700 : Colors.redAccent;
    final amountSign = isIncome ? '+' : '-';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: ListTile(
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: isIncome
              ? Colors.greenAccent.shade100
              : Colors.redAccent.shade100,
          child: Icon(
            isIncome ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
            color: color,
            size: 22,
          ),
        ),
        title: Text(
          t.title,
          style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600, fontSize: 16, color: Colors.black87),
        ),
        subtitle: Text(
          '${t.category} • ${DateFormat.yMMMd().format(t.date)}',
          style: GoogleFonts.poppins(
              fontSize: 13, color: Colors.grey.shade600, height: 1.3),
        ),
        trailing: Text(
          '$amountSign ₹${t.amount.toStringAsFixed(2)}',
          style: GoogleFonts.poppins(
              fontWeight: FontWeight.w700, fontSize: 16, color: color),
        ),
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => AddEditTransactionPage(editTransaction: t)));
        },
      ),
    );
  }

  // --- Empty State ---
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.receipt_long_rounded,
              size: 80, color: Colors.grey),
          const SizedBox(height: 20),
          Text(
            'No Transactions Yet',
            style: GoogleFonts.poppins(
                fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black54),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap + to add your first transaction',
            style: GoogleFonts.poppins(
                fontSize: 14, color: Colors.grey.shade600, height: 1.5),
          ),
        ],
      ),
    );
  }
}
