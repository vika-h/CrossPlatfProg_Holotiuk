import '../lib/screens/main_screen.dart';
import '../lib/screens/statistics_screen.dart';
import '../lib/screens/add_expense_screen.dart';
import '../lib/screens/add_income_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expence_tracker/main.dart'; 
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart';

void main() {
  // Налаштування sqflite_common_ffi для тестування
  setUpAll(() {
    // Ініціалізація FFI
    sqfliteFfiInit();
    // Зміна factory за замовчуванням для викликів модульного тестування для SQFlite
    databaseFactory = databaseFactoryFfi;
  });

  testWidgets('MyApp UI Test', (WidgetTester tester) async {
    // Створення додатку і запуск 
    await tester.pumpWidget(MyApp());

    // Перевірка чи присутня кнопка
    var fab = find.byType(AspectRatio);

    expect(fab, findsOneWidget);
  });

  testWidgets('MainScreen UI Test', (WidgetTester tester) async {
    // Створення додатку і запуск MainScreen
    await tester.pumpWidget(MaterialApp(home: MainScreen()));

    // Перевірка чи відображається текст «Баланс»
    var balanceText = find.text('Баланс');
    var incomes = find.text('Доходи');

    expect(balanceText, findsOneWidget);
    expect(incomes, findsOneWidget);
  });

  testWidgets('StatisticsScreen UI Test', (WidgetTester tester) async {
    // Створення додатку і запуск StatisticsScreen
    await tester.pumpWidget(MaterialApp(home: StatisticsScreen()));
    
    // Перевірка чи відображається текст Статистика
    var statisticsText = find.text('Статистика');
    var fab = find.byIcon(Icons.calendar_today);

    expect(statisticsText, findsOneWidget);
    expect(fab, findsOneWidget);
  });

  testWidgets('AddExpense UI Test', (WidgetTester tester) async {
    // Створення додатку і запуск AddExpenseScreen
    await tester.pumpWidget(MaterialApp(home: AddExpenseScreen()));

    // Перевірка чи присутня кнопка
    var fab = find.byType(ElevatedButton);

    expect(fab, findsOneWidget);
  });

  testWidgets('AddIncome UI Test', (WidgetTester tester) async {
    // Створення додатку і запуск AddIncomeScreen
    await tester.pumpWidget(MaterialApp(home: AddIncomeScreen()));

    // Перевірка чи присутня кнопка
    var fab = find.byType(ElevatedButton);

    expect(fab, findsOneWidget);
  });
}
