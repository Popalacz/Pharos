class OrderModel {
  final int id;
  final String reference;
  final String date;
  final double totalPaid;
  final String status;
  final String paymentMethod;

  OrderModel({
    required this.id,
    required this.reference,
    required this.date,
    required this.totalPaid,
    required this.status,
    required this.paymentMethod,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: int.parse(json['id'].toString()),
      reference: json['reference'] ?? 'BRAK',
      date: json['date_add'] ?? '',
      totalPaid: double.parse(json['total_paid'].toString()),
      status: json['status_name']?.toString() ?? json['status']?.toString() ?? 'Oczekiwanie',
      paymentMethod: json['payment'] ?? 'Nieokreślona',
    );
  }
}
