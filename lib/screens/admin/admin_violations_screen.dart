import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/services/api_service.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import 'package:provider/provider.dart';

class AdminViolationsScreen extends StatefulWidget {
  const AdminViolationsScreen({super.key});

  @override
  State<AdminViolationsScreen> createState() => _AdminViolationsScreenState();
}

class _AdminViolationsScreenState extends State<AdminViolationsScreen> {
  bool _isLoading = true;
  List<dynamic> _violations = [];

  @override
  void initState() {
    super.initState();
    _fetchViolations();
  }

  Future<void> _fetchViolations() async {
    setState(() => _isLoading = true);
    try {
      final api = context.read<ApiService>();
      final response = await api.get('/admin/violations');
      setState(() {
        _violations = response['content'] ?? [];
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate('violations')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.canPop() ? context.pop() : context.go('/admin'),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _violations.isEmpty
              ? Center(child: Text(loc.translate('noData')))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _violations.length,
                  itemBuilder: (context, index) {
                    final v = _violations[index];
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.red.shade50,
                          child: Icon(Icons.gavel, color: Colors.red.shade800),
                        ),
                        title: Text(v['facilityNameAr'] ?? ''),
                        subtitle: Text(v['description'] ?? ''),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                             Text(v['severity'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10)),
                             Icon(v['isActive'] ? Icons.warning : Icons.check_circle, color: v['isActive'] ? Colors.orange : Colors.green, size: 16),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
