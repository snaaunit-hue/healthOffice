import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/theme_provider.dart';
import '../../core/providers/locale_provider.dart';
import '../../core/theme/app_theme.dart';

class AdminSettingsScreen extends StatelessWidget {
  const AdminSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = context.watch<ThemeProvider>();
    final locale = context.watch<LocaleProvider>();
    final auth = context.read<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate('settings')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/admin'),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader(loc.translate('generalSettings')),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.language, color: AppTheme.primaryGreen),
                  title: Text(loc.translate('language')),
                  subtitle: Text(locale.isArabic ? 'العربية' : 'English'),
                  trailing: Switch(
                    value: locale.isArabic,
                    onChanged: (val) => locale.toggleLocale(),
                    activeColor: AppTheme.primaryGreen,
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(theme.isDark ? Icons.dark_mode : Icons.light_mode, color: AppTheme.primaryGreen),
                  title: Text(loc.translate('darkMode')),
                  trailing: Switch(
                    value: theme.isDark,
                    onChanged: (val) => theme.toggleTheme(),
                    activeColor: AppTheme.primaryGreen,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader(loc.translate('account')),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.person, color: AppTheme.primaryGreen),
                  title: Text(auth.fullName),
                  subtitle: Text(auth.role),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.logout, color: AppTheme.errorRed),
                  title: Text(loc.translate('logout'), style: const TextStyle(color: AppTheme.errorRed)),
                  onTap: () async {
                    await auth.logout();
                    if (context.mounted) context.go('/');
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          Center(
            child: Text(
              'Version 1.0.0',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8, right: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppTheme.primaryGreen,
        ),
      ),
    );
  }
}
