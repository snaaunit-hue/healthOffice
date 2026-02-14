import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'core/config/app_config.dart';
import 'core/localization/app_localizations.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/locale_provider.dart';
import 'core/providers/theme_provider.dart';
import 'core/services/api_service.dart';
import 'core/theme/app_theme.dart';
import 'router/app_router.dart';

import 'core/providers/notification_provider.dart';
import 'core/services/notification_service.dart';
// ... other imports

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final apiService = ApiService();
  final notificationService = NotificationService(apiService);
  final authProvider = AuthProvider(apiService: apiService);
  final notificationProvider = NotificationProvider(service: notificationService);
  final localeProvider = LocaleProvider();
  final themeProvider = ThemeProvider();

  await Future.wait([
    authProvider.init(),
    localeProvider.init(),
    themeProvider.init(),
  ]);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider.value(value: localeProvider),
        ChangeNotifierProvider.value(value: themeProvider),
        ChangeNotifierProvider.value(value: notificationProvider),
        Provider.value(value: apiService),
        Provider.value(value: notificationService),
      ],
      child: const HealthOfficeApp(),
    ),
  );
}

class HealthOfficeApp extends StatelessWidget {
  const HealthOfficeApp({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final locale = context.watch<LocaleProvider>();
    final theme = context.watch<ThemeProvider>();
    final router = createRouter(auth);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: locale.isArabic ? AppConfig.appNameAr : AppConfig.appNameEn,
      locale: locale.locale,
      supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: AppTheme.lightTheme(locale.locale.languageCode),
      darkTheme: AppTheme.darkTheme(locale.locale.languageCode),
      themeMode: theme.themeMode,
      routerConfig: router,
    );
  }
}
