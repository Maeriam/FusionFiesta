import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../services/event_service.dart';

class EventProvider with ChangeNotifier {
  List<Event> _events = [];
  Event? _selectedEvent;
  bool _isLoading = false;

  List<Event> get events => _events;
  Event? get selectedEvent => _selectedEvent;
  bool get isLoading => _isLoading;

  Future<void> fetchEvents() async {
    _isLoading = true;
    notifyListeners();
    _events = await EventService.fetchEvents();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchEventById(String id) async {
    _isLoading = true;
    notifyListeners();
    _selectedEvent = await EventService.getEventById(id);
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> registerForEvent(String id, String token) async {
    try {
      await EventService.registerForEvent(id, token);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> approveEvent(String id, String token) async {
    try {
      await EventService.approveEvent(id, token);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteEvent(String id, String token) async {
    try {
      await EventService.deleteEvent(id, token);
      _events.removeWhere((e) => e.id == id);
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> updateEvent(String id, Map<String, dynamic> body, String token) async {
    try {
      final updatedEvent = await EventService.updateEvent(id, body, token);
      final index = _events.indexWhere((e) => e.id == id);
      if (index != -1) _events[index] = updatedEvent;
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }


  Future<List<dynamic>> getParticipants(String id, String token) async {
    return await EventService.getEventParticipants(id, token);
  }
}
