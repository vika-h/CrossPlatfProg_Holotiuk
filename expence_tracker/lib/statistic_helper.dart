import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'database_helper.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

enum ChartType { expenses, incomes, combined }

class StatisticHelper {
  final DatabaseHelper databaseHelper = DatabaseHelper();
  ChartType currentChartType = ChartType.expenses; // Початковий вид діаграми

  void changeChartType(ChartType newType) {
    currentChartType = newType;
  }

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

  Widget buildChartWidget(String title, DateTime startDate, DateTime endDate, String periodText, Future<List<Map<String, dynamic>>> Function(DateTime, DateTime) statisticsFunction) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: statisticsFunction(startDate, endDate),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text('Помилка: ${snapshot.error}');
        } else {
          final List<Map<String, dynamic>> statistics = snapshot.data ?? [];

          if (statistics.isEmpty || statistics.every((data) => data['total'] == null || data['total'] == 0)) {
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
                Center(
                  child: Text(
                    'Дані для цього періоду відсутні',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            );
          }
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
                                color: Colors.accents[index % Colors.accents.length],
                                value: statistics[index]['total'].toDouble(),
                                radius: 90,
                                showTitle: false,
                              ),
                            ),
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
                        child: buildLegendWidget(statistics),
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

Widget buildCombinedChart(DateTime startDate, DateTime endDate, String periodText) {
  return FutureBuilder<List<Map<String, dynamic>>>(
    future: databaseHelper.getCombinedStatistics(startDate, endDate),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Center(child: CircularProgressIndicator());
      } else if (snapshot.hasError) {
        return Text('Помилка: ${snapshot.error}');
      } else {
        final List<Map<String, dynamic>> combinedData = snapshot.data ?? [];

        double totalExpenses = combinedData.isNotEmpty && combinedData[0]['totalExpenses'] != null
            ? (combinedData[0]['totalExpenses'])[0]['total'] ?? 0.0
            : 0.0;
        double totalIncomes = combinedData.isNotEmpty && combinedData[0]['totalIncomes'] != null
            ? (combinedData[0]['totalIncomes'])[0]['total'] ?? 0.0
            : 0.0;

        return Column(
          children: [
            SizedBox(height: 20),
            Text(
              'Статистика витрат та доходів:',
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
            totalExpenses == 0.0 && totalIncomes == 0.0
                ? Center(
                    child: Text('Дані для цього періоду відсутні'),
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
                                  if (totalExpenses != 0.0)
                                    PieChartSectionData(
                                      color: Colors.accents[0 % Colors.accents.length],
                                      value: totalExpenses,
                                      radius: 90,
                                      showTitle: false
                                    ),
                                  if (totalIncomes != 0.0)
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
                              if (totalExpenses != 0.0) {'category': 'Витрати', 'color': Colors.red},
                              if (totalIncomes != 0.0) {'category': 'Доходи', 'color': Colors.green},
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

  Widget buildLegendWidget(List<Map<String, dynamic>> statistics) {
    if (kIsWeb) {
      return _buildLegendRowSide(statistics);
    } else {
      return _buildLegendRowBottom(statistics);
    }
  }

  // Функція для розміщення легенди знизу від діаграми
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

  // Функція для розміщення легенди збоку від діаграми
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
