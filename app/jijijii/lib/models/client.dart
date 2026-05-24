class Client {
  String id;
  String fullName;
  String phone;
  String email;
  List<String> history; // История ID номеров

  Client({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.email,
    required this.history,
  });
}