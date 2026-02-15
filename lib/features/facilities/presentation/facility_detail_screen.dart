import 'package:flutter/material.dart';
import '../data/facility_model.dart';
import '../data/facility_repository.dart';

class FacilityDetailScreen extends StatefulWidget {
  final int facilityId;

  const FacilityDetailScreen({Key? key, required this.facilityId}) : super(key: key);

  @override
  State<FacilityDetailScreen> createState() => _FacilityDetailScreenState();
}

class _FacilityDetailScreenState extends State<FacilityDetailScreen> {
  final FacilityRepository _repository = FacilityRepository();
  FacilityModel? _facility;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    try {
      final facility = await _repository.getFacilityById(widget.facilityId);
      setState(() {
        _facility = facility;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _updateStatus(String newStatus) async {
    // Hardcoded admin ID for now, replace with logged-in user ID
    final int adminId = 1; 
    try {
      await _repository.updateStatus(widget.facilityId, newStatus, adminId);
      await _fetchDetails();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Status updated successfully')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error updating status: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_facility == null) {
      return const Scaffold(body: Center(child: Text('Facility not found')));
    }

    return Scaffold(
      appBar: AppBar(title: Text(_facility!.nameAr)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const Divider(height: 32),
            _buildDetailRow('Code', _facility!.facilityCode),
            _buildDetailRow('Type', _facility!.facilityType),
            _buildDetailRow('Specialty', _facility!.specialty ?? '-'),
            _buildDetailRow('Sector', _facility!.sector ?? '-'),
            _buildDetailRow('Governorate', _facility!.governorate ?? '-'),
            _buildDetailRow('District', _facility!.district ?? '-'),
            _buildDetailRow('Area/Street', '${_facility!.area ?? ""} - ${_facility!.street ?? ""}'),
            _buildDetailRow('Property Owner', _facility!.propertyOwner ?? '-'),
            const SizedBox(height: 20),
            const Text('Actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              children: [
                _buildActionButtons(),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        CircleAvatar(
          radius: 30,
          child: const Icon(Icons.local_hospital, size: 30),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _facility!.nameAr,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue),
                ),
                child: Text(
                  _facility!.operationalStatus,
                  style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
            ),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        if (_facility!.operationalStatus != 'ACTIVE')
          ElevatedButton.icon(
            icon: const Icon(Icons.check_circle),
            label: const Text('Activate'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () => _updateStatus('ACTIVE'),
          ),
        if (_facility!.operationalStatus != 'CLOSED')
          ElevatedButton.icon(
            icon: const Icon(Icons.block),
            label: const Text('Close Facility'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => _updateStatus('CLOSED'),
          ),
        if (_facility!.operationalStatus != 'SUSPENDED')
          ElevatedButton.icon(
            icon: const Icon(Icons.pause_circle_filled),
            label: const Text('Suspend'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            onPressed: () => _updateStatus('SUSPENDED'),
          ),
      ],
    );
  }
}
