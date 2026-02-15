import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/locale_provider.dart';
import '../../core/providers/theme_provider.dart';
import '../../core/theme/app_theme.dart';

class PublicScaffold extends StatelessWidget {
  final Widget body;
  final String? title;
  final bool showAppBar;

  const PublicScaffold({
    super.key,
    required this.body,
    this.title,
    this.showAppBar = true,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final locale = context.watch<LocaleProvider>();
    final theme = context.watch<ThemeProvider>();
    final auth = context.watch<AuthProvider>();
    final isWide = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      appBar: showAppBar
          ? AppBar(
              title: Text(title ?? loc.translate('appTitle')),
              leading: context.canPop()
                  ? IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => context.pop(),
                    )
                  : (!isWide
                      ? Builder(
                          builder: (ctx) => IconButton(
                            icon: const Icon(Icons.menu),
                            onPressed: () => Scaffold.of(ctx).openDrawer(),
                          ),
                        )
                      : null),
              automaticallyImplyLeading: false,
              actions: [
                if (isWide) ..._buildNavItems(context, loc),
                _buildLangToggle(context, locale, loc),
                _buildThemeToggle(context, theme, loc),
                const SizedBox(width: 8),
                _buildPortalButton(context, loc, auth),
                const SizedBox(width: 12),
              ],
            )
          : null,
      drawer: isWide ? null : _buildDrawer(context, loc, locale, theme, auth),
      body: body,
    );
  }

  List<Widget> _buildNavItems(BuildContext context, AppLocalizations loc) {
    final items = [
      {'label': loc.translate('home'), 'path': '/'},
      {'label': loc.translate('about'), 'path': '/about'},
      {'label': loc.translate('services'), 'path': '/services'},
      {'label': loc.translate('requirements'), 'path': '/requirements'},
      {'label': loc.translate('news'), 'path': '/news'},
      {'label': loc.translate('contact'), 'path': '/contact'},
    ];

    return items.map((item) {
      final currentPath = GoRouterState.of(context).matchedLocation;
      final isActive = currentPath == item['path'];
      return TextButton(
        onPressed: () {
          if (item['path'] == '/') {
            context.go('/');
          } else {
            context.push(item['path']!);
          }
        },
        style: TextButton.styleFrom(
          foregroundColor: isActive ? AppTheme.accentGold : Colors.white,
        ),
        child: Text(
          item['label']!,
          style: TextStyle(
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            decoration: isActive ? TextDecoration.underline : null,
          ),
        ),
      );
    }).toList();
  }

  Widget _buildLangToggle(
      BuildContext context, LocaleProvider locale, AppLocalizations loc) {
    return IconButton(
      icon: Text(
        locale.isArabic ? 'EN' : 'ع',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
      tooltip: loc.translate('language'),
      onPressed: () => locale.toggleLocale(),
    );
  }

  Widget _buildThemeToggle(
      BuildContext context, ThemeProvider theme, AppLocalizations loc) {
    return IconButton(
      icon: Icon(theme.isDark ? Icons.light_mode : Icons.dark_mode),
      tooltip:
          loc.translate(theme.isDark ? 'lightMode' : 'darkMode'),
      onPressed: () => theme.toggleTheme(),
    );
  }

  Widget _buildPortalButton(
      BuildContext context, AppLocalizations loc, AuthProvider auth) {
    if (auth.isLoggedIn) {
      return ElevatedButton.icon(
        onPressed: () =>
            context.push(auth.isAdmin ? '/admin' : '/portal'),
        icon: const Icon(Icons.dashboard, size: 18),
        label: Text(loc.translate('dashboard')),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.accentGold,
          foregroundColor: Colors.black87,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      );
    }
    return ElevatedButton.icon(
      onPressed: () => context.push('/login'),
      icon: const Icon(Icons.login, size: 18),
      label: Text(loc.translate('portal')),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.accentGold,
        foregroundColor: Colors.black87,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, AppLocalizations loc,
      LocaleProvider locale, ThemeProvider theme, AuthProvider auth) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: AppTheme.primaryGreen),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ClipOval(
                  child: Container(
                    color: Colors.white,
                    child: Transform.scale(
                      scale: 1.2,
                      child: Image.asset(
                        'assets/images/app_icon.png',
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  loc.translate('appTitle'),
                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          _drawerItem(context, Icons.home, loc.translate('home'), '/'),
          _drawerItem(context, Icons.info, loc.translate('about'), '/about'),
          _drawerItem(context, Icons.miscellaneous_services, loc.translate('services'), '/services'),
          _drawerItem(context, Icons.rule, loc.translate('requirements'), '/requirements'),
          _drawerItem(context, Icons.newspaper, loc.translate('news'), '/news'),
          _drawerItem(context, Icons.contact_mail, loc.translate('contact'), '/contact'),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(loc.translate('language')),
            trailing: Text(locale.isArabic ? 'EN' : 'ع'),
            onTap: () {
              locale.toggleLocale();
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(theme.isDark ? Icons.light_mode : Icons.dark_mode),
            title: Text(loc.translate(theme.isDark ? 'lightMode' : 'darkMode')),
            onTap: () {
              theme.toggleTheme();
              Navigator.pop(context);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.login, color: AppTheme.primaryGreen),
            title: Text(
              auth.isLoggedIn ? loc.translate('dashboard') : loc.translate('portal'),
              style: const TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.bold),
            ),
            onTap: () {
              Navigator.pop(context);
              if (auth.isLoggedIn) {
                context.push(auth.isAdmin ? '/admin' : '/portal');
              } else {
                context.push('/login');
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _drawerItem(BuildContext context, IconData icon, String label, String path) {
    final isActive = GoRouterState.of(context).matchedLocation == path;
    return ListTile(
      leading: Icon(icon, color: isActive ? AppTheme.primaryGreen : null),
      title: Text(
        label,
        style: TextStyle(
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          color: isActive ? AppTheme.primaryGreen : null,
        ),
      ),
      selected: isActive,
      onTap: () {
        Navigator.pop(context);
        if (path == '/') {
          context.go('/');
        } else {
          context.push(path);
        }
      },
    );
  }
}
