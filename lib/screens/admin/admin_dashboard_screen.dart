import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/models/dashboard_stats_model.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/locale_provider.dart';
import '../../core/providers/theme_provider.dart';
import '../../core/providers/notification_provider.dart';
import '../../core/services/dashboard_service.dart';
import '../../core/theme/app_theme.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  DashboardStats? _stats;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  Future<void> _fetchStats() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final api = context.read<AuthProvider>().apiService;
      final service = DashboardService(api);
      final stats = await service.getAdminStats();
      if (mounted) {
        final auth = context.read<AuthProvider>();
        context.read<NotificationProvider>().refreshUnreadCount(auth.actorId!);
        
        setState(() {
          _stats = stats;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final auth = context.watch<AuthProvider>();
    final locale = context.watch<LocaleProvider>();
    final theme = context.watch<ThemeProvider>();
    final isWide = MediaQuery.of(context).size.width > 900;

    final menuItems = [
      {'icon': Icons.dashboard, 'key': 'dashboard', 'path': '/admin'},
      {'icon': Icons.business, 'key': 'facilities', 'path': '/admin/facilities'},
      {'icon': Icons.description, 'key': 'applications', 'path': '/admin/applications'},
      {'icon': Icons.search, 'key': 'inspections', 'path': '/admin/inspections'},
      {'icon': Icons.payment, 'key': 'payments', 'path': '/admin/payments'},
      {'icon': Icons.gavel, 'key': 'violations', 'path': '/admin/violations'},
      {'icon': Icons.card_membership, 'key': 'licenses', 'path': '/admin/licenses'},
      {'icon': Icons.notifications, 'key': 'notifications', 'path': '/admin/notifications'},
      {'icon': Icons.people, 'key': 'employees', 'path': '/admin/employees'},
      {'icon': Icons.badge, 'key': 'rolesPermissions', 'path': '/admin/roles'},
      {'icon': Icons.person_add_alt_1, 'key': 'users', 'path': '/admin/users'},
      {'icon': Icons.web, 'key': 'media', 'path': '/admin/media'},
      {'icon': Icons.settings, 'key': 'settings', 'path': '/admin/settings'},
    ];



    // Build the content widget based on state
    Widget content;
    if (_isLoading) {
      content = const Center(child: CircularProgressIndicator());
    } else if (_errorMessage != null) {
      content = Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Session expired or connection error', style: TextStyle(color: AppTheme.errorRed, fontSize: 16)),
            const SizedBox(height: 8),
            Text('Details: $_errorMessage', style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _fetchStats, child: const Text('Retry')),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () async {
                 await auth.logout();
                 if (context.mounted) context.go('/');
              }, 
              child: const Text('Force Logout')
            ),
          ],
        ),
      );
    } else {
      final stats = _stats!;
      content = RefreshIndicator(
        onRefresh: _fetchStats,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    loc.translate('dashboard'),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchStats),
                ],
              ),
              const SizedBox(height: 24),
              // Stats cards
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  _statCard(context, loc.translate('totalApplications'), stats.totalApplications.toString(), Icons.description, AppTheme.infoBlu, 0),
                  _statCard(context, loc.translate('pendingReview'), stats.pendingReview.toString(), Icons.rate_review, AppTheme.warningOrange, 1),
                  _statCard(context, loc.translate('activeLicenses'), stats.activeLicenses.toString(), Icons.card_membership, AppTheme.successGreen, 2),
                  _statCard(context, loc.translate('totalFacilities'), stats.totalFacilities.toString(), Icons.business, AppTheme.primaryGreen, 3),
                  _statCard(context, loc.translate('expiringSoon'), stats.expiringLicenses.toString(), Icons.timer, Colors.deepOrange, 4),
                  _statCard(context, loc.translate('activeViolations'), stats.activeViolations.toString(), Icons.gavel, AppTheme.errorRed, 5),
                ],
              ),
              const SizedBox(height: 32),
              // Quick access
              Text(loc.translate('services'), style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              GridView.count(
                crossAxisCount: isWide ? 4 : 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: menuItems.skip(1).map((item) => Card(
                  elevation: 2,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => context.push(item['path'] as String),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(item['icon'] as IconData, size: 32, color: AppTheme.primaryGreen),
                        const SizedBox(height: 8),
                        Text(loc.translate(item['key'] as String), textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
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

    final notifications = context.watch<NotificationProvider>();

    return Scaffold(
      body: Row(
        children: [
          // Side navigation (ALWAYS VISIBLE)
          if (isWide)
            NavigationRail(
              extended: true,
              backgroundColor: AppTheme.primaryDark,
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  children: [
                    Container(
                      width: 48, height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.1),
                        border: Border.all(color: AppTheme.accentGold, width: 2),
                      ),
                      child: ClipOval(
                        child: Transform.scale(
                          scale: 1.2,
                          child: Image.asset('assets/images/app_icon.png', fit: BoxFit.cover),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(loc.translate('dashboard'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 4),
                    Text(auth.fullName, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 11)),
                    const SizedBox(height: 16),
                    const Divider(color: Colors.white24, indent: 16, endIndent: 16),
                  ],
                ),
              ),
              trailing: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  children: [
                    IconButton(
                      icon: Text(locale.isArabic ? 'EN' : 'ع', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      onPressed: () => locale.toggleLocale(),
                    ),
                    IconButton(
                      icon: Icon(theme.isDark ? Icons.light_mode : Icons.dark_mode, color: Colors.white70),
                      onPressed: () => theme.toggleTheme(),
                    ),
                    IconButton(
                      icon: const Icon(Icons.logout, color: Colors.white70),
                      onPressed: () async {
                        await auth.logout();
                        if (context.mounted) context.go('/');
                      },
                    ),
                  ],
                ),
              ),
              selectedIndex: 0,
              onDestinationSelected: (i) => context.go(menuItems[i]['path'] as String),
              destinations: menuItems.map((item) {
                final isNotif = item['key'] == 'notifications';
                return NavigationRailDestination(
                  icon: Badge(
                    label: isNotif && notifications.unreadCount > 0 
                        ? Text(notifications.unreadCount.toString()) 
                        : null,
                    isLabelVisible: isNotif && notifications.unreadCount > 0,
                    child: Icon(item['icon'] as IconData, color: Colors.white70),
                  ),
                  selectedIcon: Badge(
                    label: isNotif && notifications.unreadCount > 0 
                        ? Text(notifications.unreadCount.toString()) 
                        : null,
                    isLabelVisible: isNotif && notifications.unreadCount > 0,
                    child: Icon(item['icon'] as IconData, color: AppTheme.accentGold),
                  ),
                  label: Text(loc.translate(item['key'] as String), style: const TextStyle(color: Colors.white)),
                );
              }).toList(),
            ),
          // Main content
          Expanded(
            child: Column(
              children: [
                // Top bar (mobile)
                if (!isWide)
                  AppBar(
                    title: Text(loc.translate('dashboard')),
                    actions: [
                      IconButton(icon: const Icon(Icons.logout), onPressed: () async {
                        await auth.logout();
                        if (context.mounted) context.go('/');
                      }),
                    ],
                  ),
                // Dashboard content (or loading/error)
                Expanded(child: content),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard(BuildContext context, String label, String value, IconData icon, Color color, int index) {
    final isWide = MediaQuery.of(context).size.width > 900;
    return SizedBox(
      width: isWide ? 220 : (MediaQuery.of(context).size.width - 72) / 2,
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: color, size: 24),
                  ),
                  const Spacer(),
                  Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color)),
                ],
              ),
              const SizedBox(height: 12),
              Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
            ],
          ),
        ),
      ).animate().fadeIn(delay: (200 + index * 100).ms).slideY(begin: 0.15),
    );
  }
}
