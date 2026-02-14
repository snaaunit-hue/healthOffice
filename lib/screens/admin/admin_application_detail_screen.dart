import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/config/app_config.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/models/application_model.dart';
import '../../core/models/admin_model.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/services/application_service.dart';
import '../../core/services/inspection_service.dart';
import '../../core/services/payment_service.dart';
import '../../core/theme/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/workflow_tracker.dart';

class AdminApplicationDetailScreen extends StatefulWidget {
  final int applicationId;
  const AdminApplicationDetailScreen({super.key, required this.applicationId});

  @override
  State<AdminApplicationDetailScreen> createState() => _AdminApplicationDetailScreenState();
}

class _AdminApplicationDetailScreenState extends State<AdminApplicationDetailScreen> {
  late ApplicationService _applicationService;
  late InspectionService _inspectionService;
  late PaymentService _paymentService;
  
  Application? _app;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final api = context.read<AuthProvider>().apiService;
    _applicationService = ApplicationService(api);
    _inspectionService = InspectionService(api);
    _paymentService = PaymentService(api);
    _fetchApplication();
  }

  Future<void> _fetchApplication() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final app = await _applicationService.getById(widget.applicationId);
      if (mounted) {
        setState(() {
          _app = app;
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

  Future<void> _advanceWorkflow(String actionName) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Confirm $actionName'),
        content: const Text('Are you sure you want to proceed?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Confirm')),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);
    try {
      final auth = context.read<AuthProvider>();
      await _applicationService.advanceWorkflow(_app!.id, auth.actorId!, notes: '$actionName by admin');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$actionName successful')));
        _fetchApplication();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _scheduleInspection() async {
    List<AdminUser> inspectors = [];
    try {
      inspectors = await _inspectionService.getInspectors();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to load inspectors: $e')));
      return;
    }

    if (!mounted) return;

    int? selectedInspectorId;
    DateTime selectedDate = DateTime.now().add(const Duration(days: 1));

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Schedule Inspection'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(labelText: 'Inspector'),
                items: inspectors.map((i) => DropdownMenuItem(value: i.id, child: Text(i.fullName))).toList(),
                onChanged: (v) => setDialogState(() => selectedInspectorId = v),
              ),
              const SizedBox(height: 16),
              ListTile(
                title: Text('Date: ${selectedDate.toString().split(' ')[0]}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final d = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (d != null) setDialogState(() => selectedDate = d);
                },
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: selectedInspectorId == null ? null : () => Navigator.pop(ctx, 'CONFIRMED'),
              child: const Text('Schedule'),
            ),
          ],
        ),
      ),
    ).then((result) async {
      if (result == 'CONFIRMED' && selectedInspectorId != null) {
        setState(() => _isLoading = true);
        try {
          await _inspectionService.scheduleInspection(_app!.id, selectedInspectorId!, selectedDate);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Inspection scheduled')));
            _fetchApplication();
          }
        } catch (e) {
          if (mounted) {
            setState(() => _isLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
          }
        }
      }
    });
  }

  Future<void> _completeInspection() async {
    try {
      final inspection = await _inspectionService.getActiveForApplication(_app!.id);
      if (!mounted) return;
      
      final result = await context.push('/admin/inspections/${inspection.id}/checklist');
      if (result == true) {
        _fetchApplication();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _approveBlueprint() async {
    setState(() => _isLoading = true);
    try {
       final auth = context.read<AuthProvider>();
       await _applicationService.advanceWorkflow(_app!.id, auth.actorId!, notes: 'Blueprint Approved');
       if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Blueprint Approved')));
         _fetchApplication();
       }
    } catch (e) {
       if (mounted) {
         setState(() => _isLoading = false);
         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
       }
    }
  }

  Future<void> _generatePayment() async {
    setState(() => _isLoading = true);
    try {
      final auth = context.read<AuthProvider>();
      await _paymentService.createPaymentOrder(_app!.id, auth.actorId!);
      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment Order Generated')));
         _fetchApplication();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }
  
  Future<void> _confirmPayment() async {
    setState(() => _isLoading = true);
    try {
      final payments = await _paymentService.getPaymentsByApplication(_app!.id);
      final List pending = payments.where((p) => p['status'] == 'PENDING').toList();
      
      if (!mounted) return;
      setState(() => _isLoading = false);

      if (pending.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No pending payments found')));
        return;
      }

      final refController = TextEditingController(text: pending.first['paymentReference']);
      final channelController = TextEditingController(text: 'BANK_TRANSFER');
      final externalIdController = TextEditingController();

      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(AppLocalizations.of(context)!.translate('confirmPayment')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: refController,
                decoration: InputDecoration(labelText: AppLocalizations.of(context)!.translate('paymentReference')),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: channelController,
                decoration: const InputDecoration(labelText: 'Payment Channel'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: externalIdController,
                decoration: const InputDecoration(labelText: 'External Transaction ID'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, 'CONFIRM'),
              child: const Text('Confirm Payment'),
            ),
          ],
        ),
      ).then((res) async {
        if (res == 'CONFIRM' && refController.text.isNotEmpty) {
          setState(() => _isLoading = true);
          await _paymentService.confirmPayment(
            refController.text,
            channelController.text,
            externalIdController.text,
          );
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment Confirmed')));
            _fetchApplication();
          }
        }
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _rejectApplication() async {
    final reasonController = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reject Application'),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(labelText: 'Rejection Reason', hintText: 'Enter reason...'),
          maxLines: 3,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorRed),
            onPressed: () => Navigator.pop(ctx, reasonController.text),
            child: const Text('Reject'),
          ),
        ],
      ),
    );

    if (reason == null || reason.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      final auth = context.read<AuthProvider>();
      await _applicationService.rejectApplication(_app!.id, auth.actorId!, reason);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Application rejected')));
        _fetchApplication();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
        setState(() => _isLoading = false);
      }
    }
  }

  // ===== License Management Actions =====

  Future<void> _generateLicensePdf() async {
    setState(() => _isLoading = true);
    try {
      final auth = context.read<AuthProvider>();
      final api = auth.apiService;
      final response = await api.post(
        'admin/licenses/generate?applicationId=${_app!.id}&adminId=${auth.actorId}', body: {});
      if (mounted) {
        final pdfUrl = response['pdfUrl'] ?? '';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('License PDF generated: $pdfUrl'),
            backgroundColor: AppTheme.successGreen,
          ),
        );
        _fetchApplication();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _reprintLicense() async {
    if (_app?.license == null) return;
    setState(() => _isLoading = true);
    try {
      final auth = context.read<AuthProvider>();
      final api = auth.apiService;
      await api.post(
        'admin/licenses/${_app!.license!.id}/reprint?adminId=${auth.actorId}', body: {});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('License reprinted'), backgroundColor: AppTheme.successGreen),
        );
        _fetchApplication();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _invalidateLicense() async {
    if (_app?.license == null) return;

    final reasonController = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Invalidate License'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Are you sure you want to revoke this license?', 
                style: TextStyle(color: AppTheme.errorRed)),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(labelText: 'Reason for invalidation'),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorRed),
            onPressed: () => Navigator.pop(ctx, reasonController.text),
            child: const Text('Invalidate'),
          ),
        ],
      ),
    );

    if (reason == null || reason.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      final auth = context.read<AuthProvider>();
      final api = auth.apiService;
      await api.post(
        'admin/licenses/${_app!.license!.id}/invalidate?adminId=${auth.actorId}',
        body: {'reason': reason},
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('License invalidated'), backgroundColor: AppTheme.warningOrange),
        );
        _fetchApplication();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  int _statusToStep(String status) {
    const map = {
      'DRAFT': 0, 'SUBMITTED': 1, 'UNDER_REVIEW': 2, 'BLUEPRINT_REVIEW': 3,
      'INSPECTION_SCHEDULED': 4, 'INSPECTION_COMPLETED': 5, 'COMMITTEE_APPROVED': 6, 
      'PAYMENT_PENDING': 7, 'PAYMENT_COMPLETED': 8, 'LICENSE_ISSUED': 9, 'ARCHIVED': 10,
    };
    return map[status] ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final auth = context.watch<AuthProvider>();
    
    final String role = auth.role;
    final bool isAdmin = role == 'ADMIN';
    final bool isInspector = isAdmin;
    final bool isAccountant = isAdmin;
    final bool isDirector = isAdmin;

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(child: Text('Error loading application: $_errorMessage')),
      );
    }

    final app = _app!;

    return Scaffold(
      appBar: AppBar(
        title: Text(app.applicationNumber),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.canPop() ? context.pop() : context.go('/admin/applications'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchApplication,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Workflow
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(loc.translate('workflowSteps'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const Spacer(),
                        StatusBadge(status: app.status),
                      ],
                    ),
                    const SizedBox(height: 16),
                    WorkflowTracker(currentStep: _statusToStep(app.status)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Facility info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(loc.translate('facilityData'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const Divider(),
                    _infoRow(loc.translate('facilityName'), app.facilityNameAr),
                    _infoRow(loc.translate('facilityType'), app.facilityType),
                    _infoRow(loc.translate('licenseType'), app.licenseType),
                    if (app.supervisorName != null)
                      _infoRow('Supervisor', app.supervisorName!),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // License Card with Management Actions
            if (_app!.license != null)
              Card(
                color: AppTheme.primaryGreen.withOpacity(0.05),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(loc.translate('licenseDetails'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primaryGreen)),
                          StatusBadge(status: _app!.license!.status),
                        ],
                      ),
                      const Divider(),
                      _infoRow(loc.translate('licenseNumber'), _app!.license!.licenseNumber),
                      _infoRow(loc.translate('issueDate'), _app!.license!.issueDate),
                      _infoRow(loc.translate('expiryDate'), _app!.license!.expiryDate),
                      const SizedBox(height: 12),
                      // View License
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _openFile(_app!.license!.pdfUrl),
                          icon: const Icon(Icons.picture_as_pdf),
                          label: const Text('View License Document'),
                          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryGreen),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Admin License Actions
                      if (isDirector) ...[
                        const Divider(),
                        const SizedBox(height: 4),
                        Text('License Management', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.grey.shade700)),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _licenseActionBtn(
                              icon: Icons.refresh,
                              label: loc.translate('reprintLicense'),
                              color: AppTheme.infoBlu,
                              onPressed: _reprintLicense,
                            ),
                            _licenseActionBtn(
                              icon: Icons.cancel_outlined,
                              label: loc.translate('invalidateLicense'),
                              color: AppTheme.errorRed,
                              onPressed: _invalidateLicense,
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 16),
            // Documents
            if (app.documents != null && app.documents!.isNotEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(loc.translate('documents'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const Divider(),
                      ...app.documents!.map((doc) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            const Icon(Icons.description, size: 20, color: Colors.blueGrey),
                            const SizedBox(width: 8),
                            Expanded(child: Text(doc.documentType)),
                            TextButton(
                              onPressed: () => _openFile(doc.fileUrl),
                              child: const Text('View'),
                            ),
                          ],
                        ),
                      )).toList(),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 16),
            // Actions
            if (app.status != 'REJECTED' && app.status != 'ARCHIVED')
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Actions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const Divider(),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                            // REJECT always available for Directors
                            if (isDirector)
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                                child: OutlinedButton.icon(
                                  onPressed: _rejectApplication,
                                  icon: const Icon(Icons.cancel, color: AppTheme.errorRed),
                                  label: Text(loc.translate('reject'), style: const TextStyle(color: AppTheme.errorRed)),
                                  style: OutlinedButton.styleFrom(side: const BorderSide(color: AppTheme.errorRed)),
                                ),
                              ),
                            
                            // DYNAMIC ACTIONS based on Status + Role
                            if (app.status == 'SUBMITTED' && isDirector)
                               ElevatedButton.icon(
                                 onPressed: () => _advanceWorkflow('Start Review'),
                                 icon: const Icon(Icons.start),
                                 label: Text(loc.translate('startReview')),
                               ),
                               
                             if (app.status == 'UNDER_REVIEW' && isDirector)
                                ElevatedButton.icon(
                                  onPressed: _approveBlueprint,
                                  icon: const Icon(Icons.architecture),
                                  label: Text(loc.translate('approveBlueprint')),
                                ),
                                
                             if (app.status == 'BLUEPRINT_REVIEW' && isInspector)
                                ElevatedButton.icon(
                                  onPressed: _scheduleInspection,
                                  icon: const Icon(Icons.calendar_month),
                                  label: Text(loc.translate('scheduleInspection')),
                                ),
                               
                            if (app.status == 'INSPECTION_SCHEDULED' && isInspector)
                               ElevatedButton.icon(
                                 onPressed: _completeInspection,
                                 icon: const Icon(Icons.edit_document),
                                 label: Text(loc.translate('enterInspectionResult')),
                               ),
                               
                            if (app.status == 'INSPECTION_COMPLETED' && isDirector)
                               ElevatedButton.icon(
                                 onPressed: () => _advanceWorkflow('Committee Approval'),
                                 icon: const Icon(Icons.people),
                                 label: Text(loc.translate('committeeApproval')),
                               ),
                               
                            if (app.status == 'COMMITTEE_APPROVED' && isAccountant)
                               ElevatedButton.icon(
                                 onPressed: _generatePayment,
                                 icon: const Icon(Icons.receipt),
                                 label: Text(loc.translate('generatePaymentOrder')),
                               ),
                               
                            if (app.status == 'PAYMENT_PENDING' && isAccountant)
                               ElevatedButton.icon(
                                 onPressed: _confirmPayment,
                                 icon: const Icon(Icons.payment),
                                 label: Text(loc.translate('confirmPayment')),
                               ),
                               
                            if (app.status == 'PAYMENT_COMPLETED' && isDirector)
                               ElevatedButton.icon(
                                 onPressed: () => _advanceWorkflow('Issue License'),
                                 icon: const Icon(Icons.card_membership),
                                 label: Text(loc.translate('issueLicense')),
                               ),

                            // Generate License PDF after issuing
                            if (app.status == 'LICENSE_ISSUED' && isDirector && _app?.license == null)
                               ElevatedButton.icon(
                                 onPressed: _generateLicensePdf,
                                 icon: const Icon(Icons.picture_as_pdf),
                                 label: Text(loc.translate('generateLicensePdf')),
                                 style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryGreen),
                               ),

                            if (app.status == 'LICENSE_ISSUED' && isDirector)
                               ElevatedButton.icon(
                                 onPressed: () => _advanceWorkflow('Archive'),
                                 icon: const Icon(Icons.archive),
                                 label: Text(loc.translate('archive')),
                               ),
                        ],
                      ),
                      if (app.status == 'INSPECTION_SCHEDULED')
                        const Padding(
                          padding: EdgeInsets.only(top: 8.0),
                          child: Text('*Entering results requires Inspection ID (Auto-fetch coming soon)', style: TextStyle(fontSize: 10, color: Colors.grey)),
                        ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _licenseActionBtn({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16, color: color),
      label: Text(label, style: TextStyle(fontSize: 12, color: color)),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: color.withOpacity(0.5)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 140, child: Text(label, style: TextStyle(color: Colors.grey.shade600))),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  Future<void> _openFile(String fileName) async {
    final url = Uri.parse('${AppConfig.apiBaseUrl}/files/$fileName');
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not launch $url')));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error opening file: $e')));
      }
    }
  }
}
