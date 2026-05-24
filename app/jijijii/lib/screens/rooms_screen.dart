import 'package:flutter/material.dart';
import '../models/room.dart';
import '../services/api_service.dart'; // Импортируем наш сервис

class RoomsScreen extends StatefulWidget {
  const RoomsScreen({super.key}); // Больше не требуем список извне

  @override
  State<RoomsScreen> createState() => _RoomsScreenState();
}

class _RoomsScreenState extends State<RoomsScreen> {
  List<Room> _rooms = [];       // Сюда запишем комнаты от PHP
  bool _isLoading = true;       // Флаг загрузки (крутилка)
  String filterStatus = 'Все';

  @override
  void initState() {
    super.initState();
    _fetchRooms(); // Загружаем данные из БД при старте экрана
  }

  // Метод получения данных с PHP бэкенда
  void _fetchRooms() {
    setState(() => _isLoading = true);
    ApiService.getRooms().then((loadedRooms) {
      setState(() {
        _rooms = loadedRooms;
        _isLoading = false;
      });
    }).catchError((error) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: $error')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // Фильтрация
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
            const Text('Управление номерами (MySQL)', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
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
            setState(() { filterStatus = val!; });
          },
        ),
        // Если данные еще грузятся — показываем крутилку, если загрузились — список
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : filteredRooms.isEmpty
              ? const Center(child: Text('Нет номеров в базе данных'))
              : ListView.builder(
            itemCount: filteredRooms.length,
            itemBuilder: (context, index) {
              final room = filteredRooms[index];
              return Card(
                child: ListTile(
                  title: Text('Номер ${room.number} — ${room.type}'),
                  subtitle: Text('Цена: ${room.pricePerNight} руб/ночь'),
                  trailing: Text(room.status, style: const TextStyle(fontWeight: FontWeight.bold)),
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
        title: const Text('Добавить номер в БД'),
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
              // Отправляем данные на сервер через API
              ApiService.addRoom(num, 'Стандарт', price).then((success) {
                if (success) {
                  _fetchRooms(); // Перезапрашиваем список из БД, чтобы увидеть новый номер
                  Navigator.pop(context);
                }
              });
            },
            child: const Text('Добавить'),
          )
        ],
      ),
    );
  }
}