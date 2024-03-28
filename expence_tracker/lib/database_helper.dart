import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class DatabaseHelper {
  static Database? _database;
  static final _dbName = 'expense_tracker.db';
  static final _expenseTable = 'expenses';
  static final _incomeTable = 'incomes';
  final storage = FlutterSecureStorage();
  late DateTime startDate; // Початкова дата
  late DateTime endDate; // Кінцева дата за замовчуванням

  // Метод для отримання бази даних
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDatabase();
    return _database!;
  }

  // Метод для ініціалізації бази даних
  Future<Database> initDatabase() async {

    try {
      final path = await getDatabasesPath();
      final databasePath = join(path, _dbName);
      return await openDatabase(databasePath, version: 1, onCreate: (db, version) async {
        // Створення таблиці витрат
        await db.execute('''
          CREATE TABLE $_expenseTable (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            category TEXT,
            amount REAL,
            date TEXT,
            description TEXT
          )
        ''');
        // Створення таблиці доходів
        await db.execute('''
          CREATE TABLE $_incomeTable (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            category TEXT,
            amount REAL,
            date TEXT,
            description TEXT
          )
        ''');
      });
    } catch (e) {
      print('Error initializing database: $e');
      rethrow; // Передача винятку для подальшого вивчення
    }
  }

  // Метод для створення нової витрати
  Future<int> createExpense(String category, double amount, String date, String description) async {
    final db = await database;
    int result = await db.insert(_expenseTable, {
      'category': category,
      'amount': amount,
      'date': date,
      'description': description
    });
    return result; // Повертаємо результат вставки
  }

  // Метод для створення нового доходу
  Future<int> createIncome(String category, double amount, String date, String description) async {
    final db = await database;
    return await db.insert(_incomeTable, {
      'category': category,
      'amount': amount,
      'date': date,
      'description': description
    });
  }

  // Метод для оновлення доходу за його ID
  Future<void> updateIncome(int id, double amount, String date, String description, String category) async {
    print(id);
    print(amount);
    print(date);
    await _database?.update(
      _incomeTable,
      {
        'amount': amount,
        'date': date,
        'description': description,
        'category': category,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Метод для оновлення витрати за її ID
  Future<void> updateExpense(int id, double amount, String date, String description, String category) async {
    await _database?.update(
      _expenseTable,
      {
        'amount': amount,
        'date': date,
        'description': description,
        'category': category,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Метод для видалення витрати
  Future<void> deleteExpense(int id) async {
    final db = await database;
    await db.rawQuery('DELETE FROM $_expenseTable WHERE id = $id');  
  }

  // Метод для видалення доходу
  Future<void> deleteIncome(int id) async {
    final db = await database; 
    await db.rawQuery('''DELETE FROM $_incomeTable WHERE id = ?''',[ id ]);  
  }

  // Метод для закриття бази даних
  Future<void> closeDatabase() async {
    final db = await database;
    db.close();
  }

  // Метод для отримання загальної суми всіх доходів
  Future<double> getTotalIncome() async {
    final db = await database;
    final result = await db.rawQuery('SELECT SUM(amount) AS total FROM $_incomeTable');
    final totalIncome = result.first['total'] ?? 0.0;
    return totalIncome as double;
  }

  // Метод для отримання загальної суми всіх витрат
  Future<double> getTotalExpenses() async {
    final db = await database;
    final result = await db.rawQuery('SELECT SUM(amount) AS total FROM $_expenseTable');
    final totalExpenses = result.first['total'] ?? 0.0;
    return totalExpenses as double;
  }

  // Метод для обчислення поточного балансу
  Future<double> getCurrentBalance() async {
    final totalIncome = await getTotalIncome();
    final totalExpenses = await getTotalExpenses();
    final currentBalance = totalIncome - totalExpenses;

    return currentBalance;
  }

  Future<Map<String, dynamic>?> getIncomeById(int id) async {
    final db = await database;
    final result = await db.query(_incomeTable, where: 'id = ?', whereArgs: [id]);
    return result.isNotEmpty ? result.first : null;
  }

  Future<Map<String, dynamic>?> getExpenseById(int id) async {
    final db = await database;
    final result = await db.query(_expenseTable, where: 'id = ?', whereArgs: [id]);
    return result.isNotEmpty ? result.first : null;
  }

  Future<List<Map<String, dynamic>>> getIncomes() async {
    final db = await database;
    return await db.rawQuery('''
      SELECT *, 'true' as isIncome
      FROM $_incomeTable
    ''');
  }

  Future<List<Map<String, dynamic>>> getExpences() async {
    final db = await database;
    return await db.rawQuery('''
      SELECT *, 'false' as isIncome
      FROM $_expenseTable
    ''');
  }

  Future<List<Map<String, dynamic>>> getAllTransactionsSortedByDate() async {
    final db = await database;
    final expenses = await getExpences();
    final incomes = await getIncomes();
    
    // З'єднання списків транзакцій і сортування їх за датою
    List<Map<String, dynamic>> transactions = [...expenses, ...incomes];
    transactions.sort((a, b) => b['date'].compareTo(a['date']));
    print(transactions);
    return transactions;
  }

  Future<List<Map<String, dynamic>>> getExpenseStatistics(DateTime startDate, DateTime endDate) async {
    final db = await database;
    print(startDate.toIso8601String());
    return await db.rawQuery('''
      SELECT category, SUM(amount) AS total 
      FROM $_expenseTable 
      WHERE date BETWEEN ? AND ?
      GROUP BY category
    ''', [startDate.toIso8601String(), endDate.toIso8601String()]);
  }

  Future<List<Map<String, dynamic>>> getIncomeStatistics(DateTime startDate, DateTime endDate) async {
    final db = await database;
    print(startDate.toIso8601String());
    return await db.rawQuery('''
      SELECT category, SUM(amount) as total
      FROM $_incomeTable
      WHERE date BETWEEN ? AND ?
      GROUP BY category
    ''', [startDate.toIso8601String(), endDate.toIso8601String()]);
  }

  Future<List<Map<String, dynamic>>> getCombinedStatistics(DateTime startDate, DateTime endDate) async {
    final db = await database;
    final expensesResult = await db.rawQuery('''
      SELECT SUM(amount) AS total
      FROM $_expenseTable
      WHERE date BETWEEN ? AND ?
    ''', [startDate.toIso8601String(), endDate.toIso8601String()]);
    
    print('Expenses result: $expensesResult');

    final incomesResult = await db.rawQuery('''
      SELECT SUM(amount) AS total
      FROM $_incomeTable
      WHERE date BETWEEN ? AND ?
    ''', [startDate.toIso8601String(), endDate.toIso8601String()]);

    print('Incomes result: $incomesResult');

    final totalExpenses = expensesResult;
    final totalIncomes = incomesResult;

    return [{'totalExpenses': totalExpenses, 'totalIncomes': totalIncomes}];
  }

  Future<DateTime> getDatabaseDates() async {
    final db = await database;
    List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT MIN(date) AS firstDate FROM (
        SELECT MIN(date) AS date FROM incomes
        UNION
        SELECT MIN(date) AS date FROM expenses
      )
    ''');
    String? dateString = result.first['firstDate'];
    print(dateString);
    if (dateString != null) {
      List<String> dateParts = dateString.split('-');
      int year = int.parse(dateParts[0]);
      int month = int.parse(dateParts[1]);
      int day = int.parse(dateParts[2]);
      DateTime firstDate = DateTime(year, month, day);
      return firstDate;
    } else {
      // Повертає дату за замовчуванням, якщо транзакцій не знайдено
      return DateTime.now().subtract(Duration(days: 365));
    }
  }
}
