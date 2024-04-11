import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'add_expense_screen.dart';
import 'add_income_screen.dart';
import '../utils/database_helper.dart';
import '../widgets/bottom_navigation_bar.dart'; 
import '../utils/api_helper.dart';

// Головний екран додатка, відображає інформацію про баланс, доходи та витрати.
class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {

  /// Екземпляр DatabaseHelper для взаємодії з локальною базою даних.
  final DatabaseHelper databaseHelper = DatabaseHelper();
  /// Екземпляр ApiHelper для отримання обмінних курсів валют з зовнішнього API.
  final ApiHelper apiHelper = ApiHelper();

  /// Рядок, що представляє поточний баланс, ініціалізований значенням "0.00"
  String _currentBalance = "0.00";
  /// Рядок, що представляє загальний дохід, ініціалізований значенням "0.00".
  String _totalIncome = "0.00";
  /// Рядок, що представляє загальні витрати, ініціалізований значенням "0.00".
  String _totalExpenses = "0.00";
  /// Рядок, що представляє обрану валюту, ініціалізований значенням "UAH" (українська гривня).
  String _selectedCurrency = "UAH";
  /// Двійкове число, яке представляє обмінний курс, ініціалізоване значенням 1.0.
  double _currencyRate = 1.0;

  @override
  void initState() {
    super.initState();
    _fetchData(); // Метод для отримання даних при завантаженні екрану
  }

  // Метод для отримання даних з бази даних і оновлення відповідних змінних
  Future<void> _fetchData() async {
    final currentBalance = (await databaseHelper.getCurrentBalance() / _currencyRate).toStringAsFixed(2);
    final totalIncome = (await databaseHelper.getTotalIncome() / _currencyRate).toStringAsFixed(2);
    final totalExpenses = (await databaseHelper.getTotalExpenses() / _currencyRate).toStringAsFixed(2);
    
    setState(() {
      _currentBalance = currentBalance;
      _totalIncome = totalIncome;
      _totalExpenses = totalExpenses;
    });
  }
  
  /// Побудова головного екрану витрат та доходів, включаючи відображення балансу,
  /// загальної суми доходів та витрат, а також кнопок додавання доходів та витрат.
  ///
  /// Параметри:
  ///   - context: Контекст BuildContext, необхідний для взаємодії з інтерфейсом.
  ///
  /// Повертає:
  ///   - Scaffold: Віджет, що містить головний екран з відображенням балансу, доходів,
  ///     витрат та кнопок додавання доходів та витрат.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Expense Tracker', style: GoogleFonts.bitter(fontSize: 30)),
        actions: [
          // Кнопка для вибору валюти
          IconButton(
            icon: Icon(
              Icons.currency_exchange,
              size: 50,
              color: Colors.black.withOpacity(0.7),
            ),
            onPressed: () {
              _showCurrencySelection(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: AspectRatio(
            aspectRatio: 3 / 2,
            child: Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Container(
                alignment: Alignment.center,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  gradient: LinearGradient(
                    colors: [
                      Colors.green.withOpacity(0.5),
                      Colors.red.withOpacity(0.5)
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    // Іконка для балансу
                    Icon(
                      Icons.savings_outlined,
                      color: Colors.white,
                      size: 40
                    ),
                    Text(
                      'Баланс',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                    
                    SizedBox(height: 10),
                    Text(
                      '$_currentBalance $_selectedCurrency',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.bitter(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        // Відображення доходів
                        Column(
                          children: <Widget>[
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: Colors.white, width: 2),
                              ),
                              child: Icon(Icons.arrow_upward, size: 24, color: Colors.white),
                            ),
                            SizedBox(height: 5),
                            Text('Доходи',
                                style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center),
                            SizedBox(height: 5),
                            Text(
                              '$_totalIncome $_selectedCurrency',
                              style: GoogleFonts.bitter(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                        // Відображення витрат
                        Column(
                          children: <Widget>[
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: Colors.white, width: 2),
                              ),
                              child: Icon(Icons.arrow_downward, size: 24, color: Colors.white),
                            ),
                            SizedBox(height: 5),
                            Text('Витрати',
                                style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center),
                            SizedBox(height: 5),
                            Text(
                              '$_totalExpenses $_selectedCurrency',
                              style: GoogleFonts.bitter(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      // Кнопки додавання доходів та витрат
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 85.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Кнопка додавання доходів
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                border: Border.all(color: Colors.green.withOpacity(0.5), width: 4),
              ),
              child: IconButton(
                icon: Icon(Icons.add, size: 50, color: Colors.green.withOpacity(0.5)),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AddIncomeScreen()),
                  ).then((value) {
                    if (value != null && value) {
                      _fetchData();
                    }
                  });
                },
              ),
            ),
            // Кнопка додавання витрат
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.red.withOpacity(0.5), width: 4 ),
                borderRadius: BorderRadius.circular(50),
              ),
              child: IconButton(
                icon: Icon(Icons.remove, size: 50, color: Colors.red.withOpacity(0.5)),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AddExpenseScreen()),
                  ).then((value) {
                    if (value != null && value) {
                      _fetchData();
                    }
                  });
                },
              ),
            ),
          ],
        ),
      ),
      // Нижня панель навігації
      bottomNavigationBar: CustomBottomNavigationBar(),
    );
  }

  /// Показує вибір валюти у вигляді меню.
  ///
  /// Параметри:
  ///   - context: Контекст BuildContext, необхідний для взаємодії з інтерфейсом.
  void _showCurrencySelection(BuildContext context) {
    // Визначення розміщення кнопки валюти
    final RenderBox appBar = context.findRenderObject() as RenderBox;
    final RenderBox overlay = Overlay.of(context)!.context.findRenderObject() as RenderBox;
    final RenderBox button = context.findRenderObject() as RenderBox;

    final Offset buttonPosition = button.localToGlobal(Offset.zero);
    final RelativeRect position = RelativeRect.fromLTRB( 
      0, 
      0, 
      MediaQuery.of(context).size.width - buttonPosition.dx - button.size.width - 24, 
      0
    );

    // Показ меню вибору валюти
    showMenu(
      context: context,
      position: position,
      items: <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          value: 'USD',
          child: ListTile(
            title: Text('USD'),
          ),
        ),
        PopupMenuItem<String>(
          value: 'EUR',
          child: ListTile(
            title: Text('EUR'),
          ),
        ),
        PopupMenuItem<String>(
          value: 'UAH',
          child: ListTile(
            title: Text('UAH'),
          ),
        ),
      ],
    ).then((String? value) {
      if (value != null) {
      // Вибір валюти та оновлення даних
        Future.microtask(() async {
        _selectedCurrency = value;
        _currencyRate = await apiHelper.getCurrencyRate(_selectedCurrency);
        _fetchData();

      });
      }
    });
  }

}
