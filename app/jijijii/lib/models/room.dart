class Room {
  String id;
  String number;
  String type; // Люкс, Стандарт и т.д.
  double pricePerNight;
  String status; // Свободен, Занят, Обслуживание

  Room({
    required this.id,
    required this.number,
    required this.type,
    required this.pricePerNight,
    required this.status,
  });
}