import '../models/feedback_model.dart';
import 'api_service.dart';

class FeedbackService {
  static Future<List<FeedbackModel>> getFeedbacks(String eventId) async {
    final data = await ApiService.get("feedback/event/$eventId");
    return (data as List).map((f) => FeedbackModel.fromJson(f)).toList();
  }

  static Future<String> submitFeedback(String eventId, int rating, String comment, String token) async {
    final data = await ApiService.post(
      "feedback/$eventId",
      {"rating": rating, "comment": comment},
      token: token,
    );
    return data['message'];
  }
}
