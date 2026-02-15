import '../models/facility_model.dart';
import 'api_service.dart';

class AdminFacilityService {
  final ApiService _api;

  AdminFacilityService(this._api);

  Future<List<Facility>> getFacilities({
    String? facilityType,
    String? governorate,
    String? district,
    String? operationalStatus,
    int page = 0,
    int size = 50,
  }) async {
    final params = <String, String>{
      'page': page.toString(),
      'size': size.toString(),
    };
    if (facilityType != null && facilityType.isNotEmpty) params['facilityType'] = facilityType;
    if (governorate != null && governorate.isNotEmpty) params['governorate'] = governorate;
    if (district != null && district.isNotEmpty) params['district'] = district;
    if (operationalStatus != null && operationalStatus.isNotEmpty) params['operationalStatus'] = operationalStatus;
    final response = await _api.get('/admin/facilities', queryParams: params);
    final List<dynamic> content = response['content'] ?? [];
    return content.map((e) => Facility.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Facility> updateOperationalStatus(int facilityId, String operationalStatus, int adminId) async {
    final response = await _api.put(
      '/admin/facilities/$facilityId/operational-status',
      queryParams: {'adminId': adminId.toString(), 'operationalStatus': operationalStatus},
    );
    return Facility.fromJson(response as Map<String, dynamic>);
  }
}
