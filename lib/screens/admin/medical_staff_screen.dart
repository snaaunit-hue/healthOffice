import 'package:flutter/material.dart';
import '../../core/models/medical_professional_model.dart';
import '../../core/services/medical_professional_service.dart';
import '../../core/localization/app_localizations.dart';

class MedicalStaffScreen extends StatefulWidget {
  @override
  _MedicalStaffScreenState createState() => _MedicalStaffScreenState();
}

class _MedicalStaffScreenState extends State<MedicalStaffScreen> {
  final MedicalProfessionalService _service = MedicalProfessionalService();
  final TextEditingController _searchController = TextEditingController();
  List<MedicalProfessional> _staffList = [];
  bool _isLoading = false;

  void _search() async {
    setState(() => _isLoading = true);
    try {
      final results = await _service.search(_searchController.text);
      setState(() => _staffList = results);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (context) => AddMedicalStaffDialog(service: _service, onSuccess: _search),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(loc.translate('medicalStaff'))),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: loc.translate('searchHint'),
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(icon: const Icon(Icons.search), onPressed: _search),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: _showAddDialog,
                  icon: const Icon(Icons.add),
                  label: Text(loc.translate('addStaff')),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _staffList.isEmpty 
                  ? Center(child: Text(loc.translate('noData')))
                  : ListView.builder(
                    itemCount: _staffList.length,
                    itemBuilder: (context, index) {
                      final staff = _staffList[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        child: ListTile(
                          title: Text(staff.fullNameAr),
                          subtitle: Text('${staff.specialization} - ${loc.translate('licenseNumber')}: ${staff.practiceLicenseNumber}'),
                          trailing: Text(staff.licenseExpiryDate),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class AddMedicalStaffDialog extends StatefulWidget {
  final MedicalProfessionalService service;
  final VoidCallback onSuccess;

  const AddMedicalStaffDialog({required this.service, required this.onSuccess});

  @override
  _AddMedicalStaffDialogState createState() => _AddMedicalStaffDialogState();
}

class _AddMedicalStaffDialogState extends State<AddMedicalStaffDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nationalIdController = TextEditingController();
  final _nameArController = TextEditingController();
  final _licenseController = TextEditingController();
  final _specializationController = TextEditingController();

  void _submit() async {
    final loc = AppLocalizations.of(context)!;
    if (_formKey.currentState!.validate()) {
      final staff = MedicalProfessional(
        nationalId: _nationalIdController.text,
        fullNameAr: _nameArController.text,
        practiceLicenseNumber: _licenseController.text,
        specialization: _specializationController.text,
        qualification: 'Bachelor',
        licenseExpiryDate: '2025-12-31',
      );

      try {
        await widget.service.createProfessional(staff);
        widget.onSuccess();
        if (mounted) Navigator.pop(context);
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(loc.translate('addStaff')),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nationalIdController,
                decoration: InputDecoration(labelText: loc.translate('nationalId')),
                validator: (v) => v!.isEmpty ? loc.translate('error') : null,
              ),
              TextFormField(
                controller: _nameArController,
                decoration: InputDecoration(labelText: loc.translate('fullName') + ' (Ar)'),
                validator: (v) => v!.isEmpty ? loc.translate('error') : null,
              ),
              TextFormField(
                controller: _licenseController,
                decoration: InputDecoration(labelText: loc.translate('practiceLicense')),
                validator: (v) => v!.isEmpty ? loc.translate('error') : null,
              ),
              TextFormField(
                controller: _specializationController,
                decoration: InputDecoration(labelText: loc.translate('specialization')),
                validator: (v) => v!.isEmpty ? loc.translate('error') : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(loc.translate('cancel'))),
        ElevatedButton(onPressed: _submit, child: Text(loc.translate('save'))),
      ],
    );
  }
}
