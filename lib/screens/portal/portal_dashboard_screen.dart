import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/locale_provider.dart';
import '../../core/providers/theme_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/models/facility_model.dart';
import '../../core/services/api_service.dart';
import '../../core/services/facility_service.dart';

class PortalDashboardScreen extends StatefulWidget {
  const PortalDashboardScreen({super.key});

  @override
  State<PortalDashboardScreen> createState() => _PortalDashboardScreenState();
}

class _PortalDashboardScreenState extends State<PortalDashboardScreen> {
  List<Facility> _facilities = [];
  bool _facilitiesLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFacilities();
  }

  Future<void> _loadFacilities() async {
    final auth = context.read<AuthProvider>();
    if (auth.actorId == null) {
      setState(() => _facilitiesLoading = false);
      return;
    }
    setState(() => _facilitiesLoading = true);
    try {
      final api = context.read<ApiService>();
      final service = FacilityService(api);
      final list = await service.getMyFacilities(auth.actorId!);
      if (mounted) setState(() {
        _facilities = list;
        _facilitiesLoading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _facilitiesLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final auth = context.watch<AuthProvider>();
    final locale = context.watch<LocaleProvider>();
    final theme = context.watch<ThemeProvider>();

    final menuItems = [
      {'icon': Icons.description, 'key': 'applications', 'path': '/portal/applications'},
      {'icon': Icons.add_circle, 'key': 'newApplication', 'path': '/portal/applications/new'},
      {'icon': Icons.track_changes, 'key': 'trackApplication', 'path': '/portal/applications'},
      {'icon': Icons.notifications, 'key': 'notifications', 'path': '/portal'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate('dashboard')),
        actions: [
          IconButton(
            icon: Text(locale.isArabic ? 'EN' : 'ع', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            onPressed: () => locale.toggleLocale(),
          ),
          IconButton(
            icon: Icon(theme.isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => theme.toggleTheme(),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: loc.translate('logout'),
            onPressed: () async {
              await auth.logout();
              if (context.mounted) context.go('/');
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome card
            Card(
              color: AppTheme.primaryGreen,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.white24,
                      child: Icon(Icons.person, color: Colors.white, size: 32),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${loc.translate('welcomeMessage')}',
                            style: const TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            auth.fullName,
                            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (_facilities.isNotEmpty) ...[
              Text(loc.translate('myFacilities'), style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              _facilitiesLoading
                  ? const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()))
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _facilities.length,
                      itemBuilder: (context, i) {
                        final f = _facilities[i];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: const Icon(Icons.business, color: AppTheme.primaryGreen),
                            title: Text(f.nameAr),
                            subtitle: Text(f.district ?? f.operationalStatus ?? ''),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => context.push('/portal/facilities/${f.id}'),
                          ),
                        );
                      },
                    ),
              const SizedBox(height: 24),
            ],
            Text(loc.translate('services'), style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: MediaQuery.of(context).size.width > 800 ? 4 : 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: menuItems.map((item) => Card(
                elevation: 4,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => context.push(item['path'] as String),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 56, height: 56,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryGreen.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(item['icon'] as IconData, color: AppTheme.primaryGreen, size: 28),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        loc.translate(item['key'] as String),
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
