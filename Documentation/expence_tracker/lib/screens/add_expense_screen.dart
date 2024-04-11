import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../utils/database_helper.dart';
import '../widgets/bottom_navigation_bar.dart'; 

/// Екран для додавання витрат.
class AddExpenseScreen extends StatelessWidget {

  /// Опис категорії витрати, якщо вказано.
  final String? category;
  /// Контролер для введення суми витрати.
  final TextEditingController amountController = TextEditingController();
  /// Контролер для введення дати витрати.
  final TextEditingController dateController = TextEditingController();
  /// Контролер для введення опису витрати.
  final TextEditingController descriptionController = TextEditingController();
  /// Екземпляр DatabaseHelper для взаємодії з локальною базою даних.
  DatabaseHelper dbHelper = DatabaseHelper();

  /// Обрана категорія витрати.
  String? selectedCategory;

  /// Конструктор класу [AddExpenseScreen].
  ///
  /// [category]: Категорія витрат, яка передається з попереднього екрану.
  AddExpenseScreen({Key? key, this.category}) : super(key: key);

  /// Побудова віджету для екрану додавання витрат.
  ///
  /// [context]: Контекст поточного віджету.
  @override
  Widget build(BuildContext context) {
    DateTime selectedDate = DateTime.now(); // Початкова обрана дата

    return Scaffold(
      appBar: AppBar(
        title: Text('Додати витрату'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (category != null)
              Text(
                'Категорія: $category',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            SizedBox(height: 16.0),
            TextField(
              controller: amountController, 
              decoration: InputDecoration(
                labelText: 'Сума',
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],
            ),
            SizedBox(height: 16.0),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Категорія',
              ),
              items: <String>[
                'Дім',
                'Продукти харчування',
                'Транспорт',
                'Тренування',
                'Подарунки',
                'Кафе',
                'Дозвілля',
                'Здоров\'я',
                'Інше',
              ].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? value) {
                selectedCategory = value;
              },
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(
                labelText: 'Опис',
              ),
              maxLength: 100,
            ),
            SizedBox(height: 16.0),
            TextField(
              readOnly: true, // Тільки для відображення
              onTap: () async {
                final DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                );
                print(pickedDate);
                if (pickedDate != null) {
                  // Встановлення обраної дати, якщо вибрана
                  selectedDate = pickedDate;
                  dateController.text = DateFormat('dd-MM-yyyy').format(selectedDate);
                }
              },
              controller: dateController,
              decoration: InputDecoration(
                labelText: 'Дата',
                suffixIcon: Icon(Icons.calendar_today),
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () async{
                // Логіка для збереження витрати
                // Отримання значень з полів вводу
                String amount = amountController.text.trim();
                String description = descriptionController.text.trim();
                String date = DateFormat('yyyy-MM-dd').format(selectedDate);
                if (selectedCategory != 0){
                    String? category = selectedCategory;
                }

                // Перевірка чи всі поля заповнені
                if (amount.isEmpty || date.isEmpty || selectedCategory == null) {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text('Помилка'),
                        content: Text('Будь ласка, заповніть всі поля.'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                  return;
                }

                // Метод createExpense з об'єкту dbHelper
                if (selectedCategory != null) {
                    print('Category: $selectedCategory');
                    print('Amount: $amount');
                    print('Date: $date');
                    print('Description: $description');

                    await dbHelper.createExpense(selectedCategory!, double.parse(amount), date, description);
                }

                // Очищення полів після збереження
                amountController.clear();
                descriptionController.clear();
                selectedDate = DateTime.now();

                // Повернення на попередню сторінку
                Navigator.pop(context, true);
              },
              child: Text('Зберегти'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(),
    );
  }
}
