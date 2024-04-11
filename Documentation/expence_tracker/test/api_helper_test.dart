import 'package:flutter_test/flutter_test.dart';
import 'package:http/testing.dart'; // Імпорт для використання MockClient
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../lib/utils/api_helper.dart'; // Імпорт класу ApiHelper, який буде тестуватися

void main() {
  group('ApiHelper', () {
    test('getCurrencyRate returns correct rate for UAH', () async {
      // Перевірка, чи метод повертає правильний курс для UAH
      final apiHelper = ApiHelper();
      final rate = await apiHelper.getCurrencyRate('UAH');
      expect(rate, equals(1.0));
    });

    test('getCurrencyRate returns correct rate for USD', () async {
      // Перевірка, чи метод повертає правильний курс для USD при правильній відповіді сервера
      final currencySymbol = 'USD';
      final responseBody = '[{"rate": 30}]'; // Модель відповіді від сервера
      final client = MockClient((request) async {
        return http.Response(responseBody, 200);
      });

      final apiHelper = ApiHelper();
      final rate = await apiHelper.getCurrencyRate(currencySymbol);
      expect(rate, equals(39.0232));
    });  
  });
}
