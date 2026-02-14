import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/api_service.dart';
import '../../core/services/application_service.dart';
import '../../core/models/application_model.dart';
import '../../widgets/status_badge.dart';

class AdminApplicationsScreen extends StatefulWidget {
  const AdminApplicationsScreen({super.key});

  @override
  State<AdminApplicationsScreen> createState() => _AdminApplicationsScreenState();
}

class _AdminApplicationsScreenState extends State<AdminApplicationsScreen> {
  bool _isLoading = true;
  List<Application> _applications = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchApplications();
  }

  Future<void> _fetchApplications() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final api = context.read<ApiService>();
      final service = ApplicationService(api);
      final list = await service.getAll();
      setState(() {
        _applications = list;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate('applications')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.canPop() ? context.pop() : context.go('/admin'),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchApplications),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text('Error: $_errorMessage'))
              : _applications.isEmpty
                  ? Center(child: Text(loc.translate('noData')))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _applications.length,
                      itemBuilder: (context, index) {
                        final app = _applications[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            leading: CircleAvatar(
                              backgroundColor: AppTheme.primaryGreen.withOpacity(0.1),
                              child: Text('${app.id}', style: const TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.bold)),
                            ),
                            title: Text(app.applicationNumber, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(app.facilityNameAr),
                                const SizedBox(height: 4),
                                Text(app.createdAt.toString().split(' ')[0], style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                              ],
                            ),
                            trailing: StatusBadge(status: app.status),
                            onTap: () => context.push('/admin/applications/${app.id}'),
                          ),
                        );
                      },
                    ),
    );
  }
}
