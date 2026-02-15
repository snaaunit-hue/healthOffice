import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../core/models/facility_model.dart';
import '../../core/services/api_service.dart';
import '../../core/services/admin_facility_service.dart';
import '../../core/providers/auth_provider.dart';

class AdminFacilitiesScreen extends StatefulWidget {
  const AdminFacilitiesScreen({super.key});

  @override
  State<AdminFacilitiesScreen> createState() => _AdminFacilitiesScreenState();
}

class _AdminFacilitiesScreenState extends State<AdminFacilitiesScreen> {
  List<Facility> _facilities = [];
  bool _isLoading = true;
  String? _error;
  String? _filterType;
  String? _filterStatus;

  final _statuses = ['ACTIVE', 'CLOSED', 'SUSPENDED', 'UNDER_REVIEW'];
  final _statusLabels = {'ACTIVE': 'نشط', 'CLOSED': 'مغلق', 'SUSPENDED': 'موقوف', 'UNDER_REVIEW': 'قيد المراجعة'};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final api = context.read<ApiService>();
      final service = AdminFacilityService(api);
      final list = await service.getFacilities(
        facilityType: _filterType,
        operationalStatus: _filterStatus,
      );
      if (mounted) {
        setState(() {
          _facilities = list;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _changeStatus(Facility f) async {
    final auth = context.read<AuthProvider>();
    if (auth.actorId == null) return;
    final selected = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تغيير الحالة التشغيلية'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _statuses.map((s) => ListTile(
            title: Text(_statusLabels[s] ?? s),
            onTap: () => Navigator.of(ctx).pop(s),
          )).toList(),
        ),
      ),
    );
    if (selected == null || !mounted) return;
    try {
      final api = context.read<ApiService>();
      final service = AdminFacilityService(api);
      await service.updateOperationalStatus(f.id!, selected, auth.actorId!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم تحديث الحالة'), backgroundColor: AppTheme.successGreen),
        );
        _load();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ: $e'), backgroundColor: AppTheme.errorRed),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate('facilities')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.canPop() ? context.pop() : context.go('/admin'),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ],
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                FilterChip(
                  label: const Text('الكل'),
                  selected: _filterStatus == null,
                  onSelected: (_) {
                    setState(() => _filterStatus = null);
                    _load();
                  },
                ),
                ..._statuses.map((s) => FilterChip(
                  label: Text(_statusLabels[s] ?? s),
                  selected: _filterStatus == s,
                  onSelected: (_) {
                    setState(() => _filterStatus = s);
                    _load();
                  },
                )),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(_error!, textAlign: TextAlign.center),
                          const SizedBox(height: 16),
                          ElevatedButton(onPressed: _load, child: Text(loc.translate('retry'))),
                        ],
                      ))
                    : _facilities.isEmpty
                        ? Center(child: Text(loc.translate('noData')))
                        : RefreshIndicator(
                            onRefresh: _load,
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _facilities.length,
                              itemBuilder: (context, i) {
                                final f = _facilities[i];
                                final status = f.operationalStatus ?? 'ACTIVE';
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  child: ListTile(
                                    leading: const Icon(Icons.business, color: AppTheme.primaryGreen),
                                    title: Text(f.nameAr),
                                    subtitle: Text('${f.district ?? ''} • ${_statusLabels[status] ?? status}'),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.edit, color: AppTheme.primaryGreen),
                                      tooltip: 'تغيير الحالة التشغيلية',
                                      onPressed: () => _changeStatus(f),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}
