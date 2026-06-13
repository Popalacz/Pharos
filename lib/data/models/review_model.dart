class ReviewModel {
  final int id;
  final String customerName;
  final double rating;
  final String comment;
  final String date;

  ReviewModel({
    required this.id,
    required this.customerName,
    required this.rating,
    required this.comment,
    required this.date,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: int.parse(json['id'].toString()),
      customerName: json['customer_name'] ?? 'Klient Pharos',
      rating: double.parse(json['grade'].toString()),
      comment: json['content'] ?? '',
      date: json['date_add'] ?? '',
    );
  }
}
