import 'api_service.dart';
import '../models/notification_model.dart';

class NotificationService {
  final ApiService _api;

  NotificationService(this._api);

  Future<List<NotificationModel>> getNotifications(int adminId, {int page = 0}) async {
    final response = await _api.get('/admin/notifications', queryParams: {
      'adminId': adminId.toString(),
      'page': page.toString(),
      'size': '20',
    });
    
    if (response['content'] != null) {
      return (response['content'] as List)
          .map((json) => NotificationModel.fromJson(json))
          .toList();
    }
    return [];
  }

  Future<int> getUnreadCount(int adminId) async {
    final response = await _api.get('/admin/notifications/unread-count', queryParams: {
      'adminId': adminId.toString(),
    });
    return response as int;
  }

  Future<void> markAsRead(int notificationId) async {
    await _api.put('/admin/notifications/$notificationId/read');
  }
}
