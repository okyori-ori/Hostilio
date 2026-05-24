class Booking {
  String id;
  String roomId;
  String clientId;
  DateTime checkInDate;
  DateTime checkOutDate;
  double totalCost;
  bool isActive;

  Booking({
    required this.id,
    required this.roomId,
    required this.clientId,
    required this.checkInDate,
    required this.checkOutDate,
    required this.totalCost,
    this.isActive = true,
  });
}