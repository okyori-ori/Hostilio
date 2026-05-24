import 'package:flutter/material.dart';
import '../models/client.dart';
import '../services/api_service.dart';

class ClientsScreen extends StatefulWidget {
  const ClientsScreen({super.key}); // Больше не просим данные извне

  @override
  State<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  List<Client> _clients = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchClients();
  }

  void _fetchClients() {
    setState(() => _isLoading = true);
    ApiService.getClients().then((loadedClients) {
      setState(() {
        _clients = loadedClients;
        _isLoading = false;
      });
    }).catchError((e) {
      setState(() => _isLoading = false);
      _showError('Ошибка загрузки клиентов: $e');
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Регистрация и учет клиентов (MySQL)', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            ElevatedButton.icon(
              onPressed: _registerClientDialog,
              icon: const Icon(Icons.person_add),
              label: const Text('Регистрация клиента'),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _clients.isEmpty
              ? const Center(child: Text('Нет зарегистрированных клиентов'))
              : ListView.builder(
            itemCount: _clients.length,
            itemBuilder: (context, index) {
              final client = _clients[index];
              return Card(
                child: ListTile(
                  title: Text(client.fullName),
                  subtitle: Text('Тел: ${client.phone} | Email: ${client.email}'),
                  trailing: Text('История номеров: ${client.history.join(", ")}'),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _registerClientDialog() {
    String name = '';
    String phone = '';
    String email = '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Регистрация нового клиента'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(decoration: const InputDecoration(labelText: 'ФИО'), onChanged: (v) => name = v),
            TextField(decoration: const InputDecoration(labelText: 'Телефон'), onChanged: (v) => phone = v),
            TextField(decoration: const InputDecoration(labelText: 'Email'), onChanged: (v) => email = v),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Отмена')),
          ElevatedButton(
            onPressed: () {
              if (name.isNotEmpty && phone.isNotEmpty) {
                ApiService.addClient(name, phone, email).then((success) {
                  if (success) {
                    _fetchClients();
                    Navigator.pop(context);
                  }
                }).catchError((e) => _showError('Ошибка добавления: $e'));
              }
            },
            child: const Text('Создать'),
          )
        ],
      ),
    );
  }
}