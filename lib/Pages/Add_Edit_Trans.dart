import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../src/Providers/finance_provider.dart';
import '../src/models/transactions.dart';

class AddEditTransactionPage extends StatefulWidget {
  final MoneyTransaction? editTransaction;
  const AddEditTransactionPage({super.key, this.editTransaction});

  @override
  State<AddEditTransactionPage> createState() => _AddEditTransactionPageState();
}

class _AddEditTransactionPageState extends State<AddEditTransactionPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _amountController;
  late TextEditingController _categoryController;
  DateTime _selectedDate = DateTime.now();
  bool _isIncome = false;

  @override
  void initState() {
    super.initState();
    _titleController =
        TextEditingController(text: widget.editTransaction?.title ?? '');
    _amountController = TextEditingController(
        text: widget.editTransaction?.amount?.toString() ?? '');
    _categoryController =
        TextEditingController(text: widget.editTransaction?.category ?? '');
    _selectedDate = widget.editTransaction?.date ?? DateTime.now();
    _isIncome = widget.editTransaction?.isIncome ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FinanceProvider>(context, listen: false);
    final isEditing = widget.editTransaction != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),

      // ======= APPBAR WITH BACK ARROW =======
      appBar: AppBar(
        automaticallyImplyLeading: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: 22),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isEditing ? 'Edit Transaction' : 'Add Transaction',
          style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600, color: Colors.white),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _isIncome
                  ? [Colors.greenAccent.shade400, Colors.teal]
                  : [Colors.redAccent.shade400, Colors.orangeAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 4,
      ),

      // ======= BODY =======
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          children: [
            // TYPE SELECTION BUTTONS
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _typeButton('Income', true, Icons.arrow_downward_rounded),
                const SizedBox(width: 16),
                _typeButton('Expense', false, Icons.arrow_upward_rounded),
              ],
            ),
            const SizedBox(height: 24),

            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12.withOpacity(0.05),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                padding:
                const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      _buildTextField(
                          _titleController, 'Title', Icons.title_rounded),
                      const SizedBox(height: 16),
                      _buildTextField(_amountController, 'Amount',
                          Icons.currency_rupee_rounded,
                          keyboardType: TextInputType.number),
                      const SizedBox(height: 16),
                      _buildTextField(
                          _categoryController, 'Category', Icons.category_rounded),
                      const SizedBox(height: 20),
                      _buildDatePicker(context),
                      const SizedBox(height: 24),
                      _buildSubmitButton(provider, isEditing),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Custom Widgets ---

  Widget _typeButton(String label, bool income, IconData icon) {
    final isSelected = _isIncome == income;
    return ElevatedButton.icon(
      onPressed: () => setState(() => _isIncome = income),
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected
            ? (income ? Colors.greenAccent.shade400 : Colors.redAccent.shade400)
            : Colors.grey.shade200,
        foregroundColor: isSelected ? Colors.white : Colors.black87,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
        elevation: isSelected ? 4 : 0,
      ),
      icon: Icon(icon, size: 18),
      label: Text(
        label,
        style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, IconData icon,
      {TextInputType? keyboardType}) {
    return TextFormField(
      controller: controller,
      validator: (v) => v!.isEmpty ? 'Enter $label' : null,
      keyboardType: keyboardType,
      style: GoogleFonts.poppins(fontSize: 15),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.grey.shade600),
        labelText: label,
        labelStyle:
        GoogleFonts.poppins(fontSize: 14, color: Colors.grey.shade700),
        filled: true,
        fillColor: Colors.grey.shade100,
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime(2020),
          lastDate: DateTime(2100),
        );
        if (date != null) setState(() => _selectedDate = date);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              DateFormat.yMMMd().format(_selectedDate),
              style: GoogleFonts.poppins(fontSize: 15, color: Colors.black87),
            ),
            const Icon(Icons.calendar_today_rounded, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton(FinanceProvider provider, bool isEditing) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor:
          _isIncome ? Colors.greenAccent.shade400 : Colors.redAccent.shade400,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
        ),
        onPressed: () async {
          if (_formKey.currentState!.validate()) {
            final tx = MoneyTransaction(
              id: widget.editTransaction?.id,
              title: _titleController.text.trim(),
              category: _categoryController.text.trim(),
              amount: double.tryParse(_amountController.text) ?? 0.0,
              date: _selectedDate,
              isIncome: _isIncome,
            );

            if (isEditing) {
              await provider.updateTransaction(tx);
            } else {
              await provider.addTransaction(tx);
            }

            if (mounted) Navigator.pop(context);
          }
        },
        child: Text(
          isEditing ? 'Update Transaction' : 'Add Transaction',
          style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600, fontSize: 16, color: Colors.white),
        ),
      ),
    );
  }
}
