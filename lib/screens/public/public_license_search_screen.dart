import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../core/config/app_config.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/public_scaffold.dart';
import '../../core/localization/app_localizations.dart';

class PublicLicenseSearchScreen extends StatefulWidget {
  const PublicLicenseSearchScreen({super.key});

  @override
  State<PublicLicenseSearchScreen> createState() => _PublicLicenseSearchScreenState();
}

class _PublicLicenseSearchScreenState extends State<PublicLicenseSearchScreen> {
  final _controller = TextEditingController();
  Map<String, dynamic>? _result;
  bool _isLoading = false;
  String? _error;

  Future<void> _search() async {
    final loc = AppLocalizations.of(context)!;
    if (_controller.text.isEmpty) return;
    
    setState(() {
      _isLoading = true;
      _result = null;
      _error = null;
    });

    try {
      final response = await http.get(
        Uri.parse('${AppConfig.apiBaseUrl}/public/license-check').replace(
          queryParameters: {'licenseNumber': _controller.text},
        ),
      );

      if (response.statusCode == 200) {
        setState(() {
          _result = jsonDecode(response.body);
          _isLoading = false;
        });
      } else if (response.statusCode == 404) {
        setState(() {
          _error = '${loc.translate('licenseNumber')} ${loc.translate('noData')}';
          _isLoading = false;
        });
      } else {
        throw Exception('Server error');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = loc.translate('error');
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return PublicScaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              loc.translate('verifyLicense'),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen),
            ),
            const SizedBox(height: 8),
            Text(
              loc.translate('portalDescription'),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 40),
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: loc.translate('licenseNumber'),
                hintText: 'e.g., LIC-2023-0001',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: _search,
                ),
              ),
              onSubmitted: (_) => _search(),
            ),
            const SizedBox(height: 32),
            if (_isLoading) const CircularProgressIndicator(),
            if (_error != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red),
                    const SizedBox(width: 12),
                    Expanded(child: Text(_error!, style: const TextStyle(color: Colors.red))),
                  ],
                ),
              ),
            if (_result != null) _buildResultCard(loc),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard(AppLocalizations loc) {
    final isValid = _result!['isValid'] as bool;
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isValid ? AppTheme.primaryGreen : AppTheme.errorRed,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(isValid ? Icons.check_circle : Icons.warning, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  isValid ? loc.translate('valid').toUpperCase() : loc.translate('invalid').toUpperCase(),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _resultRow(loc.translate('facilityName'), _result!['facilityName']),
                _resultRow(loc.translate('facilityType'), loc.translate(_result!['facilityType'] == 'HOSPITAL' ? 'hospital' : _result!['facilityType'] == 'CENTER' ? 'medicalCenter' : _result!['facilityType'] == 'CLINIC' ? 'clinic' : 'pharmacy')),
                _resultRow(loc.translate('licenseNumber'), _result!['licenseNumber']),
                _resultRow(loc.translate('expiryDate'), _result!['expiryDate']),
                _resultRow(loc.translate('status'), loc.translate(_result!['status'].toLowerCase())),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _resultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
