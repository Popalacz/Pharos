class AddressModel {
  final int id;
  final String alias;
  final String firstname;
  final String lastname;
  final String address1;
  final String? address2;
  final String postcode;
  final String city;
  final String country;
  final String? phone;

  AddressModel({
    required this.id,
    required this.alias,
    required this.firstname,
    required this.lastname,
    required this.address1,
    this.address2,
    required this.postcode,
    required this.city,
    required this.country,
    this.phone,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: int.parse(json['id'].toString()),
      alias: json['alias'] ?? 'Adres',
      firstname: json['firstname'] ?? '',
      lastname: json['lastname'] ?? '',
      address1: json['address1'] ?? '',
      address2: json['address2'],
      postcode: json['postcode'] ?? '',
      city: json['city'] ?? '',
      country: json['country_name'] ?? 'Polska', // W PrestaShop często id_country, tu zakładamy nazwę z pharos_api
      phone: json['phone'],
    );
  }

  Map<String, dynamic> toJson() => {
    'alias': alias,
    'firstname': firstname,
    'lastname': lastname,
    'address1': address1,
    'address2': address2,
    'postcode': postcode,
    'city': city,
    'phone': phone,
  };
}
