class NotificationModel {
  final String id;
  final String userId;
  final String type;
  final String message;
  final bool read;
  final String? relatedEventId;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.message,
    required this.read,
    this.relatedEventId,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['_id'],
      userId: json['user'],
      type: json['type'],
      message: json['message'],
      read: json['read'] ?? false,
      relatedEventId: json['relatedEvent'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
