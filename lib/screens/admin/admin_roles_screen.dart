import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers/auth_provider.dart';

class AdminRolesScreen extends StatefulWidget {
  const AdminRolesScreen({super.key});

  @override
  State<AdminRolesScreen> createState() => _AdminRolesScreenState();
}

class _AdminRolesScreenState extends State<AdminRolesScreen> {
  List<dynamic> _roles = [];
  List<dynamic> _permissions = [];
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
      final api = context.read<AuthProvider>().apiService;
      final roles = await api.get('/admin/roles');
      final permissions = await api.get('/admin/permissions');
      if (mounted) {
        setState(() {
          _roles = roles is List ? roles : [];
          _permissions = permissions is List ? permissions : [];
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('الأدوار والصلاحيات'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.canPop() ? context.pop() : context.go('/admin'),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_error!, textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton(onPressed: _load, child: Text(loc.translate('retry'))),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'الأدوار (الموظفين)',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        ..._roles.map<Widget>((r) {
                          final codes = (r['permissionCodes'] as List?)?.cast<String>() ?? [];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ExpansionTile(
                              leading: const Icon(Icons.badge, color: AppTheme.primaryGreen),
                              title: Text(r['nameAr'] ?? r['code'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600)),
                              subtitle: Text(r['code'] ?? '', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                  child: Wrap(
                                    spacing: 6,
                                    runSpacing: 6,
                                    children: codes.map<Widget>((c) => Chip(
                                      label: Text(c, style: const TextStyle(fontSize: 11)),
                                      backgroundColor: AppTheme.accentLight,
                                    )).toList(),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                        const SizedBox(height: 24),
                        Text(
                          'الصلاحيات المتاحة في النظام',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Card(
                          child: ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _permissions.length,
                            separatorBuilder: (_, __) => const Divider(height: 1),
                            itemBuilder: (context, i) {
                              final p = _permissions[i];
                              return ListTile(
                                leading: const Icon(Icons.security, color: AppTheme.infoBlu, size: 20),
                                title: Text(p['descriptionAr'] ?? p['code'] ?? ''),
                                subtitle: Text(p['code'] ?? '', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}
