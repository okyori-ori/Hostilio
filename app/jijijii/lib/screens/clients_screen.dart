import 'package:flutter/material.dart';
import '../models/client.dart';

class ClientsScreen extends StatefulWidget {
  final List<Client> clients;
  const ClientsScreen({super.key, required this.clients});

  @override
  State<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Регистрация и учет клиентов', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            ElevatedButton.icon(
              onPressed: _registerClientDialog,
              icon: const Icon(Icons.person_add),
              label: const Text('Регистрация клиента'),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Expanded(
          child: ListView.builder(
            itemCount: widget.clients.length,
            itemBuilder: (context, index) {
              final client = widget.clients[index];
              return Card(
                child: ListTile(
                  title: Text(client.fullName),
                  subtitle: Text('Тел: ${client.phone} | Email: ${client.email}'),
                  trailing: Text('История проживаний: ${client.history.length}'),
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
              setState(() {
                widget.clients.add(Client(
                  id: DateTime.now().toString(),
                  fullName: name,
                  phone: phone,
                  email: email,
                  history: [],
                ));
              });
              Navigator.pop(context);
            },
            child: const Text('Создать'),
          )
        ],
      ),
    );
  }
}