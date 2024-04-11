import 'package:flutter/material.dart';
import '../utils/database_helper.dart';
import '../widgets/bottom_navigation_bar.dart'; 

// Екран для редагування транзакції
class EditTransactionScreen extends StatefulWidget {
  final int id;
  final bool isIncome;
  final double amount;
  final String date;
  final String description;
  final String category;

  EditTransactionScreen({
    required this.id,
    required this.isIncome,
    required this.amount,
    required this.date,
    required this.description,
    required this.category,
  });

  @override
  _EditTransactionScreenState createState() => _EditTransactionScreenState();
}

class _EditTransactionScreenState extends State<EditTransactionScreen> {

  /// Екземпляр DatabaseHelper для взаємодії з локальною базою даних.
  final DatabaseHelper databaseHelper = DatabaseHelper(); 
  
  // Контролер для введення суми транзакції
  late TextEditingController _amountController;
  // Контролер для введення дати транзакції
  late TextEditingController _dateController;
  // Контролер для введення опису транзакції
  late TextEditingController _descriptionController;
  // Вибрана категорія транзакції
  String? _selectedCategory;
  // Вибрана дата транзакції
  late DateTime _selectedDate;

  // Список категорій для випадаючих списків
  var dropdowns = [
                <String>[
                'Заробітня плата',
                'Відсотки',
                'Подарунки',
                'Інше',
              ],
              <String>[
                'Дім',
                'Продукти харчування',
                'Транспорт',
                'Тренування',
                'Подарунки',
                'Кафе',
                'Дозвілля',
                'Здоров\'я',
                'Інше',]
              ];

  @override
  void initState() {
    super.initState();
    // Ініціалізація контролерів та обраних значень
    _amountController = TextEditingController(text: widget.amount.toString());
    _dateController = TextEditingController(text: widget.date);
    _descriptionController = TextEditingController(text: widget.description);
    _selectedCategory = widget.category;
    _selectedDate = DateTime.parse(widget.date);  
  }

  /// Побудова віджету для екрану редагуватування транзакцій.
  ///
  /// [context]: Контекст поточного віджету.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Редагуватувати транзакцію'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Введення суми транзакції
            TextFormField(
              controller: _amountController, // Контролер для введення суми
              decoration: InputDecoration(labelText: 'Сума'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16.0),

            // Вибір категорії транзакції зі списку
            DropdownButtonFormField<String>(
              value: _selectedCategory, // Початкова обрана категорія
              decoration: InputDecoration(
                labelText: 'Категорія',
              ),
              // Перевірка дохід чи витрата
              items: widget.isIncome ? dropdowns[0].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value), // Відображення значення категорії
                );
              }).toList() : dropdowns[1].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),// Відображення значення категорії
                );
              }).toList(),
              onChanged: (String? value) {
                // Оновлення обраної категорії при зміні
                _selectedCategory = value;
              },
            ),
            SizedBox(height: 16.0),

            // Введення опису транзакції
            TextFormField(
              controller: _descriptionController, // Контролер для введення опису
              decoration: InputDecoration(labelText: 'Опис'),
            ),
            SizedBox(height: 16.0),

            // Вибір дати транзакції за допомогою календаря
            TextFormField(
              controller: _dateController, // Контролер для введення дати
              decoration: InputDecoration(labelText: 'Дата'),
              keyboardType: TextInputType.datetime,
              readOnly: true, // Текстове поле тільки для відображення

              onTap: () async {
                final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: DateTime.parse(_dateController.text), // Початкова дата з контролера
                firstDate: DateTime(2015, 8),
                lastDate: DateTime.now(),
                );
                if (picked != null && picked != _selectedDate)
                setState(() {
                  // Оновлення обраної дати при зміні
                    _selectedDate = picked;
                    _dateController.text = "${picked.toLocal()}".split(' ')[0];
                });
              },
            ),
            SizedBox(height: 16.0),

            // Кнопка для збереження змін
            ElevatedButton(
              onPressed: () {
                // Оновлення транзакцію
                if (widget.isIncome) {
                  // Якщо це дохід
                  databaseHelper.updateIncome(
                    widget.id,
                    double.parse(_amountController.text),
                    _dateController.text,
                    _descriptionController.text,
                    _selectedCategory!,
                  );
                } else {
                  // Якщо це витрата
                  databaseHelper.updateExpense(
                    widget.id,
                    double.parse(_amountController.text),
                    _dateController.text,
                    _descriptionController.text,
                    _selectedCategory!,
                  );
                }
                // Повернення на попередню сторінкуІ
                Navigator.pop(context, true);
              },
              child: Text('Save'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(),
    );
  }

  @override
  void dispose() {
    // Видалення контролерів при завершенні віджету
    _amountController.dispose();
    _dateController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
