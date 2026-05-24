import 'package:flutter/material.dart';
import '../models/client.dart';
import '../services/api_service.dart';

class ClientsScreen extends StatefulWidget {
  const ClientsScreen({super.key});

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
            const Text('Учет клиентов', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
            ElevatedButton.icon(
              onPressed: () => _clientDialog(null),
              icon: const Icon(Icons.person_add),
              label: const Text('Регистрация клиента'),
            ),
          ],
        ),
        const SizedBox(height: 15),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: Colors.blueAccent))
              : _clients.isEmpty
              ? const Center(child: Text('Нет зарегистрированных клиентов', style: TextStyle(color: Colors.white54)))
              : ListView.builder(
            itemCount: _clients.length,
            itemBuilder: (context, index) {
              final client = _clients[index];
              return Card(
                child: ListTile(
                  title: Text(client.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Тел: ${client.phone} | Email: ${client.email}', style: const TextStyle(color: Colors.white60)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('История: ${client.history.join(", ")}', style: const TextStyle(color: Colors.white38, fontSize: 13)),
                      const SizedBox(width: 10),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blueAccent),
                        onPressed: () => _clientDialog(client),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () {
                          ApiService.deleteClient(client.id).then((success) {
                            if (success) _fetchClients();
                          }).catchError((e) => _showError('Ошибка удаления: $e'));
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _clientDialog(Client? client) {
    final isEditing = client != null;

    String name = isEditing ? client.fullName : '';
    String phone = isEditing ? client.phone : '';
    String email = isEditing ? client.email : '';

    final nameController = TextEditingController(text: name);
    final phoneController = TextEditingController(text: phone);
    final emailController = TextEditingController(text: email);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Text(isEditing ? 'Редактировать данные' : 'Регистрация клиента', style: const TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: 'ФИО'),
              onChanged: (v) => name = v,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: phoneController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: 'Телефон'),
              onChanged: (v) => phone = v,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: emailController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: 'Email'),
              onChanged: (v) => email = v,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Отмена', style: TextStyle(color: Colors.white54))),
          ElevatedButton(
            onPressed: () {
              if (name.isNotEmpty && phone.isNotEmpty) {
                if (isEditing) {
                  ApiService.updateClient(client.id, name, phone, email).then((success) {
                    if (success) {
                      _fetchClients();
                      Navigator.pop(context);
                    }
                  }).catchError((e) => _showError('Ошибка обновления: $e'));
                } else {
                  ApiService.addClient(name, phone, email).then((success) {
                    if (success) {
                      _fetchClients();
                      Navigator.pop(context);
                    }
                  }).catchError((e) => _showError('Ошибка добавления: $e'));
                }
              }
            },
            child: Text(isEditing ? 'Сохранить' : 'Создать'),
          )
        ],
      ),
    );
  }
}