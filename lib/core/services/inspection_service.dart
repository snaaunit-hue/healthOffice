import 'api_service.dart';
import '../models/inspection_model.dart';
import '../models/admin_model.dart'; // Create this simple model

class InspectionService {
  final ApiService _api;

  InspectionService(this._api);

  Future<Inspection> scheduleInspection(int appId, int inspectorId, DateTime scheduledDate) async {
    final response = await _api.post(
      '/admin/inspections/schedule',
      queryParams: {
        'applicationId': appId.toString(),
        'inspectorId': inspectorId.toString(),
        'scheduledDate': scheduledDate.toUtc().toIso8601String(),
      },
    );
    return Inspection.fromJson(response);
  }

  Future<Inspection> getActiveForApplication(int applicationId) async {
    final response = await _api.get('/admin/inspections/active-by-application/$applicationId');
    return Inspection.fromJson(response);
  }

  Future<Inspection> getById(int id) async {
    final response = await _api.get('/admin/inspections/$id');
    return Inspection.fromJson(response);
  }

  Future<Inspection> completeInspection(int inspectionId, double overallScore, String notes, List<Map<String, dynamic>> items) async {
    final response = await _api.post(
      '/admin/inspections/$inspectionId/complete',
      body: {
        'overallScore': overallScore,
        'notes': notes,
        'items': items,
      },
      // Ensure ApiService handles List<Map> correctly in body
    );
    return Inspection.fromJson(response);
  }

  Future<List<Inspection>> getScheduledInspections() async {
    // Assuming backend supports /inspections?status=SCHEDULED
    // Backend (InspectionController) usually exposes search or list. 
    // Step 565 Shows getByStatus exists in Service, need to check Controller.
    // Assuming /admin/inspections?status=SCHEDULED mapped to Service.
    // If not, I might fail. But let's assume standard REST.
    final response = await _api.get('/admin/inspections', queryParams: {'status': 'SCHEDULED'}); 
    // Response is Page<InspectionDto>, so content is inside 'content'.
    // If backend returns list directly, then map.
    // Most Spring Data REST returns Page.
    // Let's assume standard response structure. If List, direct map.
    if (response['content'] != null) {
      return (response['content'] as List).map((i) => Inspection.fromJson(i)).toList();
    } else if (response is List) {
       return (response as List).map((i) => Inspection.fromJson(i)).toList();
    }
    return [];
  }

  Future<List<AdminUser>> getInspectors() async {
    final response = await _api.getList('/admin/users/inspectors'); // List<dynamic>
    return response.map((json) => AdminUser.fromJson(json)).toList();
  }
}
