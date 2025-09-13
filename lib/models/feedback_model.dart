class FeedbackModel {
  final String id;
  final String eventId;
  final String participantId;
  final int rating;
  final String comment;
  final bool approved;

  FeedbackModel({
    required this.id,
    required this.eventId,
    required this.participantId,
    required this.rating,
    required this.comment,
    required this.approved,
  });

  factory FeedbackModel.fromJson(Map<String, dynamic> json) {
    return FeedbackModel(
      id: json['_id'],
      eventId: json['event'],
      participantId: json['participant'],
      rating: json['rating'],
      comment: json['comment'],
      approved: json['approved'] ?? false,
    );
  }
}
