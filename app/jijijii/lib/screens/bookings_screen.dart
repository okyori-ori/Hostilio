import 'package:flutter/material.dart';
import '../models/booking.dart';
import '../models/room.dart';
import '../models/client.dart';

class BookingsScreen extends StatefulWidget {
  final List<Booking> bookings;
  final List<Room> rooms;
  final List<Client> clients;

  const BookingsScreen({super.key, required this.bookings, required this.rooms, required this.clients});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Бронирование номеров', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            ElevatedButton.icon(
              onPressed: widget.rooms.isEmpty || widget.clients.isEmpty ? null : _createBookingDialog,
              icon: const Icon(Icons.add),
              label: const Text('Создать бронь'),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Expanded(
          child: widget.bookings.isEmpty
              ? const Center(child: Text('Нет активных бронирований'))
              : ListView.builder(
            itemCount: widget.bookings.length,
            itemBuilder: (context, index) {
              final booking = widget.bookings[index];
              final room = widget.rooms.firstWhere((r) => r.id == booking.roomId);
              final client = widget.clients.firstWhere((c) => c.id == booking.clientId);

              return Card(
                color: booking.isActive ? Colors.white : Colors.grey.shade300,
                child: ListTile(
                  title: Text('Бронь — Комната ${room.number}'),
                  subtitle: Text('Клиент: ${client.fullName}\nСтоимость: ${booking.totalCost} руб.'),
                  trailing: booking.isActive
                      ? IconButton(
                    icon: const Icon(Icons.cancel, color: Colors.red),
                    onPressed: () {
                      setState(() {
                        booking.isActive = false;
                        room.status = 'Свободен';
                      });
                    },
                  )
                      : null,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _createBookingDialog() {
    Room selectedRoom = widget.rooms.first;
    Client selectedClient = widget.clients.first;
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
              children: [
                DropdownButton<Room>(
                  value: selectedRoom,
                  items: widget.rooms.map((r) => DropdownMenuItem(value: r, child: Text('Комната ${r.number}'))).toList(),
                  onChanged: (v) => setDialogState(() => selectedRoom = v!),
                ),
                DropdownButton<Client>(
                  value: selectedClient,
                  items: widget.clients.map((c) => DropdownMenuItem(value: c, child: Text(c.fullName))).toList(),
                  onChanged: (v) => setDialogState(() => selectedClient = v!),
                ),
                TextField(
                  decoration: const InputDecoration(labelText: 'Количество дней'),
                  keyboardType: TextInputType.number,
                  onChanged: (v) {
                    setDialogState(() {
                      days = int.tryParse(v) ?? 1;
                    });
                  },
                ),
                const SizedBox(height: 15),
                Text('Итоговая стоимость: $totalCost руб.', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Отмена')),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    widget.bookings.add(Booking(
                      id: DateTime.now().toString(),
                      roomId: selectedRoom.id,
                      clientId: selectedClient.id,
                      checkInDate: DateTime.now(),
                      checkOutDate: DateTime.now().add(Duration(days: days)),
                      totalCost: totalCost,
                    ));
                    selectedRoom.status = 'Занят';
                  });
                  Navigator.pop(context);
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