import 'package:flutter/material.dart';
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

  // Все списки-пустышки удалены, экраны работают автономно через PHP API
  final List<Widget> screens = [
    const RoomsScreen(),
    const BookingsScreen(),
    const ClientsScreen(),
    const CheckInOutScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hotel Management System v2.0 (PHP + MySQL)'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: Row(
        children: [
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