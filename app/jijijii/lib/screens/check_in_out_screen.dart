import 'package:flutter/material.dart';
import '../models/room.dart';
import '../services/api_service.dart';

class CheckInOutScreen extends StatefulWidget {
  const CheckInOutScreen({super.key});

  @override
  State<CheckInOutScreen> createState() => _CheckInOutScreenState();
}

class _CheckInOutScreenState extends State<CheckInOutScreen> {
  List<Room> _rooms = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRooms();
  }

  void _fetchRooms() {
    setState(() => _isLoading = true);
    ApiService.getRooms().then((loadedRooms) {
      setState(() {
        _rooms = loadedRooms;
        _isLoading = false;
      });
    }).catchError((e) => setState(() => _isLoading = false));
  }

  void _changeStatus(String id, String newStatus) {
    ApiService.updateRoomStatus(id, newStatus).then((success) {
      if (success) _fetchRooms();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Регистрация заезда и выезда (MySQL)', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 3.0),
            itemCount: _rooms.length,
            itemBuilder: (context, index) {
              final room = _rooms[index];
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
                            onPressed: room.status == 'Свободен' ? null : () => _changeStatus(room.id, 'Свободен'),
                            child: const Text('Выезд'),
                          ),
                          TextButton(
                            onPressed: room.status == 'Занят' ? null : () => _changeStatus(room.id, 'Занят'),
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