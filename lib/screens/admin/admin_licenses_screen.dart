import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/services/api_service.dart';
import '../../core/localization/app_localizations.dart';
import 'package:provider/provider.dart';

class AdminLicensesScreen extends StatefulWidget {
  const AdminLicensesScreen({super.key});

  @override
  State<AdminLicensesScreen> createState() => _AdminLicensesScreenState();
}

class _AdminLicensesScreenState extends State<AdminLicensesScreen> {
  bool _isLoading = true;
  List<dynamic> _licenses = [];

  @override
  void initState() {
    super.initState();
    _fetchLicenses();
  }

  Future<void> _fetchLicenses() async {
    setState(() => _isLoading = true);
    try {
      final api = context.read<ApiService>();
      final response = await api.get('/admin/licenses');
      setState(() {
        _licenses = response['content'] ?? [];
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate('licenses')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.canPop() ? context.pop() : context.go('/admin'),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _licenses.isEmpty
              ? Center(child: Text(loc.translate('noData')))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _licenses.length,
                  itemBuilder: (context, index) {
                    final l = _licenses[index];
                    return Card(
                      child: ListTile(
                        leading: const CircleAvatar(child: Icon(Icons.card_membership)),
                        title: Text(l['facilityNameAr'] ?? ''),
                        subtitle: Text('${l['licenseNumber']} - ${l['expiryDate']}'),
                        trailing: const Icon(Icons.chevron_right),
                      ),
                    );
                  },
                ),
    );
  }
}
