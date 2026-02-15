import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../core/models/facility_model.dart';
import '../../core/services/api_service.dart';
import '../../core/services/facility_service.dart';

class FacilityProfileScreen extends StatefulWidget {
  final int facilityId;

  const FacilityProfileScreen({super.key, required this.facilityId});

  @override
  State<FacilityProfileScreen> createState() => _FacilityProfileScreenState();
}

class _FacilityProfileScreenState extends State<FacilityProfileScreen> {
  FacilityProfile? _profile;
  bool _isLoading = true;
  String? _error;

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
      final service = FacilityService(api);
      final profile = await service.getProfile(widget.facilityId);
      if (mounted) {
        setState(() {
          _profile = profile;
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

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(loc.translate('facilityProfile')),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.canPop() ? context.pop() : context.go('/portal'),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null || _profile == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(loc.translate('facilityProfile')),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.canPop() ? context.pop() : context.go('/portal'),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_error ?? loc.translate('noData'), textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _load, child: Text(loc.translate('retry'))),
            ],
          ),
        ),
      );
    }

    final f = _profile!.facility;
    final status = f.operationalStatus ?? 'ACTIVE';

    return Scaffold(
      appBar: AppBar(
        title: Text(f.nameAr),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.canPop() ? context.pop() : context.go('/portal'),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.business, color: AppTheme.primaryGreen, size: 28),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(f.nameAr, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                                if (f.nameEn != null && f.nameEn!.isNotEmpty)
                                  Text(f.nameEn!, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                              ],
                            ),
                          ),
                          _statusChip(status, loc),
                        ],
                      ),
                      const Divider(height: 24),
                      _row(loc.translate('facilityType'), _facilityTypeLabel(f.facilityType, loc)),
                      _row(loc.translate('district'), f.district ?? '—'),
                      _row('المحافظة', f.governorate ?? '—'),
                      _row('القطاع', f.sector ?? '—'),
                      if (f.specialty != null && f.specialty!.isNotEmpty) _row('التخصص / الخدمة', f.specialty!),
                      _row(loc.translate('area'), f.area ?? '—'),
                      _row(loc.translate('street'), f.street ?? '—'),
                    ],
                  ),
                ),
              ),
              if (_profile!.currentLicenseNumber != null) ...[
                const SizedBox(height: 16),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.card_membership, color: AppTheme.primaryGreen),
                    title: Text(loc.translate('licenseStatus')),
                    subtitle: Text('${_profile!.currentLicenseNumber} — ${_profile!.currentLicenseStatus ?? ''}\n${loc.translate('licenseExpiry')}: ${_profile!.licenseExpiryDate ?? '—'}'),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.description, color: AppTheme.infoBlu),
                      title: Text(loc.translate('applications')),
                      subtitle: Text('${_profile!.applicationsCount}'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.push('/portal/applications'),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.search, color: AppTheme.warningOrange),
                      title: Text(loc.translate('inspections')),
                      subtitle: Text('${_profile!.inspectionsCount}'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.push('/portal/applications'),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.card_membership, color: AppTheme.successGreen),
                      title: Text(loc.translate('licenses')),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.push('/portal/applications'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => context.push('/portal/applications/new?facilityId=${f.id}'),
                icon: const Icon(Icons.add_circle_outline),
                label: Text(loc.translate('newApplication')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statusChip(String status, AppLocalizations loc) {
    Color color;
    String label;
    switch (status) {
      case 'ACTIVE':
        color = AppTheme.successGreen;
        label = 'نشط';
        break;
      case 'CLOSED':
        color = Colors.grey;
        label = 'مغلق';
        break;
      case 'SUSPENDED':
        color = AppTheme.warningOrange;
        label = 'موقوف';
        break;
      case 'UNDER_REVIEW':
        color = AppTheme.infoBlu;
        label = 'قيد المراجعة';
        break;
      default:
        color = Colors.grey;
        label = status;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Text(label, style: TextStyle(fontWeight: FontWeight.w600, color: color, fontSize: 12)),
    );
  }

  String _facilityTypeLabel(String type, AppLocalizations loc) {
    const map = {
      'HOSPITAL': 'hospital',
      'CENTER': 'medicalCenter',
      'CLINIC': 'clinic',
      'LABORATORY': 'laboratory',
      'PHARMACY': 'pharmacy',
    };
    return loc.translate(map[type] ?? type);
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
          ),
          Expanded(child: Text(value.isNotEmpty ? value : '—', style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}
