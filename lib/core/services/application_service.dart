import '../models/application_model.dart';
import 'api_service.dart';

class ApplicationService {
  final ApiService _api;

  ApplicationService(this._api);

  Future<Application> getById(int id) async {
    final response = await _api.get('/admin/applications/$id');
    return Application.fromJson(response);
  }

  Future<List<Application>> getAll() async {
    final response = await _api.get('/admin/applications');
    final List<dynamic> content = response['content'] ?? [];
    return content.map((e) => Application.fromJson(e)).toList();
  }

  Future<Application> advanceWorkflow(int id, int adminId, {String? notes}) async {
    final response = await _api.post(
      '/admin/applications/$id/advance?adminId=$adminId',
      body: {'notes': notes ?? ''},
    );
    return Application.fromJson(response);
  }

  Future<Application> rejectApplication(int id, int adminId, String reason) async {
    final response = await _api.post(
      '/admin/applications/$id/reject?adminId=$adminId',
      body: {'reason': reason},
    );
    return Application.fromJson(response);
  }

  // ===== Portal Methods =====

  Future<Application> createDraft(int facilityId, int userId, Map<String, dynamic> data) async {
    final response = await _api.post(
      '/portal/applications?facilityId=$facilityId&userId=$userId',
      body: data,
    );
    return Application.fromJson(response);
  }

  Future<Application> submitApplication(int id, int userId) async {
    final response = await _api.post(
      '/portal/applications/$id/submit?userId=$userId',
    );
    return Application.fromJson(response);
  }

  Future<List<Application>> getMyApplications(int facilityId) async {
    final response = await _api.get('/portal/applications', queryParams: {'facilityId': facilityId.toString()});
    final List<dynamic> content = response['content'] ?? [];
    return content.map((e) => Application.fromJson(e)).toList();
  }

  Future<Application> getPortalById(int id) async {
    final response = await _api.get('/portal/applications/$id');
    return Application.fromJson(response);
  }

  Future<void> uploadAndAddDocument({
    required int applicationId,
    required int userId,
    required String docType,
    required String fileName,
    required List<int> bytes,
    bool mandatory = true,
  }) async {
    // 1. Upload file to get URL
    final uploadResponse = await _api.uploadFile('/documents/upload', fileName, bytes);
    final String fileUrl = uploadResponse['fileUrl'];

    // 2. Link to application
    await _api.post(
      '/portal/applications/$applicationId/documents?userId=$userId',
      body: {
        'documentType': docType,
        'fileUrl': fileUrl,
        'isMandatory': mandatory,
      },
    );
  }
}
