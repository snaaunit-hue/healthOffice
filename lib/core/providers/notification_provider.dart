import 'package:flutter/material.dart';
import '../services/notification_service.dart';
import '../models/notification_model.dart';

class NotificationProvider with ChangeNotifier {
  final NotificationService _service;
  int _unreadCount = 0;
  List<NotificationModel> _notifications = [];
  bool _isLoading = false;

  NotificationProvider({required NotificationService service}) : _service = service;

  int get unreadCount => _unreadCount;
  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;

  Future<void> refreshUnreadCount(int adminId) async {
    try {
      _unreadCount = await _service.getUnreadCount(adminId);
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching unread count: $e');
    }
  }

  Future<void> fetchNotifications(int adminId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _notifications = await _service.getNotifications(adminId);
      _unreadCount = await _service.getUnreadCount(adminId);
    } catch (e) {
      debugPrint('Error fetching notifications: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(int adminId, int notificationId) async {
    try {
      await _service.markAsRead(notificationId);
      await refreshUnreadCount(adminId);
      // Update local list status by re-fetching
      await fetchNotifications(adminId);
    } catch (e) {
      debugPrint('Error marking as read: $e');
    }
  }
}
