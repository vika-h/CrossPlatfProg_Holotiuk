import 'package:flutter/material.dart';
import '../database_helper.dart';
import '../bottom_navigation_bar.dart'; 

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

  final DatabaseHelper databaseHelper = DatabaseHelper(); // Створення об'єкту класу DatabaseHelper


  late TextEditingController _amountController;
  late TextEditingController _dateController;
  late TextEditingController _descriptionController;
  String? _selectedCategory;
  late DateTime _selectedDate;


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
    _amountController = TextEditingController(text: widget.amount.toString());
    _dateController = TextEditingController(text: widget.date);
    _descriptionController = TextEditingController(text: widget.description);
    _selectedCategory = widget.category;
    _selectedDate = DateTime.parse(widget.date);  
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Редагуватувати дохід'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            TextFormField(
              controller: _amountController,
              decoration: InputDecoration(labelText: 'Сума'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16.0),

            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: InputDecoration(
                labelText: 'Категорія',
              ),
              items: widget.isIncome ? dropdowns[0].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList() : dropdowns[1].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? value) {
                _selectedCategory = value;
              },
            ),
            SizedBox(height: 16.0),

            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Опис'),
            ),
            SizedBox(height: 16.0),

            TextFormField(
              controller: _dateController,
              decoration: InputDecoration(labelText: 'Дата'),
              keyboardType: TextInputType.datetime,
              readOnly: true,

              onTap: () async {
                final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: DateTime.parse(_dateController.text), // Початкова дата з контролера
                firstDate: DateTime(2015, 8),
                lastDate: DateTime.now(),
                );
                if (picked != null && picked != _selectedDate)
                setState(() {
                    _selectedDate = picked;
                    _dateController.text = "${picked.toLocal()}".split(' ')[0];
                });
              },
            ),
            SizedBox(height: 16.0),

            ElevatedButton(
              onPressed: () {
                // Оновлення транзакцію
                if (widget.isIncome) {
                  databaseHelper.updateIncome(
                    widget.id,
                    double.parse(_amountController.text),
                    _dateController.text,
                    _descriptionController.text,
                    _selectedCategory!,
                  );
                } else {
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
    _amountController.dispose();
    _dateController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
