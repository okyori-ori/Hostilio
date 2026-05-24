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
    }).catchError((e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка сети: $e')));
    });
  }

  void _changeStatus(String id, String newStatus) {
    ApiService.updateRoomStatus(id, newStatus).then((success) {
      if (success) {
        setState(() {
          final roomIndex = _rooms.indexWhere((r) => r.id == id);
          if (roomIndex != -1) {
            _rooms[roomIndex].status = newStatus;
          }
        });
      }
    });
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Свободен': return const Color(0xFF00E676);
      case 'Занят': return const Color(0xFFFF1744);
      case 'Обслуживание': return const Color(0xFFFF9100);
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Регистрация заезда, выезда и обслуживания',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: Colors.blueAccent))
              : GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 1.0, // Даем чуть больше высоты для предотвращения любых переполнений
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: _rooms.length,
            itemBuilder: (context, index) {
              final room = _rooms[index];
              final color = _getStatusColor(room.status);

              return Card(
                color: const Color(0xFF1E1E1E),
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border(top: BorderSide(color: color, width: 6)),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // ФИКС: Обернули текст номера в Expanded, чтобы он не давил на статус и не взрывал RenderFlex
                          Expanded(
                            child: Text(
                              '№${room.number}',
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                              overflow: TextOverflow.ellipsis, // Если текст не влезет, он аккуратно сократится с "..."
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: color.withOpacity(0.5)),
                            ),
                            child: Text(
                              room.status,
                              style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'Тип: ${room.type}',
                        style: const TextStyle(color: Colors.white70, fontSize: 15),
                      ),
                      const Divider(color: Colors.white10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        alignment: WrapAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: room.status == 'Занят' ? () => _changeStatus(room.id, 'Свободен') : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1B5E20),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            ),
                            child: const Text('Выезд'),
                          ),
                          ElevatedButton(
                            onPressed: room.status == 'Свободен' ? () => _changeStatus(room.id, 'Занят') : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0D47A1),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            ),
                            child: const Text('Заезд'),
                          ),
                          ElevatedButton(
                            onPressed: room.status == 'Обслуживание'
                                ? () => _changeStatus(room.id, 'Свободен')
                                : () => _changeStatus(room.id, 'Обслуживание'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE65100),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            ),
                            child: Text(room.status == 'Обслуживание' ? 'Готово' : 'Уборка'),
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