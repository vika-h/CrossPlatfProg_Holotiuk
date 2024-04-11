import 'package:flutter/material.dart';
import 'edit_transaction_screen.dart'; 
import '../utils/database_helper.dart';
import '../widgets/bottom_navigation_bar.dart'; 

// Екран для відображення транзакцій
class TransactionScreen extends StatefulWidget {
  @override
  _TransactionScreenState createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  
  /// Екземпляр DatabaseHelper для взаємодії з локальною базою даних.
  final DatabaseHelper databaseHelper = DatabaseHelper(); 

  /// Побудова віджету для екрану історії транзакцій.
  ///
  /// [context]: Контекст поточного віджету.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Історія транзакцій'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: databaseHelper.getAllTransactionsSortedByDate(), // Отримання всіх транзакцій, відсортованих за датою
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) { // Показуємо індикатор завантаження, якщо дані завантажуються
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            List<Map<String, dynamic>> transactions = snapshot.data!; // Отримуємо список транзакцій з результату майбутнього завдання
            Map<String, List<Map<String, dynamic>>> transactionsByDate = groupTransactionsByDate(transactions); // Групуємо транзакції за датою
            return ListView.builder(
              itemCount: transactionsByDate.length, // Кількість елементів - кількість унікальних дат
              itemBuilder: (context, index) {
                String date = transactionsByDate.keys.elementAt(index); // Отримуємо дату зі списку ключів
                List<Map<String, dynamic>> transactionsForDate = transactionsByDate[date]!; // Отримуємо список транзакцій за певну дату
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Text(
                        date, // Відображення дати
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
                      ),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: transactionsForDate.length,
                      itemBuilder: (context, index) {
                        Map<String, dynamic> transaction = transactionsForDate[index];
                        bool isIncome = bool.parse(transaction['isIncome']); // Визначаємо, чи це дохід
                        Color indicatorColor = isIncome ? Colors.green : Colors.red; // Встановлюємо колір індикатора
                        IconData indicatorIcon = isIncome ? Icons.arrow_upward : Icons.arrow_downward; // Встановлюємо значок індикатора
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: indicatorColor, // Колір індикатора
                            child: Icon(indicatorIcon, color: Colors.white), // Значок індикатора
                          ),
                          title: Text(transaction['category']), // Відображення категорії транзакції
                          subtitle: Text('${transaction['amount']} UAH'), // Відображення суми транзакції
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [

                              // Кнопка редагувати
                              IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () {
                                    print(transaction['id']);
                                    print(isIncome);
                                    // Обробник для кнопки редагування
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => EditTransactionScreen(
                                            id: transaction['id'], // Передача ідентифікатора 
                                            isIncome: isIncome, // Передача типу транзакції (дохід чи витрата)
                                            amount: transaction['amount'], // Передача суми 
                                            date: transaction['date'], // Передача дати 
                                            description: transaction['description'], // Передача опису 
                                            category: transaction['category'], // Передача категорії 
                                            ),
                                        ),
                                    ).then((value) {
                                    if (value != null && value) {
                                        // Якщо від EditTransactionScreen повернувся результат, що зміни були внесені, оновлення списку.
                                        setState(() {});
                                    };
                                });
                                }
                              ),

                              // Кнопка видалити
                              IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: Text('Видалення транзакції'),
                                      content: Text('Ви впевнені, що хочете видалити цю транзакцію?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            if (isIncome) {
                                                databaseHelper.deleteIncome(transaction['id']!);
                                            } else {
                                                databaseHelper.deleteExpense(transaction['id']!);
                                            }
                                            Navigator.of(context).pop(); // Закриття діалогового вікна
                                            setState(() {});
                                          },
                                          child: Text('Видалити'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop(); // Закриття діалогового вікна
                                          },
                                          child: Text('Закрити'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    Divider(),
                  ],
                );
              },
            );
          }
        },
      ),
      bottomNavigationBar: CustomBottomNavigationBar(),
    );
  }

  /// Функція `groupTransactionsByDate` приймає список транзакцій і групує їх за датою, 
  /// повертаючи словник, де кожен ключ - це дата, а відповідне значення - це список 
  /// транзакцій, що відбулися у цю дату.
  Map<String, List<Map<String, dynamic>>> groupTransactionsByDate(List<Map<String, dynamic>> transactions) {
    // Ініціалізуємо пустий словник `result`, щоб зберігати згруповані транзакції.
    Map<String, List<Map<String, dynamic>>> result = {};
    // Проходимося по кожній транзакції у списку `transactions`.
    for (var transaction in transactions) {
      // Отримуємо дату транзакції.
      String date = transaction['date'];
      // Перевіряємо, чи вже містить словник `result` запис з такою датою.
      if (!result.containsKey(date)) {
        // Якщо немає, ініціалізуємо пустий список для цієї дати.
        result[date] = [];
      }
      // Додаємо поточну транзакцію до списку, що відповідає її даті у словнику `result`.
      result[date]!.add(transaction);
    }
    return result;
  }
}
