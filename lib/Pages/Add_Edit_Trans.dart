import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../src/Providers/finance_provider.dart';
import '../src/models/transactions.dart';
import 'package:intl/intl.dart';

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
        text: widget.editTransaction?.amount.toString() ?? '');
    _categoryController =
        TextEditingController(text: widget.editTransaction?.category ?? '');
    _selectedDate = widget.editTransaction?.date ?? DateTime.now();
    _isIncome = widget.editTransaction?.isIncome ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FinanceProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
          title: Text(widget.editTransaction == null
              ? 'Add Transaction'
              : 'Edit Transaction')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (v) => v!.isEmpty ? 'Enter title' : null,
              ),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Amount'),
                validator: (v) => v!.isEmpty ? 'Enter amount' : null,
              ),
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(labelText: 'Category'),
                validator: (v) => v!.isEmpty ? 'Enter category' : null,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(DateFormat.yMMMd().format(_selectedDate)),
                  TextButton(
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );
                      if (date != null) setState(() => _selectedDate = date);
                    },
                    child: const Text('Pick Date'),
                  )
                ],
              ),
              SwitchListTile(
                title: const Text('Is Income?'),
                value: _isIncome,
                onChanged: (v) => setState(() => _isIncome = v),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final tx = MoneyTransaction(
                      id: widget.editTransaction?.id,
                      title: _titleController.text,
                      category: _categoryController.text,
                      amount: double.tryParse(_amountController.text) ?? 0.0,
                      date: _selectedDate,
                      isIncome: _isIncome,
                    );

                    if (widget.editTransaction == null) {
                      await provider.addTransaction(tx);
                    } else {
                      await provider.updateTransaction(tx);
                    }

                    Navigator.pop(context);
                  }
                },
                child: Text(widget.editTransaction == null ? 'Add' : 'Update'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
