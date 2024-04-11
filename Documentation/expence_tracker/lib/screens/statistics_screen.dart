import 'package:flutter/material.dart';
import '../utils/database_helper.dart';
import '../widgets/bottom_navigation_bar.dart'; 
import '../utils/statistic_helper.dart';

// Екран для відображення статистики
class StatisticsScreen extends StatefulWidget {
  @override
  _StatisticsScreenState createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  /// Екземпляр DatabaseHelper для взаємодії з локальною базою даних.
  final DatabaseHelper databaseHelper = DatabaseHelper();
  /// Екземпляр StatisticHelper для обробки статистичних даних..
  final StatisticHelper statisticHelper = StatisticHelper();
  /// Тип графіку, який відображається на екрані статистики.
  ChartType currentChartType = ChartType.expenses;
  /// Початкова дата періоду статистики.  
  late DateTime startDate;
  /// Кінцева дата періоду статистики.
  late DateTime endDate; 

  @override
  void initState() {
    super.initState();
    setInitialDates();
  }
  // Метод для встановлення початкової дати з бази даних
  void setInitialDates() async {
    // Отримання початкової дати з бази даних
    startDate = await (databaseHelper.getDatabaseDates());
    startDate = startDate.subtract(Duration(days: 1));
    // Встановлення кінцевої дати на сьогоднішню дату
    endDate = DateTime.now();
    setState(() {}); // Оновлення стану для перебудови інтерфейсу з новими датами
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Статистика'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Вибір типу графіку: витрати, надходження, комбінована статистика
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                //витрати
                IconButton(
                  onPressed: () {
                    setState(() {
                      currentChartType = ChartType.expenses;
                    });
                  },
                  icon: Icon(Icons.trending_down, size: 50, color: Colors.red),
                ),
                //надходження
                IconButton(
                  onPressed: () {
                    setState(() {
                      currentChartType = ChartType.incomes;
                    });
                  },
                  icon: Icon(Icons.trending_up, size: 50, color: Colors.green),
                ),
                //статистика разом
                IconButton(
                  onPressed: () {
                    setState(() {
                      currentChartType = ChartType.combined;
                    });
                  },
                  icon: ShaderMask(
                    shaderCallback: (Rect bounds) {
                      return LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [Colors.green, Colors.red],
                      ).createShader(bounds);
                    },
                    child: Icon(
                      Icons.bar_chart_rounded,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20), // Проміжок між кнопками і періодом
            
            // Вибір періоду статистики: повна, за день, тиждень, місяць, календар
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                        onPressed: () {
                          setState(() {
                              // Визначення дати повної
                              setInitialDates();
                          });
                        },
                      child: Icon(Icons.timelapse),
                  ),

                  ElevatedButton(
                    onPressed: () {
                        setState(() {
                            // Визначення сьогоднішньої дати
                            endDate = DateTime.now();
                            startDate = endDate.subtract(Duration(days: 1));
                        });
                    },
                    child: Text('День'),
                  ),

                  ElevatedButton(
                        onPressed: () {
                        setState(() {
                            // Визначення дати 7 днів тому та сьогоднішньої дати
                            endDate = DateTime.now();
                            startDate = endDate.subtract(Duration(days: 6));
                        });
                    },
                    child: Text('Тиждень'),
                  ),

                  ElevatedButton(
                    onPressed: () {
                        setState(() {
                            // Визначення дати 30 днів тому та сьогоднішньої дати
                            endDate = DateTime.now();
                            startDate = endDate.subtract(Duration(days: 29));
                        });
                    },
                    child: Text('Місяць'),
                  ),

                    //календар
                  ElevatedButton(
                        onPressed: () async {
                            // Відображення календаря для вибору стартової та кінцевої дати
                            final selectedDates = await showDialog(
                                context: context,
                                builder: (context) => DateRangePickerDialog(
                                    firstDate: DateTime(2000), 
                                    lastDate: DateTime.now(),
                                ),
                            );

                          if (selectedDates != null) {
                            setState(() {
                                // Використання обраних дат для визначення періоду статистики
                                startDate = selectedDates.start.subtract(Duration(days: 1));
                                endDate = selectedDates.end;
                                print(startDate);
                                print(endDate);
                            });
                          }
                        },
                        child: Icon(Icons.calendar_today),
                  ),
                ],
            ),

            SizedBox(height: 20),
            // Відображення графіку статистики
            Expanded(
                child: FutureBuilder<DateTime>(
                    future: databaseHelper.getDatabaseDates(),
                    builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                            return CircularProgressIndicator(); // Показ індикатора завантаження, поки очікується результат
                        } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}'); // Вивід повідомлення про помилку
                        } else {
                            // Отримання значення першої дати з снапшоту та встановлення її як startDate
                            return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: statisticHelper.buildChart(currentChartType, startDate, endDate),
                            );
                        }
                    },
                ),
             ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(),
    );
  }
}
