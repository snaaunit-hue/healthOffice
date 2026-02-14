import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/api_service.dart';
import '../../core/services/inspection_service.dart';
import '../../widgets/status_badge.dart';

class AdminInspectionsScreen extends StatefulWidget {
  const AdminInspectionsScreen({super.key});

  @override
  State<AdminInspectionsScreen> createState() => _AdminInspectionsScreenState();
}

class _AdminInspectionsScreenState extends State<AdminInspectionsScreen> {
  bool _isLoading = true;
  List<dynamic> _inspections = [];

  @override
  void initState() {
    super.initState();
    _fetchInspections();
  }

  Future<void> _fetchInspections() async {
    setState(() => _isLoading = true);
    try {
      final api = context.read<ApiService>();
      final service = InspectionService(api);
      final list = await service.getScheduledInspections();
      setState(() {
        _inspections = list;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate('inspections')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.canPop() ? context.pop() : context.go('/admin'),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchInspections),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _inspections.isEmpty
              ? Center(child: Text(loc.translate('noData')))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _inspections.length,
                  itemBuilder: (context, index) {
                    final insp = _inspections[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: CircleAvatar(
                          backgroundColor: AppTheme.primaryGreen.withOpacity(0.1),
                          child: const Icon(Icons.search, color: AppTheme.primaryGreen),
                        ),
                        title: Text(insp.applicationNumber, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(insp.scheduledDate.toString().split(' ')[0]),
                            const SizedBox(height: 4),
                          ],
                        ),
                        trailing: StatusBadge(status: insp.status),
                        onTap: () => context.push('/admin/applications/${insp.applicationId}'),
                      ),
                    );
                  },
                ),
    );
  }
}
