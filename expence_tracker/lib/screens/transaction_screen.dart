import 'package:flutter/material.dart';
import '../database_helper.dart'; 
import 'edit_transaction_screen.dart'; 
import '../bottom_navigation_bar.dart'; 


class TransactionScreen extends StatefulWidget {
  @override
  _TransactionScreenState createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  
  final DatabaseHelper databaseHelper = DatabaseHelper(); 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Історія транзакцій'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: databaseHelper.getAllTransactionsSortedByDate(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            List<Map<String, dynamic>> transactions = snapshot.data!;
            Map<String, List<Map<String, dynamic>>> transactionsByDate = groupTransactionsByDate(transactions);
            return ListView.builder(
              itemCount: transactionsByDate.length,
              itemBuilder: (context, index) {
                String date = transactionsByDate.keys.elementAt(index);
                List<Map<String, dynamic>> transactionsForDate = transactionsByDate[date]!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Text(
                        date,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
                      ),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: transactionsForDate.length,
                      itemBuilder: (context, index) {
                        Map<String, dynamic> transaction = transactionsForDate[index];
                        bool isIncome = bool.parse(transaction['isIncome']);
                        Color indicatorColor = isIncome ? Colors.green : Colors.red;
                        IconData indicatorIcon = isIncome ? Icons.arrow_upward : Icons.arrow_downward;
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: indicatorColor,
                            child: Icon(indicatorIcon, color: Colors.white),
                          ),
                          title: Text(transaction['category']),
                          subtitle: Text('${transaction['amount']} UAH'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
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

  Map<String, List<Map<String, dynamic>>> groupTransactionsByDate(List<Map<String, dynamic>> transactions) {
    Map<String, List<Map<String, dynamic>>> result = {};
    for (var transaction in transactions) {
      String date = transaction['date'];
      if (!result.containsKey(date)) {
        result[date] = [];
      }
      result[date]!.add(transaction);
    }
    return result;
  }
}
