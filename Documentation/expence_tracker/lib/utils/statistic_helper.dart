import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'database_helper.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// Перечислення для типів діаграм.
enum ChartType { expenses, incomes, combined }

/// Клас StatisticHelper відповідає за побудову та відображення статистики у вигляді діаграм.
class StatisticHelper {
  final DatabaseHelper databaseHelper = DatabaseHelper();
  ChartType currentChartType = ChartType.expenses; // Початковий вид діаграми

  /// Метод changeChartType призначений для зміни типу діаграми.
  /// 
  /// Параметри:
  ///   - newType: новий тип діаграми, який потрібно встановити.
  /// 
  /// При виклику цього методу змінюється значення поля currentChartType
  /// на переданий новий тип діаграми.
  void changeChartType(ChartType newType) {
    currentChartType = newType;
  }

  /// Метод buildChart створює відповідну діаграму в залежності від переданого типу.
  /// 
  /// Параметри:
  ///   - chartType: тип діаграми (витрати, доходи або комбінована).
  ///   - startDate: початкова дата періоду, за який буде побудована діаграма.
  ///   - endDate: кінцева дата періоду, за який буде побудована діаграма.
  /// 
  /// Повертає:
  ///   - Віджет, який містить побудовану діаграму.
  Widget buildChart(ChartType chartType, DateTime startDate, DateTime endDate) {
    final periodText = '${startDate.day}.${startDate.month}.${startDate.year} - ${endDate.day}.${endDate.month}.${endDate.year}';

    switch (chartType) {
      case ChartType.expenses:
        return buildChartWidget(
          'Статистика витрат:',
          startDate,
          endDate,
          periodText,
          databaseHelper.getExpenseStatistics,
        );
      case ChartType.incomes:
        return buildChartWidget(
          'Статистика доходів:',
          startDate,
          endDate,
          periodText,
          databaseHelper.getIncomeStatistics,
        );
      case ChartType.combined:
        return buildCombinedChart(startDate, endDate, periodText);
      default:
        return Container();
    }
  }

  /// Метод buildChartWidget генерує віджет, який містить побудовану діаграму на основі отриманих статистичних даних.
  /// 
  /// Параметри:
  ///   - title: заголовок для віджету.
  ///   - startDate: початкова дата періоду, за який буде побудована діаграма.
  ///   - endDate: кінцева дата періоду, за який буде побудована діаграма.
  ///   - periodText: текст, що відображає період, для відображення в заголовку.
  ///   - statisticsFunction: функція, яка повертає статистичні дані для побудови діаграми.
  /// 
  /// Повертає:
  ///   - Віджет, який містить побудовану діаграму або повідомлення про відсутність даних.
  Widget buildChartWidget(String title, DateTime startDate, DateTime endDate, String periodText, Future<List<Map<String, dynamic>>> Function(DateTime, DateTime) statisticsFunction) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: statisticsFunction(startDate, endDate), // Викликає функцію, що повертає статистичні дані.
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) { // Перевіряє, чи дані віддаються
          return Center(child: CircularProgressIndicator()); // Показує індикатор завантаження, якщо дані ще не отримані.
        } else if (snapshot.hasError) { // Перевіряє, чи сталася помилка під час отримання даних
          return Text('Помилка: ${snapshot.error}'); // Виводить повідомлення про помилку
        } else {
          final List<Map<String, dynamic>> statistics = snapshot.data ?? []; // Отримує дані з снапшоту

          // Перевіряє, чи немає статистичних даних або всі значення total рівні null або 0
          if (statistics.isEmpty || statistics.every((data) => data['total'] == null || data['total'] == 0)) {
            return Column(
              children: <Widget>[
                SizedBox(height: 20),
                Text(
                  title, // Заголовок діаграми
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  periodText, // Відображення періоду
                  style: TextStyle(
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                SizedBox(height: 10),
                Center(
                  child: Text(
                    'Дані для цього періоду відсутні',  // Виводить повідомлення, якщо немає даних
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            );
          }
          // Якщо дані є, створюємо віджет з діаграмою
          return Column(
            children: <Widget>[
              SizedBox(height: 20),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text(
                periodText,
                style: TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                ),
              ),
              SizedBox(height: 10),
              Expanded(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: PieChart(
                          PieChartData(
                            sections: List.generate(
                              statistics.length,
                              (index) => PieChartSectionData(
                                color: Colors.accents[index % Colors.accents.length], // Встановлює колір для кожної секції діаграми
                                value: statistics[index]['total'].toDouble(), // Встановлює значення для кожної секції діаграми
                                radius: 90,
                                showTitle: false,
                              ),
                            ),
                            centerSpaceRadius: 50,

                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      // Умовний оператор для вибору положення легенди
                      bottom: kIsWeb ? null : 0, 
                      right: kIsWeb ? 0 : null, 
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 16, right: 16),
                        child: buildLegendWidget(statistics), // Відображення легенди діаграми
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }
      },
    );
  }

  /// Метод buildCombinedChart генерує віджет, який містить побудовану комбіновану діаграму витрат і доходів на основі отриманих статистичних даних.
  /// 
  /// Параметри:
  ///   - startDate: початкова дата періоду, за який буде побудована діаграма.
  ///   - endDate: кінцева дата періоду, за який буде побудована діаграма.
  ///   - periodText: текст, що відображає період, для відображення в заголовку.
  /// 
  /// Повертає:
  ///   - Віджет, який містить побудовану комбіновану діаграму витрат і доходів або повідомлення про відсутність даних.
  Widget buildCombinedChart(DateTime startDate, DateTime endDate, String periodText) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: databaseHelper.getCombinedStatistics(startDate, endDate), // Отримує статистичні дані для побудови комбінованої діаграми
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) { // Перевіряє, чи дані віддаються
          return Center(child: CircularProgressIndicator()); // Показує індикатор завантаження, якщо дані ще не отримані
        } else if (snapshot.hasError) { // Перевіряє, чи сталася помилка під час отримання даних
          return Text('Помилка: ${snapshot.error}'); // Виводить повідомлення про помилку
        } else {
          final List<Map<String, dynamic>> combinedData = snapshot.data ?? []; // Отримує дані з снапшоту

          // Отримує загальну суму витрат
          double totalExpenses = combinedData.isNotEmpty && combinedData[0]['totalExpenses'] != null
              ? (combinedData[0]['totalExpenses'])[0]['total'] ?? 0.0
              : 0.0;
          // Отримує загальну суму доходів
          double totalIncomes = combinedData.isNotEmpty && combinedData[0]['totalIncomes'] != null
              ? (combinedData[0]['totalIncomes'])[0]['total'] ?? 0.0
              : 0.0;

          return Column(
            children: [
              SizedBox(height: 20),
              Text(
                'Статистика витрат та доходів:', // Заголовок діаграми
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text(
                periodText, // Відображення періоду
                style: TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                ),
              ),
              SizedBox(height: 10),
              totalExpenses == 0.0 && totalIncomes == 0.0
                  ? Center(
                      child: Text('Дані для цього періоду відсутні'), // Виводить повідомлення, якщо немає даних
                    )
                  : Expanded(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: PieChart(
                                PieChartData(
                                  sections: [
                                    if (totalExpenses != 0.0) // Додає секцію для витрат, якщо вони є
                                      PieChartSectionData(
                                        color: Colors.accents[0 % Colors.accents.length],
                                        value: totalExpenses,
                                        radius: 90,
                                        showTitle: false
                                      ),
                                    if (totalIncomes != 0.0) // Додає секцію для доходів, якщо вони є
                                      PieChartSectionData(
                                        color: Colors.accents[1 % Colors.accents.length],
                                        value: totalIncomes,
                                        radius: 90,
                                        showTitle: false
                                      ),
                                  ],
                                  centerSpaceRadius: 60,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            // Умовний оператор для вибору положення легенди
                            bottom: kIsWeb ? null : 0, 
                            right: kIsWeb ? 0 : null, 
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 16, right: 16),
                              child: buildLegendWidget([
                                if (totalExpenses != 0.0) {'category': 'Витрати', 'color': Colors.red}, // Легенда для витрат
                                if (totalIncomes != 0.0) {'category': 'Доходи', 'color': Colors.green}, // Легенда для доходів
                              ]),
                            ),
                          ),
                        ],
                      ),
                    ),
            ],
          );
        }
      },
    );
  }

  /// Метод _buildLegendItem створює віджет для кожного елементу легенди.
  /// 
  /// Параметри:
  ///   - color: Колір для елементу легенди.
  ///   - title: Текстова мітка для елементу легенди.
  /// 
  /// Повертає:
  ///   - Віджет, що містить елемент легенди з кольором і текстом.
  Widget _buildLegendItem(Color color, String title) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          color: color,
        ),
        SizedBox(width: 5),
        Text(
          title,
          style: TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  /// Метод buildLegendWidget створює віджет легенди для відображення на діаграмі.
  /// 
  /// Параметри:
  ///   - statistics: Статистичні дані для відображення в легенді.
  /// 
  /// Повертає:
  ///   - Віджет легенди, який може бути розміщений біля діаграми залежно від типу пристрою.
  Widget buildLegendWidget(List<Map<String, dynamic>> statistics) {
    if (kIsWeb) {
      return _buildLegendRowSide(statistics); // Відображає легенду збоку, якщо програма працює у веб-середовищі
    } else {
      return _buildLegendRowBottom(statistics); // Відображає легенду знизу, якщо програма працює на мобільному пристрої
    }
  }

  /// Функція _buildLegendRowBottom відповідає за розміщення легенди знизу від діаграми.
  /// 
  /// Параметри:
  ///   - statistics: Статистичні дані, які будуть відображені в легенді.
  /// 
  /// Повертає:
  ///   - Віджет, що містить легенду знизу від діаграми.
  Widget _buildLegendRowBottom(List<Map<String, dynamic>> statistics) {
    List<Widget> leftColumn = [];
    List<Widget> rightColumn = [];

    for (int i = 0; i < statistics.length; i += 2) {
      if (i + 1 < statistics.length) {
        leftColumn.add(
          _buildLegendItem(
            Colors.accents[i % Colors.accents.length],
            statistics[i]['category'],
          ),
        );
        rightColumn.add(
          _buildLegendItem(
            Colors.accents[(i + 1) % Colors.accents.length],
            statistics[i + 1]['category'],
          ),
        );
      } else {
        leftColumn.add(
          _buildLegendItem(
            Colors.accents[i % Colors.accents.length],
            statistics[i]['category'],
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: 20), 
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: leftColumn,
            ),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: rightColumn,
            ),
          ],
        ),
      ],
    );
  }

  /// Функція _buildLegendRowSide відповідає за розміщення легенди збоку від діаграми.
  /// 
  /// Параметри:
  ///   - statistics: Статистичні дані, які будуть відображені в легенді.
  /// 
  /// Повертає:
  ///   - Віджет, що містить легенду збоку від діаграми.
  Widget _buildLegendRowSide(List<Map<String, dynamic>> statistics) {
    List<Widget> leftColumn = [];
    List<Widget> rightColumn = [];

    for (int i = 0; i < statistics.length; i += 2) {
      if (i + 1 < statistics.length) {
        leftColumn.add(
          _buildLegendItem(
            Colors.accents[i % Colors.accents.length],
            statistics[i]['category'],
          ),
        );
        rightColumn.add(
          _buildLegendItem(
            Colors.accents[(i + 1) % Colors.accents.length],
            statistics[i + 1]['category'],
          ),
        );
      } else {
        leftColumn.add(
          _buildLegendItem(
            Colors.accents[i % Colors.accents.length],
            statistics[i]['category'],
          ),
        );
      }
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: leftColumn,
        ),
        SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: rightColumn,
        ),
      ],
    );
  }
}
