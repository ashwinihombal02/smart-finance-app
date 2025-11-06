import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '/src/models/transactions.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '/src/models/budget_models.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('finance.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final Directory dir = await getApplicationDocumentsDirectory();
    final dbPath = join(dir.path, fileName);
    return await openDatabase(
      dbPath,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE transactions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        amount REAL NOT NULL,
        category TEXT NOT NULL,
        date TEXT NOT NULL,
        isIncome INTEGER NOT NULL
      );
    ''');
    await db.execute('''
      CREATE TABLE budgets(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category TEXT NOT NULL UNIQUE,
        monthlyLimit REAL NOT NULL
      );
    ''');
  }


  Future<Budget> createBudget(Budget budget) async {
    final db = await instance.database;
    final id = await db.insert(
      'budgets',
      budget.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return budget.copyWith(id: id);
  }

  Future<List<Budget>> readAllBudgets() async {
    final db = await instance.database;
    final result = await db.query('budgets', orderBy: 'category ASC');
    return result.map((m) => Budget.fromMap(m)).toList();
  }

  Future<Budget?> readBudgetByCategory(String category) async {
    final db = await instance.database;
    final maps = await db.query(
      'budgets',
      where: 'category = ?',
      whereArgs: [category],
    );
    if (maps.isNotEmpty) {
      return Budget.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateBudget(Budget budget) async {
    final db = await instance.database;
    return db.update(
      'budgets',
      budget.toMap(),
      where: 'id = ?',
      whereArgs: [budget.id],
    );
  }

  Future<int> deleteBudget(int id) async {
    final db = await instance.database;
    return db.delete('budgets', where: 'id = ?', whereArgs: [id]);
  }

  Future<MoneyTransaction> createTransaction(MoneyTransaction tx) async {
    final db = await instance.database;
    final id = await db.insert('transactions', tx.toMap());
    return tx.copyWith(id: id);
  }

  Future<MoneyTransaction?> readTransaction(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return MoneyTransaction.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<List<MoneyTransaction>> readAllTransactions() async {
    final db = await instance.database;
    final orderBy = 'date DESC';
    final result = await db.query('transactions', orderBy: orderBy);
    return result.map((m) => MoneyTransaction.fromMap(m)).toList();
  }

  Future<int> updateTransaction(MoneyTransaction tx) async {
    final db = await instance.database;
    return db.update(
      'transactions',
      tx.toMap(),
      where: 'id = ?',
      whereArgs: [tx.id],
    );
  }

  Future<int> deleteTransaction(int id) async {
    final db = await instance.database;
    return await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
