import 'api_service.dart';
import '../models/dashboard_stats_model.dart';

class DashboardService {
  final ApiService _api;

  DashboardService(this._api);

  Future<DashboardStats> getAdminStats() async {
    final response = await _api.get('/admin/dashboard/stats');
    return DashboardStats.fromJson(response);
  }
}
