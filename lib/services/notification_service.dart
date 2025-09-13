import '../models/notification_model.dart';
import 'api_service.dart';

class NotificationService {
  static Future<List<NotificationModel>> getNotifications(String token) async {
    final data = await ApiService.get("notifications", token: token);
    return (data as List).map((n) => NotificationModel.fromJson(n)).toList();
  }

  static Future<String> markAsRead(String id, String token) async {
    final data = await ApiService.put("notifications/$id/read", {}, token: token);
    return data['message'];
  }
}
