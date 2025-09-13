class User {
  final String id;
  final String name;
  final String email;
  final String role;
  final bool approved;
  final String? enrolmentNumber;
  final String? department;
  final String? collegeIdProof;
  final List<String> bookmarks; // ✅ added field

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.approved,
    this.enrolmentNumber,
    this.department,
    this.collegeIdProof,
    this.bookmarks = const [], // ✅ default empty list
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      approved: json['approved'] ?? false,
      enrolmentNumber: json['enrolmentNumber'],
      department: json['department'],
      collegeIdProof: json['collegeIdProof'],
      bookmarks: List<String>.from(json['bookmarks'] ?? []), // ✅ parse safely
    );
  }
}
