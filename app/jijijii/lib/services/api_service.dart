import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/room.dart';
import '../models/client.dart';
import '../models/booking.dart';

class ApiService {
  // Напоминалка: если тестируешь на Android-эмуляторе, замени localhost на 10.0.2.2
  static const String baseUrl = 'http://localhost/hotel_api';

  // --- НОМЕРА ---
  static Future<List<Room>> getRooms() async {
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
    }
    throw Exception('Ошибка сервера');
  }

  static Future<bool> addRoom(String number, String type, double price) async {
    final response = await http.post(
      Uri.parse('$baseUrl/rooms.php'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"number": number, "type": type, "price_per_night": price}),
    );
    return response.statusCode == 200 && jsonDecode(response.body)['success'] == true;
  }

  static Future<bool> updateRoomStatus(String id, String status) async {
    final response = await http.put(
      Uri.parse('$baseUrl/rooms.php'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"id": id, "status": status}),
    );
    return response.statusCode == 200 && jsonDecode(response.body)['success'] == true;
  }

  static Future<bool> deleteRoom(String id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/rooms.php'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"id": id}),
    );
    return response.statusCode == 200 && jsonDecode(response.body)['success'] == true;
  }

  // --- КЛИЕНТЫ ---
  static Future<List<Client>> getClients() async {
    final response = await http.get(Uri.parse('$baseUrl/clients.php'));
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((item) {
        String rawHistory = item['history'] ?? '';
        List<String> historyList = rawHistory.split(',').where((e) => e.isNotEmpty).toList();
        return Client(
          id: item['id'].toString(),
          fullName: item['full_name'].toString(),
          phone: item['phone'].toString(),
          email: item['email'].toString(),
          history: historyList,
        );
      }).toList();
    }
    throw Exception('Ошибка сервера');
  }

  static Future<bool> addClient(String name, String phone, String email) async {
    final response = await http.post(
      Uri.parse('$baseUrl/clients.php'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"full_name": name, "phone": phone, "email": email}),
    );
    return response.statusCode == 200 && jsonDecode(response.body)['success'] == true;
  }

  // --- БРОНИ ---
  static Future<List<Booking>> getBookings() async {
    final response = await http.get(Uri.parse('$baseUrl/bookings.php'));
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => Booking(
        id: item['id'].toString(),
        roomId: item['room_id'].toString(),
        clientId: item['client_id'].toString(),
        checkInDate: DateTime.parse(item['check_in_date']),
        checkOutDate: DateTime.parse(item['check_out_date']),
        totalCost: double.parse(item['total_cost'].toString()),
        isActive: item['is_active'].toString() == '1',
      )).toList();
    }
    throw Exception('Ошибка сервера');
  }

  static Future<bool> addBooking(String roomId, String clientId, String roomNumber, int days, double totalCost) async {
    final response = await http.post(
      Uri.parse('$baseUrl/bookings.php'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "room_id": roomId,
        "client_id": clientId,
        "room_number": roomNumber,
        "days": days,
        "total_cost": totalCost
      }),
    );
    return response.statusCode == 200 && jsonDecode(response.body)['success'] == true;
  }
}