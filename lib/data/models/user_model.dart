class UserModel {
  final int id;
  final String email;
  final String firstname;
  final String lastname;
  final String? photoUrl;
  final String? birthday;
  final bool newsletter;

  UserModel({
    required this.id,
    required this.email,
    required this.firstname,
    required this.lastname,
    this.photoUrl,
    this.birthday,
    this.newsletter = false,
  });

  String get displayName => '$firstname $lastname';

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      email: json['email'] ?? '',
      firstname: json['firstname'] ?? '',
      lastname: json['lastname'] ?? '',
      photoUrl: json['photo_url'],
      birthday: json['birthday'],
      newsletter: json['newsletter'] == '1' || json['newsletter'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'firstname': firstname,
    'lastname': lastname,
    'photo_url': photoUrl,
    'birthday': birthday,
    'newsletter': newsletter ? '1' : '0',
  };
}
