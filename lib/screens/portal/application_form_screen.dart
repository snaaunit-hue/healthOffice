import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/services/api_service.dart';
import '../../core/services/application_service.dart';
import '../../core/utils/validators.dart';
import '../../core/services/facility_service.dart';

class ApplicationFormScreen extends StatefulWidget {
  final int? preselectedFacilityId;

  const ApplicationFormScreen({super.key, this.preselectedFacilityId});

  @override
  State<ApplicationFormScreen> createState() => _ApplicationFormScreenState();
}

class _ApplicationFormScreenState extends State<ApplicationFormScreen>
    with TickerProviderStateMixin {
  int _currentStep = 0;
  bool _isSubmitting = false;
  bool _confirmChecked = false;
  final _formKeys = List.generate(5, (_) => GlobalKey<FormState>());

  // ─── Section A: Facility ───
  String _facilityType = 'HOSPITAL';
  String _licenseType = 'NEW';
  String _propertyStatus = 'OWNED';
  String _parkingStatus = 'OWNED';
  final _facilityNameCtrl = TextEditingController();
  final _districtCtrl = TextEditingController();
  final _areaCtrl = TextEditingController();
  final _streetCtrl = TextEditingController();
  final _propertyOwnerCtrl = TextEditingController();
  final _roomsCountCtrl = TextEditingController();
  final _specializationsCtrl = TextEditingController();
  final _latCtrl = TextEditingController();
  final _lonCtrl = TextEditingController();

  // ─── Section B: Supervisor ───
  String _idDocType = 'ID_CARD';
  final _supervisorNameCtrl = TextEditingController();
  final _supervisorNidCtrl = TextEditingController();
  final _supervisorIdIssuerCtrl = TextEditingController();
  final _supervisorQualCtrl = TextEditingController();
  final _supervisorUnivCtrl = TextEditingController();
  final _supervisorQualIssuerCtrl = TextEditingController();
  final _supervisorPracticeLicCtrl = TextEditingController();
  final _supervisorPhoneCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  DateTime? _supervisorIdIssueDate;
  DateTime? _supervisorQualDate;
  DateTime? _supervisorLicenseExpiry;
  bool _pledgeCompliance = false;

  // ─── Section C: Previous License ───
  final _prevAuthorityCtrl = TextEditingController();
  final _prevLicenseNumCtrl = TextEditingController();
  DateTime? _prevLicenseDate;
  DateTime? _licenseFrom;
  DateTime? _licenseTo;

  // ─── Documents ───
  final Map<String, PlatformFile> _selectedFiles = {};

  late AnimationController _progressAnim;
  bool _facilityFieldsLocked = false;
  bool _facilityPrefillLoaded = false;

  @override
  void initState() {
    super.initState();
    _progressAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    if (widget.preselectedFacilityId != null) {
      _loadFacilityAndPrefill();
    } else {
      _facilityPrefillLoaded = true;
    }
  }

  Future<void> _loadFacilityAndPrefill() async {
    if (widget.preselectedFacilityId == null) return;
    try {
      final api = context.read<ApiService>();
      final service = FacilityService(api);
      final profile = await service.getProfile(widget.preselectedFacilityId!);
      final f = profile.facility;
      if (mounted) {
        setState(() {
          _facilityNameCtrl.text = f.nameAr;
          if (f.nameEn != null && f.nameEn!.isNotEmpty) {}
          _facilityType = f.facilityType;
          _districtCtrl.text = f.district ?? '';
          _areaCtrl.text = f.area ?? '';
          _streetCtrl.text = f.street ?? '';
          _propertyOwnerCtrl.text = f.propertyOwner ?? '';
          _roomsCountCtrl.text = f.roomsCount?.toString() ?? '';
          _specializationsCtrl.text = f.specialty ?? '';
          if (f.latitude != null) _latCtrl.text = f.latitude.toString();
          if (f.longitude != null) _lonCtrl.text = f.longitude.toString();
          _facilityFieldsLocked = true;
          _facilityPrefillLoaded = true;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _facilityPrefillLoaded = true);
    }
  }

  @override
  void dispose() {
    _progressAnim.dispose();
    for (var c in [
      _facilityNameCtrl, _districtCtrl, _areaCtrl, _streetCtrl,
      _propertyOwnerCtrl, _roomsCountCtrl, _specializationsCtrl,
      _latCtrl, _lonCtrl, _supervisorNameCtrl, _supervisorNidCtrl,
      _supervisorIdIssuerCtrl, _supervisorQualCtrl, _supervisorUnivCtrl,
      _supervisorQualIssuerCtrl, _supervisorPracticeLicCtrl,
      _supervisorPhoneCtrl, _notesCtrl, _prevAuthorityCtrl,
      _prevLicenseNumCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  int get _totalSteps => _licenseType == 'RENEWAL' ? 5 : 4;
  List<String> get _stepLabels {
    final loc = AppLocalizations.of(context)!;
    final steps = [
      loc.translate('facilityData'),
      loc.translate('technicalSupervisor'),
      loc.translate('documents'),
      loc.translate('reviewSummary'),
    ];
    if (_licenseType == 'RENEWAL') {
      steps.insert(2, loc.translate('previousLicense'));
    }
    return steps;
  }

  Future<void> _pickFile(String docType) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
        withData: true,
      );
      if (result != null) {
        final file = result.files.single;
        if (file.bytes == null) {
           // On some platforms bytes might be null if not using withData: true, 
           // but we are using withData: true.
           return;
        }
        // Enforce 5MB limit
        if (file.size > 5 * 1024 * 1024) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('حجم الملف يتجاوز 5 ميجابايت'),
                backgroundColor: AppTheme.errorRed,
              ),
            );
          }
          return;
        }
        setState(() => _selectedFiles[docType] = file);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<DateTime?> _pickDate(BuildContext context,
      {DateTime? initial, bool mustBeFuture = false, bool mustBePast = false}) async {
    final now = DateTime.now();
    return showDatePicker(
      context: context,
      initialDate: initial ?? now,
      firstDate: mustBeFuture ? now : DateTime(1950),
      lastDate: mustBePast ? now : DateTime(2050),
    );
  }

  bool _validateCurrentStep() {
    final key = _formKeys[_currentStep];
    return key.currentState?.validate() ?? false;
  }

  void _goNext() {
    if (!_validateCurrentStep()) return;

    // Extra validation for documents step
    final docStepIndex = _licenseType == 'RENEWAL' ? 3 : 2;
    if (_currentStep == docStepIndex) {
      final reqs = Validators.getRequiredDocuments(_facilityType);
      final missing = reqs.where((r) =>
          r.mandatory && !_selectedFiles.containsKey(r.type)).toList();
      if (missing.isNotEmpty) {
        final loc = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${loc.translate('missingDocuments')}: ${missing.map((m) => loc.translate(Validators.docTypeToLocKey(m.type))).join(', ')}',
            ),
            backgroundColor: AppTheme.errorRed,
            duration: const Duration(seconds: 4),
          ),
        );
        return;
      }
    }

    if (_currentStep < _totalSteps - 1) {
      setState(() => _currentStep++);
    } else {
      _submitForm();
    }
  }

  void _goBack() {
    if (_currentStep > 0) setState(() => _currentStep--);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final isWide = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate('newApplication')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/portal/applications'),
        ),
      ),
      body: _isSubmitting || (widget.preselectedFacilityId != null && !_facilityPrefillLoaded)
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(loc.translate('loading')),
                ],
              ),
            )
          : Column(
              children: [
                // ─── Progress Indicator ───
                _buildProgressBar(loc),
                // ─── Step Content ───
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: isWide ? 80 : 16,
                      vertical: 16,
                    ),
                    child: _buildCurrentStep(loc),
                  ),
                ),
                // ─── Navigation Buttons ───
                _buildNavigationButtons(loc),
              ],
            ),
    );
  }

  Widget _buildProgressBar(AppLocalizations loc) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _stepLabels[_currentStep],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_currentStep + 1} / $_totalSteps',
                  style: const TextStyle(
                    color: AppTheme.primaryGreen,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TweenAnimationBuilder<double>(
            tween: Tween(
              begin: 0,
              end: (_currentStep + 1) / _totalSteps,
            ),
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
            builder: (context, value, _) => ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: value,
                minHeight: 6,
                backgroundColor: Colors.grey.shade200,
                valueColor: const AlwaysStoppedAnimation(AppTheme.primaryGreen),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons(AppLocalizations loc) {
    final isLastStep = _currentStep == _totalSteps - 1;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _goBack,
                icon: const Icon(Icons.arrow_back),
                label: Text(loc.translate('previous')),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: isLastStep && !_confirmChecked ? null : _goNext,
              icon: Icon(isLastStep ? Icons.send : Icons.arrow_forward),
              label: Text(
                isLastStep ? loc.translate('submit') : loc.translate('next'),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: isLastStep
                    ? AppTheme.primaryGreen
                    : AppTheme.primaryGreen,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStep(AppLocalizations loc) {
    // Map logical step index to builder
    if (_currentStep == 0) return _buildFacilityStep(loc);
    if (_currentStep == 1) return _buildSupervisorStep(loc);
    if (_licenseType == 'RENEWAL') {
      if (_currentStep == 2) return _buildPreviousLicenseStep(loc);
      if (_currentStep == 3) return _buildDocumentsStep(loc);
      if (_currentStep == 4) return _buildReviewStep(loc);
    } else {
      if (_currentStep == 2) return _buildDocumentsStep(loc);
      if (_currentStep == 3) return _buildReviewStep(loc);
    }
    return const SizedBox.shrink();
  }

  // ═══════════════════════════════════════════
  //  STEP 1: Facility Data
  // ═══════════════════════════════════════════
  Widget _buildFacilityStep(AppLocalizations loc) {
    return Form(
      key: _formKeys[0],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(loc.translate('facilityData'), Icons.business),
          const SizedBox(height: 16),

          if (_facilityFieldsLocked)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.infoBlu.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.infoBlu.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lock, color: AppTheme.infoBlu, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'بيانات المنشأة مقفلة (من ملف المنشأة)',
                      style: TextStyle(color: AppTheme.infoBlu, fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),
          // Facility Type
          _fieldWithHelp(
            loc.translate('fieldHelp_facilityType'),
            DropdownButtonFormField<String>(
              value: _facilityType,
              decoration: InputDecoration(
                labelText: '${loc.translate('facilityType')} *',
                prefixIcon: const Icon(Icons.local_hospital),
              ),
              items: [
                _dropItem('HOSPITAL', loc.translate('hospital')),
                _dropItem('CENTER', loc.translate('medicalCenter')),
                _dropItem('CLINIC', loc.translate('clinic')),
                _dropItem('DENTAL_CLINIC', loc.translate('dentalClinic')),
                _dropItem('EMERGENCY_CLINIC', loc.translate('emergencyClinic')),
                _dropItem('LABORATORY', loc.translate('laboratory')),
                _dropItem('RADIOLOGY_LAB', loc.translate('radiologyLab')),
                _dropItem('PHARMACY', loc.translate('pharmacy')),
                _dropItem('OTHER', loc.translate('otherFacility')),
              ],
              onChanged: _facilityFieldsLocked ? null : (v) => setState(() => _facilityType = v!),
            ),
          ),
          const SizedBox(height: 16),

          // License Type
          DropdownButtonFormField<String>(
            value: _licenseType,
            decoration: InputDecoration(
              labelText: '${loc.translate('licenseType')} *',
              prefixIcon: const Icon(Icons.badge),
            ),
            items: [
              _dropItem('NEW', loc.translate('newLicense')),
              _dropItem('RENEWAL', loc.translate('renewal')),
            ],
            onChanged: _facilityFieldsLocked ? null : (v) => setState(() {
              _licenseType = v!;
              _currentStep = 0;
            }),
          ),
          const SizedBox(height: 16),

          // Specializations
          TextFormField(
            controller: _specializationsCtrl,
            readOnly: _facilityFieldsLocked,
            decoration: InputDecoration(
              labelText: loc.translate('specializations'),
              prefixIcon: const Icon(Icons.medical_services),
              hintText: 'مثال: باطنية، جراحة، أطفال',
            ),
          ),
          const SizedBox(height: 16),

          // Facility Name
          _fieldWithHelp(
            loc.translate('fieldHelp_facilityName'),
            TextFormField(
              controller: _facilityNameCtrl,
              readOnly: _facilityFieldsLocked,
              decoration: InputDecoration(
                labelText: '${loc.translate('facilityName')} *',
                prefixIcon: const Icon(Icons.drive_file_rename_outline),
              ),
              validator: (v) => Validators.required(v, loc.translate('facilityName')),
            ),
          ),
          const SizedBox(height: 16),

          // Location Row
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _districtCtrl,
                  readOnly: _facilityFieldsLocked,
                  decoration: InputDecoration(
                    labelText: '${loc.translate('district')} *',
                    prefixIcon: const Icon(Icons.location_city),
                  ),
                  validator: (v) => Validators.required(v, loc.translate('district')),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _areaCtrl,
                  readOnly: _facilityFieldsLocked,
                  decoration: InputDecoration(
                    labelText: '${loc.translate('area')} *',
                    prefixIcon: const Icon(Icons.map),
                  ),
                  validator: (v) => Validators.required(v, loc.translate('area')),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: _streetCtrl,
            readOnly: _facilityFieldsLocked,
            decoration: InputDecoration(
              labelText: loc.translate('street'),
              prefixIcon: const Icon(Icons.add_road),
            ),
          ),
          const SizedBox(height: 16),

          // Property
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _propertyStatus,
                  decoration: InputDecoration(
                    labelText: loc.translate('propertyStatus'),
                    prefixIcon: const Icon(Icons.home_work),
                  ),
                  items: [
                    _dropItem('OWNED', loc.translate('owned')),
                    _dropItem('RENTED', loc.translate('rented')),
                  ],
                  onChanged: _facilityFieldsLocked ? null : (v) => setState(() => _propertyStatus = v!),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _propertyOwnerCtrl,
                  readOnly: _facilityFieldsLocked,
                  decoration: InputDecoration(
                    labelText: '${loc.translate('propertyOwner')} *',
                    prefixIcon: const Icon(Icons.person),
                  ),
                  validator: (v) => Validators.required(v, loc.translate('propertyOwner')),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Parking + Rooms
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _parkingStatus,
                  decoration: InputDecoration(
                    labelText: loc.translate('parkingStatus'),
                    prefixIcon: const Icon(Icons.local_parking),
                  ),
                  items: [
                    _dropItem('OWNED', loc.translate('owned')),
                    _dropItem('RENTED', loc.translate('rented')),
                  ],
                  onChanged: _facilityFieldsLocked ? null : (v) => setState(() => _parkingStatus = v!),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _fieldWithHelp(
                  loc.translate('fieldHelp_roomsCount'),
                  TextFormField(
                    controller: _roomsCountCtrl,
                    readOnly: _facilityFieldsLocked,
                    decoration: InputDecoration(
                      labelText: '${loc.translate('roomsCount')} *',
                      prefixIcon: const Icon(Icons.meeting_room),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) =>
                        Validators.roomsCount(v, _facilityType),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // GPS
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _latCtrl,
                  readOnly: _facilityFieldsLocked,
                  decoration: InputDecoration(
                    labelText: loc.translate('latitude'),
                    prefixIcon: const Icon(Icons.explore),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  controller: _lonCtrl,
                  readOnly: _facilityFieldsLocked,
                  decoration: InputDecoration(
                    labelText: loc.translate('longitude'),
                    prefixIcon: const Icon(Icons.explore),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.my_location, color: AppTheme.primaryGreen),
                onPressed: _facilityFieldsLocked ? null : () => setState(() {
                  _latCtrl.text = "15.3694";
                  _lonCtrl.text = "44.1910";
                }),
                tooltip: loc.translate('getLocation'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════
  //  STEP 2: Technical Supervisor
  // ═══════════════════════════════════════════
  Widget _buildSupervisorStep(AppLocalizations loc) {
    return Form(
      key: _formKeys[1],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(loc.translate('technicalSupervisor'), Icons.person_pin),
          const SizedBox(height: 16),

          TextFormField(
            controller: _supervisorNameCtrl,
            decoration: InputDecoration(
              labelText: '${loc.translate('fullName')} *',
              prefixIcon: const Icon(Icons.person),
            ),
            validator: (v) => Validators.required(v, loc.translate('fullName')),
          ),
          const SizedBox(height: 16),

          // ID Document Type + Number
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _idDocType,
                  decoration: InputDecoration(
                    labelText: loc.translate('idDocType'),
                    prefixIcon: const Icon(Icons.badge),
                  ),
                  items: [
                    _dropItem('ID_CARD', loc.translate('idCard')),
                    _dropItem('PASSPORT', loc.translate('passport')),
                  ],
                  onChanged: (v) => setState(() => _idDocType = v!),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _fieldWithHelp(
                  loc.translate('fieldHelp_nationalId'),
                  TextFormField(
                    controller: _supervisorNidCtrl,
                    decoration: InputDecoration(
                      labelText: '${loc.translate('nationalId')} *',
                      prefixIcon: const Icon(Icons.numbers),
                    ),
                    validator: Validators.nationalId,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _supervisorIdIssuerCtrl,
                  decoration: InputDecoration(
                    labelText: '${loc.translate('idIssuer')} *',
                    prefixIcon: const Icon(Icons.account_balance),
                  ),
                  validator: (v) => Validators.required(v, loc.translate('idIssuer')),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _dateField(
                  label: loc.translate('issueDate'),
                  value: _supervisorIdIssueDate,
                  onPicked: (d) => setState(() => _supervisorIdIssueDate = d),
                  mustBePast: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Qualification
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _supervisorQualCtrl,
                  decoration: InputDecoration(
                    labelText: '${loc.translate('qualification')} *',
                    prefixIcon: const Icon(Icons.school),
                  ),
                  validator: (v) => Validators.required(v, loc.translate('qualification')),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _supervisorUnivCtrl,
                  decoration: InputDecoration(
                    labelText: loc.translate('university'),
                    prefixIcon: const Icon(Icons.domain),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _supervisorQualIssuerCtrl,
                  decoration: InputDecoration(
                    labelText: loc.translate('qualIssuer'),
                    prefixIcon: const Icon(Icons.verified),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _dateField(
                  label: loc.translate('qualDate'),
                  value: _supervisorQualDate,
                  onPicked: (d) => setState(() => _supervisorQualDate = d),
                  mustBePast: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Practice License
          Row(
            children: [
              Expanded(
                child: _fieldWithHelp(
                  loc.translate('fieldHelp_practiceLicense'),
                  TextFormField(
                    controller: _supervisorPracticeLicCtrl,
                    decoration: InputDecoration(
                      labelText: '${loc.translate('practiceLicense')} *',
                      prefixIcon: const Icon(Icons.card_membership),
                    ),
                    validator: (v) =>
                        Validators.required(v, loc.translate('practiceLicense')),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _dateField(
                  label: loc.translate('practiceLicenseExpiry'),
                  value: _supervisorLicenseExpiry,
                  onPicked: (d) => setState(() => _supervisorLicenseExpiry = d),
                  mustBeFuture: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Phone
          TextFormField(
            controller: _supervisorPhoneCtrl,
            decoration: InputDecoration(
              labelText: '${loc.translate('supervisorPhone')} *',
              prefixIcon: const Icon(Icons.phone),
              hintText: '7XXXXXXXX',
            ),
            keyboardType: TextInputType.phone,
            validator: Validators.phoneNumber,
          ),
          const SizedBox(height: 16),

          // Pledge
          CheckboxListTile(
            value: _pledgeCompliance,
            onChanged: (v) => setState(() => _pledgeCompliance = v ?? false),
            title: Text(loc.translate('pledgeCompliance'),
                style: const TextStyle(fontSize: 14)),
            controlAffinity: ListTileControlAffinity.leading,
            activeColor: AppTheme.primaryGreen,
          ),
          const SizedBox(height: 8),

          TextFormField(
            controller: _notesCtrl,
            decoration: InputDecoration(
              labelText: loc.translate('notes'),
              prefixIcon: const Icon(Icons.note),
            ),
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════
  //  STEP 3 (renewal only): Previous License
  // ═══════════════════════════════════════════
  Widget _buildPreviousLicenseStep(AppLocalizations loc) {
    return Form(
      key: _formKeys[2],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(loc.translate('previousLicense'), Icons.history),
          const SizedBox(height: 16),

          TextFormField(
            controller: _prevAuthorityCtrl,
            decoration: InputDecoration(
              labelText: '${loc.translate('prevLicenseIssuer')} *',
              prefixIcon: const Icon(Icons.account_balance),
            ),
            validator: (v) =>
                Validators.required(v, loc.translate('prevLicenseIssuer')),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _prevLicenseNumCtrl,
                  decoration: InputDecoration(
                    labelText: '${loc.translate('licenseNumber')} *',
                    prefixIcon: const Icon(Icons.numbers),
                  ),
                  validator: (v) =>
                      Validators.required(v, loc.translate('licenseNumber')),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _dateField(
                  label: loc.translate('licenseDate'),
                  value: _prevLicenseDate,
                  onPicked: (d) => setState(() => _prevLicenseDate = d),
                  mustBePast: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // License validity period
          Row(
            children: [
              Expanded(
                child: _dateField(
                  label: loc.translate('licenseFrom'),
                  value: _licenseFrom,
                  onPicked: (d) => setState(() => _licenseFrom = d),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _dateField(
                  label: loc.translate('licenseTo'),
                  value: _licenseTo,
                  onPicked: (d) => setState(() => _licenseTo = d),
                  mustBeFuture: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════
  //  STEP 3/4: Documents (conditional)
  // ═══════════════════════════════════════════
  Widget _buildDocumentsStep(AppLocalizations loc) {
    final docStepIndex = _licenseType == 'RENEWAL' ? 3 : 2;
    final reqs = Validators.getRequiredDocuments(_facilityType);

    return Form(
      key: _formKeys[docStepIndex],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(loc.translate('documentChecklist'), Icons.folder_open),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.infoBlu.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.infoBlu.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: AppTheme.infoBlu, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${loc.translate('allowedFormats')} | ${loc.translate('maxFileSize')}',
                    style: TextStyle(
                      color: AppTheme.infoBlu,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          ...reqs.map((req) => _documentCard(
                loc.translate(Validators.docTypeToLocKey(req.type)),
                req.type,
                req.mandatory,
              )),
        ],
      ),
    );
  }

  Widget _documentCard(String label, String key, bool mandatory) {
    final file = _selectedFiles[key];
    final hasFile = file != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: hasFile
            ? AppTheme.successGreen.withOpacity(0.05)
            : mandatory
                ? AppTheme.errorRed.withOpacity(0.03)
                : Colors.grey.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasFile
              ? AppTheme.successGreen.withOpacity(0.4)
              : mandatory
                  ? AppTheme.errorRed.withOpacity(0.2)
                  : Colors.grey.shade300,
        ),
      ),
      child: Row(
        children: [
          Icon(
            hasFile ? Icons.check_circle : Icons.circle_outlined,
            color: hasFile ? AppTheme.successGreen : Colors.grey,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(label,
                          style: const TextStyle(fontWeight: FontWeight.w500)),
                    ),
                    if (mandatory)
                      const Text(' *',
                          style: TextStyle(
                              color: AppTheme.errorRed, fontWeight: FontWeight.bold)),
                  ],
                ),
                if (hasFile)
                  Text(
                    file!.name,
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          if (hasFile)
            IconButton(
              icon: const Icon(Icons.swap_horiz, size: 18),
              tooltip: AppLocalizations.of(context)!.translate('replaceFile'),
              onPressed: () => _pickFile(key),
              color: AppTheme.warningOrange,
            )
          else
            OutlinedButton.icon(
              onPressed: () => _pickFile(key),
              icon: const Icon(Icons.upload_file, size: 16),
              label: Text(
                AppLocalizations.of(context)!.translate('uploadDocument'),
                style: const TextStyle(fontSize: 12),
              ),
              style: OutlinedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════
  //  STEP 4/5: Review & Confirmation
  // ═══════════════════════════════════════════
  Widget _buildReviewStep(AppLocalizations loc) {
    final reviewStepIndex = _licenseType == 'RENEWAL' ? 4 : 3;
    final reqs = Validators.getRequiredDocuments(_facilityType);

    return Form(
      key: _formKeys[reviewStepIndex],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(loc.translate('reviewSummary'), Icons.fact_check),
          const SizedBox(height: 16),

          // Facility Summary
          _reviewCard(
            loc.translate('facilityData'),
            Icons.business,
            [
              _reviewRow(loc.translate('facilityType'), _facilityType),
              _reviewRow(loc.translate('licenseType'), _licenseType == 'NEW'
                  ? loc.translate('newLicense') : loc.translate('renewal')),
              _reviewRow(loc.translate('facilityName'), _facilityNameCtrl.text),
              _reviewRow(loc.translate('district'), _districtCtrl.text),
              _reviewRow(loc.translate('area'), _areaCtrl.text),
              _reviewRow(loc.translate('street'), _streetCtrl.text),
              _reviewRow(loc.translate('propertyOwner'), _propertyOwnerCtrl.text),
              _reviewRow(loc.translate('roomsCount'), _roomsCountCtrl.text),
            ],
          ),
          const SizedBox(height: 12),

          // Supervisor Summary
          _reviewCard(
            loc.translate('technicalSupervisor'),
            Icons.person_pin,
            [
              _reviewRow(loc.translate('fullName'), _supervisorNameCtrl.text),
              _reviewRow(loc.translate('nationalId'), _supervisorNidCtrl.text),
              _reviewRow(loc.translate('qualification'), _supervisorQualCtrl.text),
              _reviewRow(loc.translate('practiceLicense'),
                  _supervisorPracticeLicCtrl.text),
              _reviewRow(loc.translate('supervisorPhone'),
                  _supervisorPhoneCtrl.text),
            ],
          ),
          const SizedBox(height: 12),

          // Documents Summary
          _reviewCard(
            loc.translate('documentChecklist'),
            Icons.folder_open,
            reqs.map((r) => _reviewDocRow(
                  loc.translate(Validators.docTypeToLocKey(r.type)),
                  _selectedFiles.containsKey(r.type),
                  r.mandatory,
                )).toList(),
          ),
          const SizedBox(height: 20),

          // Missing docs warning
          Builder(builder: (context) {
            final missing = reqs
                .where((r) =>
                    r.mandatory && !_selectedFiles.containsKey(r.type))
                .toList();
            if (missing.isEmpty) return const SizedBox.shrink();
            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.errorRed.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.errorRed.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber,
                      color: AppTheme.errorRed, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${loc.translate('missingDocuments')}: ${missing.length}',
                      style: const TextStyle(
                          color: AppTheme.errorRed, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 16),

          // Confirmation
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.3)),
            ),
            child: CheckboxListTile(
              value: _confirmChecked,
              onChanged: (v) => setState(() => _confirmChecked = v ?? false),
              title: Text(
                loc.translate('confirmData'),
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 14),
              ),
              controlAffinity: ListTileControlAffinity.leading,
              activeColor: AppTheme.primaryGreen,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════
  //  SUBMIT
  // ═══════════════════════════════════════════
  Future<void> _submitForm() async {
    if (!_confirmChecked) return;

    setState(() => _isSubmitting = true);
    final loc = AppLocalizations.of(context)!;

    try {
      final auth = context.read<AuthProvider>();
      final api = context.read<ApiService>();
      final service = ApplicationService(api);

      final appData = {
        'facilityNameAr': _facilityNameCtrl.text,
        'licenseType': _licenseType,
        'facilityType': _facilityType,
        'supervisorName': _supervisorNameCtrl.text,
        'supervisorNationalId': _supervisorNidCtrl.text,
        'supervisorIdIssuer': _supervisorIdIssuerCtrl.text,
        'supervisorIdIssueDate': _supervisorIdIssueDate?.toIso8601String().split('T')[0],
        'supervisorQualification': _supervisorQualCtrl.text,
        'supervisorUniversity': _supervisorUnivCtrl.text,
        'supervisorQualIssuer': _supervisorQualIssuerCtrl.text,
        'supervisorQualDate': _supervisorQualDate?.toIso8601String().split('T')[0],
        'supervisorPracticeLicense': _supervisorPracticeLicCtrl.text,
        'supervisorLicenseExpiry':
            _supervisorLicenseExpiry?.toIso8601String().split('T')[0],
        'prevIssuingAuthority':
            _licenseType == 'RENEWAL' ? _prevAuthorityCtrl.text : null,
        'prevLicenseNumber':
            _licenseType == 'RENEWAL' ? _prevLicenseNumCtrl.text : null,
        'prevLicenseDate':
            _licenseType == 'RENEWAL'
                ? _prevLicenseDate?.toIso8601String().split('T')[0]
                : null,
        'prevValidityPeriod': _licenseType == 'RENEWAL' && _licenseFrom != null
            ? '${_licenseFrom!.toIso8601String().split('T')[0]} to ${_licenseTo?.toIso8601String().split('T')[0]}'
            : null,
        'latitude': double.tryParse(_latCtrl.text),
        'longitude': double.tryParse(_lonCtrl.text),
      };

      final facilityId = widget.preselectedFacilityId ?? auth.facilityId;
      if (facilityId == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('يجب ربط المنشأة بحسابك أولاً'), backgroundColor: AppTheme.errorRed),
          );
          setState(() => _isSubmitting = false);
        }
        return;
      }
      final draft =
          await service.createDraft(facilityId, auth.actorId!, appData);

      // Upload docs
      final mandatoryTypes = Validators.getRequiredDocuments(_facilityType)
          .where((r) => r.mandatory)
          .map((r) => r.type)
          .toSet();

      for (var entry in _selectedFiles.entries) {
        await service.uploadAndAddDocument(
          applicationId: draft.id,
          userId: auth.actorId!,
          docType: entry.key,
          fileName: entry.value.name,
          bytes: entry.value.bytes!,
          mandatory: mandatoryTypes.contains(entry.key),
        );
      }

      // Submit
      await service.submitApplication(draft.id, auth.actorId!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(loc.translate('success')),
            backgroundColor: AppTheme.successGreen,
          ),
        );
        context.go('/portal/applications');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.errorRed),
        );
        setState(() => _isSubmitting = false);
      }
    }
  }

  // ─── Helper Widgets ───

  DropdownMenuItem<String> _dropItem(String value, String label) =>
      DropdownMenuItem(value: value, child: Text(label));

  Widget _sectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppTheme.primaryGreen, size: 20),
        ),
        const SizedBox(width: 10),
        Text(title,
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 18)),
      ],
    );
  }

  Widget _fieldWithHelp(String helpText, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        child,
        Padding(
          padding: const EdgeInsets.only(top: 4, right: 8, left: 8),
          child: Text(helpText,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
        ),
      ],
    );
  }

  Widget _dateField({
    required String label,
    required DateTime? value,
    required ValueChanged<DateTime?> onPicked,
    bool mustBeFuture = false,
    bool mustBePast = false,
  }) {
    return InkWell(
      onTap: () async {
        final d = await _pickDate(context,
            initial: value, mustBeFuture: mustBeFuture, mustBePast: mustBePast);
        if (d != null) onPicked(d);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.calendar_today, size: 18),
          suffixIcon: const Icon(Icons.arrow_drop_down),
        ),
        child: Text(
          value != null
              ? '${value.year}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}'
              : '',
          style: const TextStyle(fontSize: 14),
        ),
      ),
    );
  }

  Widget _reviewCard(String title, IconData icon, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppTheme.primaryGreen, size: 18),
                const SizedBox(width: 8),
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15)),
              ],
            ),
            const Divider(),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _reviewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(label,
                style: TextStyle(
                    color: Colors.grey.shade600, fontSize: 13)),
          ),
          Expanded(
            child: Text(value.isNotEmpty ? value : '—',
                style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Widget _reviewDocRow(String label, bool uploaded, bool mandatory) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(
            uploaded ? Icons.check_circle : Icons.cancel,
            color: uploaded ? AppTheme.successGreen : AppTheme.errorRed,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 13))),
          if (mandatory && !uploaded)
            const Text('مطلوب',
                style: TextStyle(
                    color: AppTheme.errorRed,
                    fontSize: 11,
                    fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
