import 'package:flutter_test/flutter_test.dart';
import '../lib/utils/database_helper.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart';

Future main() async {
  DatabaseHelper databaseHelper = DatabaseHelper();
  
  // Налаштування sqflite_common_ffi для тестування
  setUpAll(() {
    // Ініціалізація FFI
    sqfliteFfiInit();
    // Зміна factory за замовчуванням для викликів модульного тестування для SQFlite
    databaseFactory = databaseFactoryFfi;
  });

  // Тест ініціалізації бази даних
  test('Test database initialization', () async {
    final db = await databaseHelper.initDatabase();
    expect(db.isOpen, isTrue);
  });

  // Тест створення витрати
  test('Test creating expense', () async {
    final result = await databaseHelper.createExpense('Food', 50.0, '2024-03-28', 'Groceries');
    expect(result, isNotNull);
  });

  // Тест створення надходження
  test('Test creating income', () async {
    final result = await databaseHelper.createIncome('Salary', 200.0, '2024-03-28', 'Monthly Salary');
    expect(result, isNotNull);
  });

  // Тест отримання загальної суми витрат
  test('Test getting total expenses', () async {
    final totalExpenses = await databaseHelper.getTotalExpenses();
    expect(totalExpenses, greaterThanOrEqualTo(0));
  });

  // Тест отримання загальної суми надходжень
  test('Test getting total income', () async {
    final totalIncome = await databaseHelper.getTotalIncome();
    expect(totalIncome, greaterThanOrEqualTo(0));
  });

  // Тест отримання поточного балансу
  test('Test getting current balance', () async {
    final currentBalance = await databaseHelper.getCurrentBalance();
    expect(currentBalance, isNotNull);
  });

  // Тест оновлення надходження
  test('Test updating income', () async {
    final updatedAmount = 100.0;
    final updatedDate = '2024-03-28';
    final updatedDescription = 'Updated description';
    final updatedCategory = 'Salary';

    // Створення надходження для оновлення
    final incomeId = await databaseHelper.createIncome('Salary', 200.0, '2024-03-28', 'Monthly Salary');

    // Оновлення надходження
    await databaseHelper.updateIncome(incomeId, updatedAmount, updatedDate, updatedDescription, updatedCategory);

    // Після оновлення надходження
    final updatedIncome = await databaseHelper.getIncomeById(incomeId);
    expect(updatedIncome, isNotNull);
    // Перевірка, чи надходження успішно оновлено
    if (updatedIncome != null) {

    expect(updatedIncome['amount'], equals(updatedAmount));
    expect(updatedIncome['date'], equals(updatedDate));
    expect(updatedIncome['description'], equals(updatedDescription));
    expect(updatedIncome['category'], equals(updatedCategory));
    }
  });

  test('Test updating expense', () async {
    final updatedAmount = 100.0;
    final updatedDate = '2024-03-28';
    final updatedDescription = 'Updated description';
    final updatedCategory = 'Groceries';
    
    // Створення витрати для оновлення
    final expenceId = await databaseHelper.createExpense('Groceries', 200.0, '2024-03-28', 'Groceri');

    // Оновлення витрати
    await databaseHelper.updateExpense(expenceId, updatedAmount, updatedDate, updatedDescription, updatedCategory);
    
    // Після оновлення витрати
    final updatedExpense = await databaseHelper.getExpenseById(expenceId);
    expect(updatedExpense, isNotNull);
    // Перевірка, чи витрата оновлена успішно
    if (updatedExpense != null) {
      expect(updatedExpense['amount'], equals(updatedAmount));
      expect(updatedExpense['date'], equals(updatedDate));
      expect(updatedExpense['description'], equals(updatedDescription));
      expect(updatedExpense['category'], equals(updatedCategory));
    }
  });

  // Тест видалення надходження
  test('Test deleting income', () async {
    final id = 1; // Припускаючи, що існує надходження з цим ID
    await databaseHelper.deleteExpense(id);
    final deletedExpense = await databaseHelper.getExpenseById(id);
    expect(deletedExpense, isNull);
  });

  // Тест видалення витрати
  test('Test deleting expense', () async {
    final id = 1; /// Припускаючи, що існує витрата з цим ID
    await databaseHelper.deleteIncome(id);
    final deletedIncome = await databaseHelper.getIncomeById(id);
    expect(deletedIncome, isNull);
  });

  // Тест отримання всіх транзакцій впорядкованих за датою
  test('Test getting all transactions sorted by date', () async {
    await databaseHelper.createIncome('Salary', 200.0, '2024-03-28', 'Monthly Salary');
    await databaseHelper.createExpense('Groceries', 150.0, '2024-03-28', 'Grocery shopping');
    final transactions = await databaseHelper.getAllTransactionsSortedByDate();
    expect(transactions, isNotNull);
  });

  // Тест отримання статистики витрат
  test('Test getting expense statistics', () async {
    final startDate = DateTime.now().subtract(Duration(days: 30));
    final endDate = DateTime.now();
    await databaseHelper.createExpense('Groceries', 150.0, '2024-03-28', 'Grocery shopping');
    final expenseStatistics = await databaseHelper.getExpenseStatistics(startDate, endDate);
    expect(expenseStatistics, isNotNull);
  });

  // Тест отримання статистики надходжень
  test('Test getting income statistics', () async {
    final startDate = DateTime.now().subtract(Duration(days: 30));
    final endDate = DateTime.now();
    await databaseHelper.createIncome('Salary', 200.0, '2024-03-28', 'Monthly Salary');
    final incomeStatistics = await databaseHelper.getIncomeStatistics(startDate, endDate);
    expect(incomeStatistics, isNotNull);
  });

  // Тест отримання комбінованої статистики
  test('Test getting combined statistics', () async {
    final startDate = DateTime.now().subtract(Duration(days: 30));
    final endDate = DateTime.now();
    await databaseHelper.createIncome('Salary', 200.0, '2024-03-28', 'Monthly Salary');
    await databaseHelper.createExpense('Groceries', 150.0, '2024-03-28', 'Grocery shopping');
    final combinedStatistics = await databaseHelper.getCombinedStatistics(startDate, endDate);
    expect(combinedStatistics, isNotNull);
  });

  // Тест отримання дат бази даних
  test('Test getting database dates', () async {
    final databaseDates = await databaseHelper.getDatabaseDates();
    expect(databaseDates, isNotNull);
  });
}
