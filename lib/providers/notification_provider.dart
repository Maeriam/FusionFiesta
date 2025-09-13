import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';

class NotificationProvider with ChangeNotifier {
  List<NotificationModel> _notifications = [];

  List<NotificationModel> get notifications => _notifications;

  Future<void> fetchNotifications(String token) async {
    _notifications = await NotificationService.getNotifications(token);
    notifyListeners();
  }

  Future<bool> markAsRead(String id, String token) async {
    try {
      await NotificationService.markAsRead(id, token);

      _notifications = _notifications.map((n) {
        if (n.id == id) {
          return NotificationModel(
            id: n.id,
            userId: n.userId,
            type: n.type,
            message: n.message,
            read: true, // ✅ updated to match your model
            relatedEventId: n.relatedEventId,
            createdAt: n.createdAt,
          );
        }
        return n;
      }).toList();

      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }
}
