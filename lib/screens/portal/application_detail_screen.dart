import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/config/app_config.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/workflow_tracker.dart';
import '../../core/services/api_service.dart';
import '../../core/services/application_service.dart';
import '../../core/models/application_model.dart';

class ApplicationDetailScreen extends StatefulWidget {
  final int applicationId;
  const ApplicationDetailScreen({super.key, required this.applicationId});

  @override
  State<ApplicationDetailScreen> createState() => _ApplicationDetailScreenState();
}

class _ApplicationDetailScreenState extends State<ApplicationDetailScreen> {
  Application? _application;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchApplication();
  }

  Future<void> _fetchApplication() async {
    setState(() => _isLoading = true);
    try {
      final api = context.read<ApiService>();
      final service = ApplicationService(api);
      final app = await service.getPortalById(widget.applicationId);
      setState(() {
        _application = app;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
        setState(() => _isLoading = false);
      }
    }
  }

  int _statusToStep(String status) {
    const map = {
      'DRAFT': 0, 'SUBMITTED': 1, 'UNDER_REVIEW': 2, 'BLUEPRINT_REVIEW': 3,
      'INSPECTION_SCHEDULED': 4, 'INSPECTION_COMPLETED': 5, 'COMMITTEE_APPROVED': 6,
      'PAYMENT_PENDING': 7, 'PAYMENT_COMPLETED': 8, 'LICENSE_ISSUED': 9, 'ARCHIVED': 10,
    };
    return map[status] ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(loc.translate('applications'))),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_application == null) {
      return Scaffold(
        appBar: AppBar(title: Text(loc.translate('applications'))),
        body: Center(child: Text(loc.translate('noData'))),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('${loc.translate('applications')} #${_application!.applicationNumber}'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.go('/portal/applications')),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchApplication),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status & Workflow
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(loc.translate('workflowSteps'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const Spacer(),
                        StatusBadge(status: _application!.status),
                      ],
                    ),
                    const SizedBox(height: 8),
                    WorkflowTracker(currentStep: _statusToStep(_application!.status)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Facility Info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(loc.translate('facilityData'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const Divider(),
                    _infoRow(loc.translate('facilityName'), _application!.facilityNameAr),
                    _infoRow(loc.translate('facilityType'), _application!.facilityType),
                    _infoRow(loc.translate('licenseType'), _application!.licenseType),
                    _infoRow(loc.translate('issueDate'), _application!.createdAt.toString().split(' ')[0]),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // License Details (If issued)
            if (_application!.license != null)
              Card(
                color: AppTheme.primaryGreen.withOpacity(0.05),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(loc.translate('licenseDetails'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primaryGreen)),
                          StatusBadge(status: _application!.license!.status),
                        ],
                      ),
                      const Divider(),
                      _infoRow(loc.translate('licenseNumber'), _application!.license!.licenseNumber),
                      _infoRow(loc.translate('issueDate'), _application!.license!.issueDate),
                      _infoRow(loc.translate('expiryDate'), _application!.license!.expiryDate),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _openFile(_application!.license!.pdfUrl),
                          icon: const Icon(Icons.picture_as_pdf),
                          label: Text(loc.translate('downloadLicense')),
                          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryGreen),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 16),
            // Documents
            if (_application!.documents.isNotEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(loc.translate('documents'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const Divider(),
                      ..._application!.documents.map((doc) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            const Icon(Icons.description, size: 20, color: Colors.blueGrey),
                            const SizedBox(width: 8),
                            Expanded(child: Text(doc.documentType)),
                            TextButton(
                              onPressed: () => _openFile(doc.fileUrl),
                              child: const Text('View'),
                            ),
                          ],
                        ),
                      )).toList(),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 140, child: Text(label, style: TextStyle(color: Colors.grey.shade600))),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  Future<void> _openFile(String fileName) async {
    final url = Uri.parse('${AppConfig.apiBaseUrl}/files/$fileName');
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not launch $url')));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error opening file: $e')));
      }
    }
  }
}
