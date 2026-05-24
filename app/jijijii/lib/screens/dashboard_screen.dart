import 'package:flutter/material.dart';
import '../models/room.dart';
import '../models/client.dart';
import '../models/booking.dart';
import 'rooms_screen.dart';
import 'bookings_screen.dart';
import 'clients_screen.dart';
import 'check_in_out_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  // Имитация базы данных (In-Memory списки для демонстрации преподу)
  final List<Room> rooms = [
    Room(id: '1', number: '101', type: 'Стандарт', pricePerNight: 3000, status: 'Свободен'),
    Room(id: '2', number: '102', type: 'Люкс', pricePerNight: 7000, status: 'Занят'),
  ];

  final List<Client> clients = [
    Client(id: '1', fullName: 'Иванов Иван Иванович', phone: '+79991112233', email: 'ivanov@mail.ru', history: ['101']),
  ];

  final List<Booking> bookings = [];

  @override
  Widget build(BuildContext context) {
    // Список экранов, куда прокидываем наши "базы данных"
    final List<Widget> screens = [
      RoomsScreen(rooms: rooms),
      BookingsScreen(bookings: bookings, rooms: rooms, clients: clients),
      ClientsScreen(clients: clients),
      CheckInOutScreen(rooms: rooms, bookings: bookings),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hotel Management System v1.0'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: Row(
        children: [
          // Боковое меню для удобства веб-интерфейса
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            labelType: NavigationRailLabelType.all,
            destinations: const [
              NavigationRailDestination(icon: Icon(Icons.hotel), label: Text('Номера')),
              NavigationRailDestination(icon: Icon(Icons.book_online), label: Text('Брони')),
              NavigationRailDestination(icon: Icon(Icons.people), label: Text('Клиенты')),
              NavigationRailDestination(icon: Icon(Icons.sync_alt), label: Text('Заезд/Выезд')),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          // Основной контент
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: screens[_selectedIndex],
            ),
          ),
        ],
      ),
    );
  }
}