import 'package:flutter/material.dart';
import '../models/feedback_model.dart';
import '../services/feedback_service.dart';

class FeedbackProvider with ChangeNotifier {
  List<FeedbackModel> _feedbacks = [];

  List<FeedbackModel> get feedbacks => _feedbacks;

  Future<void> fetchFeedbacks(String eventId) async {
    _feedbacks = await FeedbackService.getFeedbacks(eventId);
    notifyListeners();
  }

  Future<bool> submitFeedback(String eventId, int rating, String comment, String token) async {
    try {
      await FeedbackService.submitFeedback(eventId, rating, comment, token);
      return true;
    } catch (_) {
      return false;
    }
  }
}
