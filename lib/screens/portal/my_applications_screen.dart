import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/status_badge.dart';
import '../../core/services/api_service.dart';
import '../../core/services/application_service.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/models/application_model.dart';

class MyApplicationsScreen extends StatefulWidget {
  const MyApplicationsScreen({super.key});

  @override
  State<MyApplicationsScreen> createState() => _MyApplicationsScreenState();
}

class _MyApplicationsScreenState extends State<MyApplicationsScreen> {
  List<Application> _applications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchApplications();
  }

  Future<void> _fetchApplications() async {
    setState(() => _isLoading = true);
    try {
      final auth = context.read<AuthProvider>();
      final api = context.read<ApiService>();
      final service = ApplicationService(api);
      
      final list = await service.getMyApplications(auth.facilityId!);
      setState(() {
        _applications = list;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
        setState(() => _isLoading = false);
      }
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
          onPressed: () => context.canPop() ? context.pop() : context.go('/portal'),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchApplications),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/portal/applications/new'),
        icon: const Icon(Icons.add),
        label: Text(loc.translate('newApplication')),
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
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
                          child: const Icon(Icons.description, color: AppTheme.primaryGreen),
                        ),
                        title: Text(app.applicationNumber, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text('${loc.translate('licenseType')}: ${app.licenseType}'),
                            const SizedBox(height: 4),
                            Text(app.createdAt.toString().split(' ')[0], style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                          ],
                        ),
                        trailing: StatusBadge(status: app.status),
                        onTap: () => context.push('/portal/applications/${app.id}'),
                      ),
                    );
                  },
                ),
    );
  }
}
