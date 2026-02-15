import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../data/facility_model.dart';

class FacilityRepository {
  // Replace with your actual backend URL or use a config file
  final String baseUrl = 'http://10.0.2.2:8080/api/facilities'; 

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<List<FacilityModel>> getFacilities({
    String? search,
    String? governorate,
    String? district,
    String? facilityType,
    String? operationalStatus,
    int page = 0,
    int size = 20,
  }) async {
    final queryParams = {
      if (search != null && search.isNotEmpty) 'search': search,
      if (governorate != null && governorate.isNotEmpty) 'governorate': governorate,
      if (district != null && district.isNotEmpty) 'district': district,
      if (facilityType != null && facilityType.isNotEmpty) 'facilityType': facilityType,
      if (operationalStatus != null && operationalStatus.isNotEmpty) 'operationalStatus': operationalStatus,
      'page': page.toString(),
      'size': size.toString(),
    };

    final uri = Uri.parse(baseUrl).replace(queryParameters: queryParams);
    final headers = await _getHeaders();

    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> content = data['content'];
      return content.map((json) => FacilityModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load facilities');
    }
  }

  Future<FacilityModel> updateStatus(int id, String status, int adminId) async {
    final uri = Uri.parse('$baseUrl/$id/status')
        .replace(queryParameters: {'status': status, 'adminId': adminId.toString()});
    final headers = await _getHeaders();

    final response = await http.put(uri, headers: headers);

    if (response.statusCode == 200) {
      return FacilityModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update status');
    }
  }

  Future<FacilityModel> getFacilityById(int id) async {
    final uri = Uri.parse('$baseUrl/$id');
    final headers = await _getHeaders();
    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      return FacilityModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load facility details');
    }
  }
}
