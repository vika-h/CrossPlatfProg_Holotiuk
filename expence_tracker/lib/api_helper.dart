import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiHelper {
    
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