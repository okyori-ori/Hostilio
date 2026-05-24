import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/room.dart';

class ApiService {
  // Меняй localhost на IP-адрес сервера, если тестируешь с мобильного телефона
  static const String baseUrl = 'http://localhost/hotel_api';

  // Получение списка номеров с бэкенда
  static Future<List<Room>> getRooms() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/rooms.php'));
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => Room(
          id: item['id'].toString(),
          number: item['number'].toString(),
          type: item['type'].toString(),
          pricePerNight: double.parse(item['price_per_night'].toString()),
          status: item['status'].toString(),
        )).toList();
      } else {
        throw Exception('Ошибка сервера: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Не удалось подключиться к серверу: $e');
    }
  }

  // Отправка нового номера в MySQL
  static Future<bool> addRoom(String number, String type, double price) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/rooms.php'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "number": number,
          "type": type,
          "price_per_night": price,
        }),
      );
      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        return result['success'] ?? false;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}