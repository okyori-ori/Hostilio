import 'package:flutter/material.dart';
import '../models/booking.dart';
import '../models/room.dart';
import '../models/client.dart';
import '../services/api_service.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  List<Booking> _bookings = [];
  List<Room> _rooms = [];
  List<Client> _clients = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  void _loadAllData() async {
    setState(() => _isLoading = true);
    try {
      final bookings = await ApiService.getBookings();
      final rooms = await ApiService.getRooms();
      final clients = await ApiService.getClients();
      setState(() {
        _bookings = bookings;
        _rooms = rooms;
        _clients = clients;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка сети: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Бронирование номеров (MySQL)', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            ElevatedButton.icon(
              onPressed: _rooms.isEmpty || _clients.isEmpty ? null : _createBookingDialog,
              icon: const Icon(Icons.add),
              label: const Text('Создать бронь'),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _bookings.isEmpty
              ? const Center(child: Text('Нет активных бронирований'))
              : ListView.builder(
            itemCount: _bookings.length,
            itemBuilder: (context, index) {
              final booking = _bookings[index];
              final room = _rooms.firstWhere((r) => r.id == booking.roomId, orElse: () => Room(id: '', number: '?', type: '', pricePerNight: 0, status: ''));
              final client = _clients.firstWhere((c) => c.id == booking.clientId, orElse: () => Client(id: '', fullName: 'Удален', phone: '', email: '', history: []));

              return Card(
                color: booking.isActive ? Colors.white : Colors.grey.shade300,
                child: ListTile(
                  title: Text('Бронь — Комната №${room.number} (${room.type})'),
                  subtitle: Text('Клиент: ${client.fullName}\nСтоимость: ${booking.totalCost} руб.'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_forever, color: Colors.red),
                    onPressed: () {
                      ApiService.deleteBooking(booking.id).then((success) {
                        if (success) {
                          ApiService.updateRoomStatus(room.id, 'Свободен').then((_) => _loadAllData());
                        }
                      });
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _createBookingDialog() {
    final freeRooms = _rooms.where((r) => r.status == 'Свободен').toList();
    if (freeRooms.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Нет свободных номеров для бронирования!')));
      return;
    }

    Room selectedRoom = freeRooms.first;
    Client selectedClient = _clients.first;
    int days = 1;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          double totalCost = selectedRoom.pricePerNight * days;

          return AlertDialog(
            title: const Text('Новое бронирование'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Выберите комнату:'),
                DropdownButton<Room>(
                  value: selectedRoom,
                  isExpanded: true,
                  items: freeRooms.map((r) => DropdownMenuItem(value: r, child: Text('Комната ${r.number} (${r.type} - ${r.pricePerNight} руб)'))).toList(),
                  onChanged: (v) => setDialogState(() => selectedRoom = v!),
                ),
                const SizedBox(height: 10),
                const Text('Выберите клиента:'),
                DropdownButton<Client>(
                  value: selectedClient,
                  isExpanded: true,
                  items: _clients.map((c) => DropdownMenuItem(value: c, child: Text(c.fullName))).toList(),
                  onChanged: (v) => setDialogState(() => selectedClient = v!),
                ),
                TextField(
                  decoration: const InputDecoration(labelText: 'Количество дней проживания'),
                  keyboardType: TextInputType.number,
                  onChanged: (v) {
                    setDialogState(() {
                      days = int.tryParse(v) ?? 1;
                    });
                  },
                ),
                const SizedBox(height: 15),
                Text('Итоговая стоимость: $totalCost руб.', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 16)),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Отмена')),
              ElevatedButton(
                onPressed: () {
                  ApiService.addBooking(selectedRoom.id, selectedClient.id, selectedRoom.number, days, totalCost).then((success) {
                    if (success) {
                      _loadAllData();
                      Navigator.pop(context);
                    }
                  });
                },
                child: const Text('Оформить'),
              )
            ],
          );
        },
      ),
    );
  }
}