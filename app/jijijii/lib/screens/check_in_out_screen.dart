import 'package:flutter/material.dart';
import '../models/room.dart';
import '../models/booking.dart';

class CheckInOutScreen extends StatefulWidget {
  final List<Room> rooms;
  final List<Booking> bookings;

  const CheckInOutScreen({super.key, required this.rooms, required this.bookings});

  @override
  State<CheckInOutScreen> createState() => _CheckInOutScreenState();
}

class _CheckInOutScreenState extends State<CheckInOutScreen> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Регистрация заезда и выезда', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 3.0),
            itemCount: widget.rooms.length,
            itemBuilder: (context, index) {
              final room = widget.rooms[index];
              return Card(
                color: room.status == 'Свободен' ? Colors.green.shade50 : Colors.red.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Комната ${room.number}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text('Статус: ${room.status}'),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton(
                            onPressed: room.status == 'Свободен' ? null : () {
                              setState(() { room.status = 'Свободен'; });
                            },
                            child: const Text('Выезд'),
                          ),
                          TextButton(
                            onPressed: room.status == 'Занят' ? null : () {
                              setState(() { room.status = 'Занят'; });
                            },
                            child: const Text('Заезд'),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              );
            },
          ),
        )
      ],
    );
  }
}