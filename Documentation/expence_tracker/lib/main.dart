import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:sqflite/sqflite.dart';
import 'utils/database_helper.dart'; // Додано імпорт бази даних
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'widgets/bottom_navigation_bar.dart'; 
import 'screens/main_screen.dart'; 
import 'screens/statistics_screen.dart'; 

void main() async {
  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  }
  WidgetsFlutterBinding.ensureInitialized(); // Для коректної роботи асинхронного коду
  await DatabaseHelper().initDatabase(); // Виклик методу initDatabase()
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Tracker by Vikylia',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      
      home: MainScreen(), // При запуску програми відкриваємо головний екран
    );
  }
}

