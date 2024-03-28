import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'add_expense_screen.dart';
import 'add_income_screen.dart';
import '../database_helper.dart';
import '../bottom_navigation_bar.dart'; 
import '../api_helper.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final DatabaseHelper databaseHelper = DatabaseHelper();
  final ApiHelper apiHelper = ApiHelper();

  String _currentBalance = "0.00";
  String _totalIncome = "0.00";
  String _totalExpenses = "0.00";
  String _selectedCurrency = "UAH";
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Expense Tracker', style: GoogleFonts.bitter(fontSize: 30)),
        actions: [
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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 85.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
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
      bottomNavigationBar: CustomBottomNavigationBar(),
    );
  }
  void _showCurrencySelection(BuildContext context) {
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
        // Вибір валюти
        Future.microtask(() async {
        _selectedCurrency = value;
        _currencyRate = await apiHelper.getCurrencyRate(_selectedCurrency);
        _fetchData();

      });
      }
    });
}

}
