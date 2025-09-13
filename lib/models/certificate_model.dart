class Certificate {
  final String id;
  final String fileUrl;
  final String qrCode;
  final bool paid;
  final String eventId;
  final String participantId;

  Certificate({
    required this.id,
    required this.fileUrl,
    required this.qrCode,
    required this.paid,
    required this.eventId,
    required this.participantId,
  });

  factory Certificate.fromJson(Map<String, dynamic> json) {
    return Certificate(
      id: json['_id'],
      fileUrl: json['fileUrl'],
      qrCode: json['qrCode'],
      paid: json['paid'] ?? false,
      eventId: json['event'],
      participantId: json['participant'],
    );
  }
}
