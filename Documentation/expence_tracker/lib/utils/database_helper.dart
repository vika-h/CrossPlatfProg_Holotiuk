import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// Клас для роботи з базою даних
class DatabaseHelper {
  static Database? _database; // Екземпляр бази даних
  static final _dbName = 'expense_tracker.db'; // Назва бази даних
  static final _expenseTable = 'expenses'; // Назва таблиці витрат
  static final _incomeTable = 'incomes'; // Назва таблиці доходів
  late DateTime startDate; // Початкова дата
  late DateTime endDate; // Кінцева дата за замовчуванням

  /// Метод для отримання бази даних
  /// Повертає базу даних або створює нову, якщо вона ще не існує
  Future<Database> get database async {
    if (_database != null) return _database!;
    // Якщо база даних ще не ініціалізована, то ініціалізуємо її
    _database = await initDatabase();
    return _database!;
  }

  /// Метод для ініціалізації бази даних
  /// Ініціалізує базу даних та створює таблиці
  Future<Database> initDatabase() async {

    try {
      // Створюємо Шлях до бази даних
      final path = await getDatabasesPath();
      final databasePath = join(path, _dbName);
      // Створюємо базу даних
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
  ///
  /// Параметри:
  ///  - category: Категорія витрати
  ///  - amount: Сума витрати
  ///  - date: Дата витрати у форматі 'YYYY-MM-DD'
  ///  - description: Опис витрати
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
  ///
  /// Параметри:
  ///  - category: Категорія доходу
  ///  - amount: Сума доходу
  ///  - date: Дата доходу у форматі 'YYYY-MM-DD'
  ///  - description: Опис доходу
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
  ///
  /// Параметри:
  ///  - id: Ідентифікатор доходу
  ///  - amount: Нова сума доходу
  ///  - date: Нова дата доходу у форматі 'YYYY-MM-DD'
  ///  - description: Новий опис доходу
  ///  - category: Нова категорія доходу
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
  ///
  /// Параметри:
  ///  - id: Ідентифікатор витрати
  ///  - amount: Нова сума витрати
  ///  - date: Нова дата витрати у форматі 'YYYY-MM-DD'
  ///  - description: Новий опис витрати
  ///  - category: Нова категорія витрати
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
  ///
  /// Параметри:
  ///  - id: Ідентифікатор витрати, яку потрібно видалити
  Future<void> deleteExpense(int id) async {
    final db = await database;
    await db.rawQuery('DELETE FROM $_expenseTable WHERE id = $id');  
  }

  // Метод для видалення доходу
  ///
  /// Параметри:
  ///  - id: Ідентифікатор доходу, який потрібно видалити
  Future<void> deleteIncome(int id) async {
    final db = await database; 
    await db.rawQuery('''DELETE FROM $_incomeTable WHERE id = ?''',[ id ]);  
  }

  // Метод для закриття бази даних
  Future<void> closeDatabase() async {
    final db = await database;
    db.close();
  }

  /// Метод для отримання загальної суми всіх доходів.
  /// Повертає загальну суму всіх доходів, зчитаних з таблиці доходів у базі даних.
  /// Якщо немає записів про доходи, повертається 0.0.
  Future<double> getTotalIncome() async {
    final db = await database;
    final result = await db.rawQuery('SELECT SUM(amount) AS total FROM $_incomeTable');
    final totalIncome = result.first['total'] ?? 0.0;
    return totalIncome as double;
  }

  /// Метод для отримання загальної суми всіх витрат.
  /// Повертає загальну суму всіх витрат, зчитаних з таблиці витрат у базі даних.
  /// Якщо немає записів про витрати, повертається 0.0.
  Future<double> getTotalExpenses() async {
    final db = await database;
    final result = await db.rawQuery('SELECT SUM(amount) AS total FROM $_expenseTable');
    final totalExpenses = result.first['total'] ?? 0.0;
    return totalExpenses as double;
  }

  // Метод для обчислення поточного балансу
  /// Повертає різницю між загальним доходом та загальними витратами, щоб отримати поточний баланс.
  /// Використовує методи getTotalIncome() та getTotalExpenses() для отримання загального доходу та витрат відповідно.
  /// Після отримання обох значень обчислює різницю між ними та повертає це значення.
  Future<double> getCurrentBalance() async {
    final totalIncome = await getTotalIncome();
    final totalExpenses = await getTotalExpenses();
    final currentBalance = totalIncome - totalExpenses;

    return currentBalance;
  }

  /// Метод для отримання інформації про дохід з бази даних за його ID
  ///
  /// Параметри:
  ///  - id: Ідентифікатор доходу
  Future<Map<String, dynamic>?> getIncomeById(int id) async {
    final db = await database;
    final result = await db.query(_incomeTable, where: 'id = ?', whereArgs: [id]);
    return result.isNotEmpty ? result.first : null;
  }

  /// Метод для отримання інформації про витрату з бази даних за її ID
  ///
  /// Параметри:
  ///  - id: Ідентифікатор витрати
  Future<Map<String, dynamic>?> getExpenseById(int id) async {
    final db = await database;
    final result = await db.query(_expenseTable, where: 'id = ?', whereArgs: [id]);
    return result.isNotEmpty ? result.first : null;
  }

  /// Метод для отримання всіх доходів з бази даних.
  ///
  /// Повертається список мап з інформацією про кожен дохід.
  /// Кожен елемент списку містить дані про один дохід у вигляді мапи з наступними ключами:
  ///  - 'id': Ідентифікатор доходу.
  ///  - 'category': Категорія доходу.
  ///  - 'amount': Сума доходу.
  ///  - 'date': Дата доходу у форматі 'YYYY-MM-DD'.
  ///  - 'description': Опис доходу.
  ///  - 'isIncome': Прапорець, що позначає, що запис є доходом (значення 'true').
  Future<List<Map<String, dynamic>>> getIncomes() async {
    final db = await database;
    return await db.rawQuery('''
      SELECT *, 'true' as isIncome
      FROM $_incomeTable
    ''');
  }

  /// Метод для отримання всіх витрат з бази даних.
  ///
  /// Повертається список мап з інформацією про кожну витрату.
  /// Кожен елемент списку містить дані про одну витрату у вигляді мапи з наступними ключами:
  ///  - 'id': Ідентифікатор витрати.
  ///  - 'category': Категорія витрати.
  ///  - 'amount': Сума витрати.
  ///  - 'date': Дата витрати у форматі 'YYYY-MM-DD'.
  ///  - 'description': Опис витрати.
  ///  - 'isIncome': Прапорець, що позначає, що запис є витратою (значення 'false').
  Future<List<Map<String, dynamic>>> getExpences() async {
    final db = await database;
    return await db.rawQuery('''
      SELECT *, 'false' as isIncome
      FROM $_expenseTable
    ''');
  }

  /// Метод для отримання всіх транзакцій з бази даних, відсортованих за датою.
  ///
  /// Повертається список мап з інформацією про кожну транзакцію.
  /// Кожен елемент списку містить дані про одну транзакцію у вигляді мапи з наступними ключами:
  ///  - 'id': Ідентифікатор транзакції.
  ///  - 'category': Категорія транзакції.
  ///  - 'amount': Сума транзакції.
  ///  - 'date': Дата транзакції у форматі 'YYYY-MM-DD'.
  ///  - 'description': Опис транзакції.
  ///  - 'isIncome': Прапорець, що позначає, що запис є доходом (значення 'true') або витратою (значення 'false').
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

  /// Метод для отримання статистики витрат за певний період.
  ///
  /// Параметри:
  ///  - startDate: Початкова дата періоду.
  ///  - endDate: Кінцева дата періоду.
  ///
  /// Повертає список мап, де кожен елемент містить інформацію про категорію витрат та їх суму за вказаний період.
  /// Кожен елемент містить наступні ключі:
  ///  - 'category': Категорія витрат.
  ///  - 'total': Загальна сума витрат у цій категорії за період.
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

  /// Метод для отримання статистики доходів за певний період.
  ///
  /// Параметри:
  ///  - startDate: Початкова дата періоду.
  ///  - endDate: Кінцева дата періоду.
  ///
  /// Повертає список мап, де кожен елемент містить інформацію про категорію доходів та їх суму за вказаний період.
  /// Кожен елемент містить наступні ключі:
  ///  - 'category': Категорія доходів.
  ///  - 'total': Загальна сума доходів у цій категорії за період.
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

  /// Метод для отримання комбінованої статистики доходів та витрат за певний період.
  ///
  /// Параметри:
  ///  - startDate: Початкова дата періоду.
  ///  - endDate: Кінцева дата періоду.
  ///
  /// Повертає список мап, що містить загальну суму доходів та витрат за вказаний період.
  /// Кожен елемент мапи містить наступні ключі:
  ///  - 'totalExpenses': Загальна сума витрат за період.
  ///  - 'totalIncomes': Загальна сума доходів за період.
  Future<List<Map<String, dynamic>>> getCombinedStatistics(DateTime startDate, DateTime endDate) async {
    final db = await database;
    
    // Отримання суми витрат за заданий період
    final expensesResult = await db.rawQuery('''
      SELECT SUM(amount) AS total
      FROM $_expenseTable
      WHERE date BETWEEN ? AND ?
    ''', [startDate.toIso8601String(), endDate.toIso8601String()]);
    
    print('Expenses result: $expensesResult');

    // Отримання суми доходів за заданий період
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

  /// Метод для отримання дати першої транзакції в базі даних.
  ///
  /// Повертає дату першої транзакції в базі даних.
  /// Якщо транзакції відсутні, повертається дата за замовчуванням - поточна дата мінус 365 днів.
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
