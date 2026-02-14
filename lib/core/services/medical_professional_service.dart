import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/medical_professional_model.dart';
import '../../main.dart'; // import global config or secure storage

class MedicalProfessionalService {
  final String baseUrl = 'http://localhost:8080/api/professionals'; // Replace with config

  Future<MedicalProfessional> createProfessional(MedicalProfessional professional) async {
    final token = await _getToken();
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(professional.toJson()),
    );

    if (response.statusCode == 200) {
      return MedicalProfessional.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create professional: ${response.body}');
    }
  }

  Future<List<MedicalProfessional>> search(String query) async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/search?query=$query'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => MedicalProfessional.fromJson(e)).toList();
    } else {
      return [];
    }
  }
  
  Future<String?> _getToken() async {
    // Implement token retrieval from SecureStorage
    return 'demo-token'; // temporary
  }
}
