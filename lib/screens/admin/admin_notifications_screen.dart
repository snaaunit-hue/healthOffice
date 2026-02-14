import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/notification_provider.dart';
import '../../core/providers/locale_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/localization/app_localizations.dart';

class AdminNotificationsScreen extends StatefulWidget {
  const AdminNotificationsScreen({super.key});

  @override
  State<AdminNotificationsScreen> createState() => _AdminNotificationsScreenState();
}

class _AdminNotificationsScreenState extends State<AdminNotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      context.read<NotificationProvider>().fetchNotifications(auth.actorId!);
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final locale = context.watch<LocaleProvider>();
    final notifProvider = context.watch<NotificationProvider>();
    final auth = context.read<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate('notifications')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/admin'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => notifProvider.fetchNotifications(auth.actorId!),
          ),
        ],
      ),
      body: notifProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : notifProvider.notifications.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.notifications_off_outlined, size: 64, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text(loc.translate('noNotifications'), style: TextStyle(color: Colors.grey.shade600)),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: notifProvider.notifications.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final n = notifProvider.notifications[index];
                    return Card(
                      elevation: n.read ? 1 : 4,
                      color: n.read ? Colors.white : Colors.blue.shade50,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: n.read ? Colors.grey.shade200 : Colors.blue.shade200,
                          width: 1,
                        ),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _getTypeColor(n.type).withOpacity(0.1),
                          child: Icon(_getTypeIcon(n.type), color: _getTypeColor(n.type)),
                        ),
                        title: Text(
                          locale.isArabic ? n.titleAr : n.titleEn,
                          style: TextStyle(
                            fontWeight: n.read ? FontWeight.normal : FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(locale.isArabic ? n.bodyAr : n.bodyEn),
                            const SizedBox(height: 8),
                            Text(
                              _formatDate(n.createdAt),
                              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                        onTap: () {
                          if (!n.read) {
                            notifProvider.markAsRead(auth.actorId!, n.id);
                          }
                        },
                      ),
                    );
                  },
                ),
    );
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'SUCCESS': return Icons.check_circle_outline;
      case 'ERROR': return Icons.error_outline;
      case 'WARNING': return Icons.warning_amber_outlined;
      default: return Icons.info_outline;
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'SUCCESS': return AppTheme.successGreen;
      case 'ERROR': return AppTheme.errorRed;
      case 'WARNING': return AppTheme.warningOrange;
      default: return AppTheme.infoBlu;
    }
  }

  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
  }
}
