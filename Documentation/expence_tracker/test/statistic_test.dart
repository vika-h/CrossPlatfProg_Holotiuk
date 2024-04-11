import 'package:flutter_test/flutter_test.dart';
import '../lib/utils/database_helper.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart';

void main() {

  // Налаштування тестового середовища перед усіма тестами
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  // Тест обчислення статистики витрат
  test('Test expense statistics calculation', () async {
    final dbHelper = DatabaseHelper();
    final startDate = DateTime(2024, 1, 1);
    final endDate = DateTime(2024, 12, 31);

    final expenseStatistics = await dbHelper.getExpenseStatistics(startDate, endDate);
    
    // Перевірка результатів
    expect(expenseStatistics, isNotNull);
    expect(expenseStatistics.isNotEmpty, isTrue);

  });

  // Тест обчислення статистики доходів
  test('Test income statistics calculation', () async {
    final dbHelper = DatabaseHelper();
    final startDate = DateTime(2024, 1, 1);
    final endDate = DateTime(2024, 12, 31);

    final incomeStatistics = await dbHelper.getIncomeStatistics(startDate, endDate);
    
    // Перевірка результатів
    expect(incomeStatistics, isNotNull);
    expect(incomeStatistics.isNotEmpty, isTrue);
  });

  // Тест обчислення комбінованої статистики
  test('Test combined statistics calculation', () async {
    final dbHelper = DatabaseHelper();
    final startDate = DateTime(2024, 1, 1);
    final endDate = DateTime(2024, 12, 31);

    final combinedStatistics = await dbHelper.getCombinedStatistics(startDate, endDate);
    
    // Перевірка результатів
    expect(combinedStatistics, isNotNull);
    expect(combinedStatistics.isNotEmpty, isTrue);
  });
}
