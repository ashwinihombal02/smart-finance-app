import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io';
import '/src/Providers/finance_provider.dart';
import 'Pages/Dashboard.dart';
import 'Pages/Transaction_Page.dart';
import 'Pages/Add_Edit_Trans.dart';

void main() {
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  runApp(const SmartFinanceApp());
}

class SmartFinanceApp extends StatelessWidget {
  const SmartFinanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FinanceProvider()..loadTransactions(),
      child: MaterialApp(
        title: 'Smart Finance',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(primarySwatch: Colors.teal),
        initialRoute: '/',
        routes: {
          '/': (_) => DashboardPage(),
          '/transactions': (_) => const TransactionsPage(),
          '/add': (_) => const AddEditTransactionPage(),
        },
      ),
    );
  }
}
