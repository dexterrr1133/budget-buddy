import 'dart:async';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../models/transaction.dart';

class DatabaseHelper {
  DatabaseHelper._();

  static const _dbName = 'budget_buddy.db';
  static const _dbVersion = 1;
  static const transactionsTable = 'transactions';
  static const budgetsTable = 'budgets';

  static const _transactionTypeIncome = 'income';
  static const _transactionTypeExpense = 'expense';

  static final DatabaseHelper instance = DatabaseHelper._();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = join(directory.path, _dbName);
    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onConfigure: _onConfigure,
    );
  }

  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $transactionsTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        amount REAL NOT NULL CHECK(amount >= 0),
        category TEXT NOT NULL,
        date TEXT NOT NULL,
        type TEXT NOT NULL CHECK(type IN ('$_transactionTypeIncome','$_transactionTypeExpense')),
        note TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE $budgetsTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category TEXT NOT NULL,
        limit_amount REAL NOT NULL CHECK(limit_amount >= 0),
        period_start TEXT,
        period_end TEXT
      )
    ''');
  }

  Future<int> insertTransaction(TransactionModel transaction) async {
    _validateTransaction(transaction);
    final db = await database;
    return db.insert(
      transactionsTable,
      transaction.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<TransactionModel>> fetchTransactions() async {
    final db = await database;
    final result = await db.query(
      transactionsTable,
      orderBy: 'date DESC',
    );
    return result.map(TransactionModel.fromMap).toList();
  }

  Future<int> updateTransaction(TransactionModel transaction) async {
    if (transaction.id == null) {
      throw ArgumentError('Cannot update transaction without an id');
    }
    _validateTransaction(transaction);
    final db = await database;
    return db.update(
      transactionsTable,
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  Future<int> deleteTransaction(int id) async {
    final db = await database;
    return db.delete(
      transactionsTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> close() async {
    final db = _database;
    if (db != null && db.isOpen) {
      await db.close();
    }
    _database = null;
  }

  void _validateTransaction(TransactionModel transaction) {
    if (!transaction.amount.isFinite || transaction.amount < 0) {
      throw ArgumentError('Amount must be a non-negative number');
    }
    if (transaction.category.trim().isEmpty) {
      throw ArgumentError('Category is required');
    }
    if (transaction.type != _transactionTypeIncome &&
        transaction.type != _transactionTypeExpense) {
      throw ArgumentError('Type must be income or expense');
    }
  }
}
