import '../models/facility_model.dart';
import 'api_service.dart';

class FacilityService {
  final ApiService _api;

  FacilityService(this._api);

  Future<List<Facility>> getMyFacilities(int userId) async {
    final response = await _api.get(
      '/portal/facilities',
      queryParams: {'userId': userId.toString()},
    );
    if (response is List) {
      return (response as List).map((e) => Facility.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }

  Future<FacilityProfile> getProfile(int facilityId) async {
    final response = await _api.get('/portal/facilities/$facilityId');
    return FacilityProfile.fromJson(response as Map<String, dynamic>);
  }
}
