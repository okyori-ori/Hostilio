import 'package:flutter/material.dart';
import '../models/room.dart';

class RoomsScreen extends StatefulWidget {
  final List<Room> rooms;
  const RoomsScreen({super.key, required this.rooms});

  @override
  State<RoomsScreen> createState() => _RoomsScreenState();
}

class _RoomsScreenState extends State<RoomsScreen> {
  String filterStatus = 'Все';

  @override
  Widget build(BuildContext context) {
    final filteredRooms = widget.rooms.where((room) {
      if (filterStatus == 'Все') return true;
      return room.status == filterStatus;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Управление номерами', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            ElevatedButton.icon(
              onPressed: _addRoomDialog,
              icon: const Icon(Icons.add),
              label: const Text('Добавить номер'),
            ),
          ],
        ),
        const SizedBox(height: 10),
        DropdownButton<String>(
          value: filterStatus,
          items: <String>['Все', 'Свободен', 'Занят', 'Обслуживание'].map((String value) {
            return DropdownMenuItem<String>(value: value, child: Text(value));
          }).toList(),
          onChanged: (val) {
            setState(() {
              filterStatus = val!;
            });
          },
        ),
        Expanded(
          child: ListView.builder(
            itemCount: filteredRooms.length,
            itemBuilder: (context, index) {
              final room = filteredRooms[index];
              return Card(
                child: ListTile(
                  title: Text('Номер ${room.number} — ${room.type}'),
                  subtitle: Text('Цена: ${room.pricePerNight} руб/ночь | Статус: ${room.status}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      setState(() {
                        widget.rooms.remove(room);
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

  void _addRoomDialog() {
    String num = '';
    double price = 3000;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Добавить номер'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(decoration: const InputDecoration(labelText: 'Номер'), onChanged: (v) => num = v),
            TextField(decoration: const InputDecoration(labelText: 'Цена'), onChanged: (v) => price = double.tryParse(v) ?? 3000),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Отмена')),
          ElevatedButton(
            onPressed: () {
              setState(() {
                widget.rooms.add(Room(id: DateTime.now().toString(), number: num, type: 'Стандарт', pricePerNight: price, status: 'Свободен'));
              });
              Navigator.pop(context);
            },
            child: const Text('Добавить'),
          )
        ],
      ),
    );
  }
}