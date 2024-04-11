import 'dart:convert';
import 'package:http/http.dart' as http;

/// Клас ApiHelper відповідає за взаємодію з зовнішнім API для отримання курсів валют.
class ApiHelper {
    
    /// Метод для отримання курсу валюти за її символьним кодом.
    ///
    /// Параметри:
    ///  - currencySymbol: Символьний код валюти.
    ///
    /// Повертає курс валюти відносно гривні.
    /// Якщо символьний код валюти "UAH", повертається курс 1.0.
    /// Якщо курс валюти не знайдено або виникає помилка, викидається виняток з відповідним повідомленням.
    Future<double> getCurrencyRate(String currencySymbol) async {
        if(currencySymbol == "UAH")
        {
            return 1.0;
        }
        final response = await http.get(
            Uri.parse('https://bank.gov.ua/NBUStatService/v1/statdirectory/exchange?valcode=$currencySymbol&json'),
        );

        if (response.statusCode == 200) {
            List<dynamic> data = json.decode(response.body);
            return data[0]['rate'];
            throw Exception('Курс для вказаної валюти не знайдено');
        } else {
            throw Exception('Не вдалося отримати дані з сервера');
        }
    }
}