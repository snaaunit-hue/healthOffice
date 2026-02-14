import 'package:flutter/material.dart';
import '../../core/localization/app_localizations.dart';
import '../../widgets/public_scaffold.dart';

class NewsScreen extends StatelessWidget {
  const NewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return PublicScaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.newspaper, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(loc.translate('news'), style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text(loc.translate('noData'), style: const TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}
