import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/services/api_service.dart';
import '../../core/services/payment_service.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import 'package:provider/provider.dart';

class AdminPaymentsScreen extends StatefulWidget {
  const AdminPaymentsScreen({super.key});

  @override
  State<AdminPaymentsScreen> createState() => _AdminPaymentsScreenState();
}

class _AdminPaymentsScreenState extends State<AdminPaymentsScreen> {
  bool _isLoading = true;
  List<dynamic> _payments = [];

  @override
  void initState() {
    super.initState();
    _fetchPayments();
  }

  Future<void> _fetchPayments() async {
    setState(() => _isLoading = true);
    try {
      final api = context.read<ApiService>();
      final response = await api.get('/admin/payments');
      setState(() {
        _payments = response['content'] ?? [];
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
        title: Text(loc.translate('payments')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.canPop() ? context.pop() : context.go('/admin'),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _payments.isEmpty
              ? Center(child: Text(loc.translate('noData')))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _payments.length,
                  itemBuilder: (context, index) {
                    final p = _payments[index];
                    final isPending = p['status'] == 'PENDING';
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isPending ? Colors.orange.shade50 : Colors.green.shade50,
                          child: Icon(Icons.payment, color: isPending ? Colors.orange : Colors.green),
                        ),
                        title: Text('${p['applicationNumber']}'),
                        subtitle: Text('${p['amount']} YR - ${p['paymentReference']}'),
                        trailing: isPending 
                          ? TextButton(
                              onPressed: () => _confirmPayment(p['paymentReference']),
                              child: Text(loc.translate('confirmPayment')),
                            )
                          : Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: Colors.green.shade100, borderRadius: BorderRadius.circular(4)),
                              child: Text('PAID', style: TextStyle(color: Colors.green.shade800, fontSize: 10, fontWeight: FontWeight.bold)),
                            ),
                      ),
                    );
                  },
                ),
    );
  }

  Future<void> _confirmPayment(String ref) async {
    try {
      final api = context.read<ApiService>();
      final service = PaymentService(api);
      await service.confirmPayment(ref, 'OFFLINE_CASH', 'MANUAL-ADMIN');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment Confirmed')));
      _fetchPayments();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }
}
