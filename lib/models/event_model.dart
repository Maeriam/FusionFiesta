import 'user_model.dart';

class Event {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final String venue;
  final String category;
  final int registrationLimit;
  final String? bannerImage;
  final String? guidelinesDocument;
  final String status;
  final bool approved;
  final List<String> registeredUsers;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.venue,
    required this.category,
    required this.registrationLimit,
    this.bannerImage,
    this.guidelinesDocument,
    required this.status,
    required this.approved,
    required this.registeredUsers,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['_id'],
      title: json['title'],
      description: json['description'],
      date: DateTime.parse(json['date']),
      venue: json['venue'],
      category: json['category'],
      registrationLimit: json['registrationLimit'],
      bannerImage: json['bannerImage'],
      guidelinesDocument: json['guidelinesDocument'],
      status: json['status'] ?? "Pending",
      approved: json['approved'] ?? false,
      registeredUsers: List<String>.from(json['registeredUsers'] ?? []),
    );
  }
}
