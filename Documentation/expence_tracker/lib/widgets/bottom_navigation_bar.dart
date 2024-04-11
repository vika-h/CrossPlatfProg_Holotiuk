import 'package:flutter/material.dart';
import '../screens/main_screen.dart'; 
import '../screens/statistics_screen.dart'; 
import '../screens/transaction_screen.dart';

// Клас CustomBottomNavigationBar відповідає за побудову нижньої панелі навігації з іконками.
class CustomBottomNavigationBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Іконка для переходу на головний екран
          IconButton(
            icon: Icon(Icons.home, size: 45, color: Colors.green.withOpacity(0.5)),
            onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => MainScreen()));
            },
          ),
          // Іконка для переходу на екран статистики
          IconButton(
            icon: Icon(Icons.show_chart, size: 45, color: Colors.green.withOpacity(0.5)),
            onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => StatisticsScreen()));
            },
          ),
          // Іконка для переходу на екран історії транзакцій
          IconButton(
            icon: Icon(Icons.history, size: 45, color: Colors.green.withOpacity(0.5)),
            onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => TransactionScreen()));
            },
          ),

        ],
      ),
    );
  }
}
