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
      status: _mapStatus(json['current_state'].toString()),
      paymentMethod: json['payment'] ?? 'Nieokreślona',
    );
  }

  static String _mapStatus(String stateId) {
    // Proste mapowanie statusów PrestaShop
    switch (stateId) {
      case '2': return 'Płatność zaakceptowana';
      case '3': return 'W trakcie przygotowania';
      case '4': return 'Wysłano';
      case '5': return 'Dostarczono';
      default: return 'Oczekiwanie';
    }
  }
}
