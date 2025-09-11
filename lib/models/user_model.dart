class UserModel {
  final String id;
  final String name;
  final String email;
  final String role;

  UserModel({required this.id, required this.name, required this.email, required this.role});

  factory UserModel.fromJson(String id, Map<String, dynamic> json) {
    return UserModel(
      id: id,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'student',
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'email': email, 'role': role};
  }
}
