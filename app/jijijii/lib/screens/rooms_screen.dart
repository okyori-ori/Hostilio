import 'package:flutter/material.dart';
import '../models/room.dart';
import '../services/api_service.dart';

class RoomsScreen extends StatefulWidget {
  const RoomsScreen({super.key});

  @override
  State<RoomsScreen> createState() => _RoomsScreenState();
}

class _RoomsScreenState extends State<RoomsScreen> {
  List<Room> _rooms = [];
  bool _isLoading = true;
  String filterStatus = 'Все';

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
    }).catchError((error) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка: $error')));
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredRooms = _rooms.where((room) {
      if (filterStatus == 'Все') return true;
      return room.status == filterStatus;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Управление номерами', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
            ElevatedButton.icon(
              onPressed: _addRoomDialog,
              icon: const Icon(Icons.add),
              label: const Text('Добавить номер'),
            ),
          ],
        ),
        const SizedBox(height: 15),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: filterStatus,
              dropdownColor: const Color(0xFF1E1E1E),
              style: const TextStyle(color: Colors.white, fontSize: 16),
              items: <String>['Все', 'Свободен', 'Занят', 'Обслуживание'].map((String value) {
                return DropdownMenuItem<String>(value: value, child: Text(value));
              }).toList(),
              onChanged: (val) {
                setState(() { filterStatus = val!; });
              },
            ),
          ),
        ),
        const SizedBox(height: 15),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: Colors.blueAccent))
              : filteredRooms.isEmpty
              ? const Center(child: Text('Нет номеров в базе данных', style: TextStyle(color: Colors.white54)))
              : ListView.builder(
            itemCount: filteredRooms.length,
            itemBuilder: (context, index) {
              final room = filteredRooms[index];
              return Card(
                child: ListTile(
                  title: Text('Номер ${room.number} — ${room.type}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Цена: ${room.pricePerNight} руб/ночь | Статус: ${room.status}', style: const TextStyle(color: Colors.white60)),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () {
                      ApiService.deleteRoom(room.id).then((success) {
                        if (success) _fetchRooms();
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
    String selectedType = 'Стандарт';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          title: const Text('Добавить номер в БД', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Номер комнаты'),
                style: const TextStyle(color: Colors.white),
                onChanged: (v) => num = v,
              ),
              const SizedBox(height: 15),
              const Text('Тип номера:', style: TextStyle(color: Colors.white60, fontSize: 14)),
              const SizedBox(height: 5),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(color: const Color(0xFF2A2A2A), borderRadius: BorderRadius.circular(8)),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedType,
                    dropdownColor: const Color(0xFF2A2A2A),
                    isExpanded: true,
                    style: const TextStyle(color: Colors.white),
                    items: <String>['Стандарт', 'Премиум', 'Люкс'].map((String value) {
                      return DropdownMenuItem<String>(value: value, child: Text(value));
                    }).toList(),
                    onChanged: (val) {
                      setDialogState(() { selectedType = val!; });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                decoration: const InputDecoration(labelText: 'Цена за ночь'),
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.number,
                onChanged: (v) => price = double.tryParse(v) ?? 3000,
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Отмена', style: TextStyle(color: Colors.white54))),
            ElevatedButton(
              onPressed: () {
                if (num.isNotEmpty) {
                  ApiService.addRoom(num, selectedType, price).then((success) {
                    if (success) {
                      _fetchRooms();
                      Navigator.pop(context);
                    }
                  });
                }
              },
              child: const Text('Добавить'),
            )
          ],
        ),
      ),
    );
  }
}