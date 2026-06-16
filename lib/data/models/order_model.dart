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
    // Rozszerzone mapowanie statusów PrestaShop dla Senior Architecta
    switch (stateId) {
      case '1':
      case '10':
        return 'Oczekiwanie';
      case '2':
      case '11':
      case '12':
        return 'Płatność zaakceptowana';
      case '3':
        return 'W trakcie przygotowania';
      case '4':
        return 'Wysłano';
      case '5':
        return 'Dostarczono';
      case '6':
        return 'Anulowano';
      case '7':
        return 'Zwrócono';
      case '8':
        return 'Błąd płatności';
      default:
        return 'Oczekiwanie';
    }
  }
}
