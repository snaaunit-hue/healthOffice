import 'package:flutter/material.dart';
import '../data/facility_model.dart';
import '../data/facility_repository.dart';
import 'facility_detail_screen.dart';

class FacilityDashboardScreen extends StatefulWidget {
  const FacilityDashboardScreen({Key? key}) : super(key: key);

  @override
  State<FacilityDashboardScreen> createState() => _FacilityDashboardScreenState();
}

class _FacilityDashboardScreenState extends State<FacilityDashboardScreen> {
  final FacilityRepository _repository = FacilityRepository();
  final TextEditingController _searchController = TextEditingController();

  List<FacilityModel> _facilities = [];
  bool _isLoading = false;
  String? _selectedStatus;
  String? _selectedType;

  @override
  void initState() {
    super.initState();
    _fetchFacilities();
  }

  Future<void> _fetchFacilities() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final facilities = await _repository.getFacilities(
        search: _searchController.text,
        operationalStatus: _selectedStatus,
        facilityType: _selectedType,
      );
      setState(() {
        _facilities = facilities;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading facilities: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'ACTIVE':
        return Colors.green;
      case 'CLOSED':
        return Colors.red;
      case 'SUSPENDED':
        return Colors.orange;
      case 'UNDER_REVIEW':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Facility Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name or code...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _fetchFacilities();
                  },
                ),
              ),
              onSubmitted: (_) => _fetchFacilities(),
            ),
          ),
          _buildFilterChips(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _facilities.isEmpty
                    ? const Center(child: Text('No facilities found'))
                    : ListView.builder(
                        itemCount: _facilities.length,
                        itemBuilder: (context, index) {
                          final facility = _facilities[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: _getStatusColor(facility.operationalStatus),
                                child: const Icon(Icons.local_hospital, color: Colors.white),
                              ),
                              title: Text(facility.nameAr),
                              subtitle: Text('${facility.facilityType} - ${facility.district ?? ""}'),
                              trailing: Text(
                                facility.operationalStatus,
                                style: TextStyle(
                                  color: _getStatusColor(facility.operationalStatus),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => FacilityDetailScreen(facilityId: facility.id),
                                  ),
                                ).then((_) => _fetchFacilities()); // Refresh on return
                              },
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          _buildChip('All', null),
          const SizedBox(width: 8),
          _buildChip('Active', 'ACTIVE'),
          const SizedBox(width: 8),
          _buildChip('Closed', 'CLOSED'),
          const SizedBox(width: 8),
          _buildChip('Suspended', 'SUSPENDED'),
          const SizedBox(width: 8),
          _buildChip('Under Review', 'UNDER_REVIEW'),
        ],
      ),
    );
  }

  Widget _buildChip(String label, String? status) {
    final isSelected = _selectedStatus == status;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedStatus = selected ? status : null;
        });
        _fetchFacilities();
      },
    );
  }

  void _showFilterDialog() {
    // Implement advanced filter dialog for Governorates, Types etc.
  }
}
