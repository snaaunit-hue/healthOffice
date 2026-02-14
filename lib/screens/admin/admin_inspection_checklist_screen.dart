import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/models/inspection_model.dart';
import '../../core/services/api_service.dart';
import '../../core/services/inspection_service.dart';
import '../../core/theme/app_theme.dart';

class AdminInspectionChecklistScreen extends StatefulWidget {
  final int inspectionId;
  const AdminInspectionChecklistScreen({super.key, required this.inspectionId});

  @override
  State<AdminInspectionChecklistScreen> createState() => _AdminInspectionChecklistScreenState();
}

class _AdminInspectionChecklistScreenState extends State<AdminInspectionChecklistScreen> {
  Inspection? _inspection;
  bool _isLoading = true;
  final Map<int, double> _scores = {};
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    setState(() => _isLoading = true);
    try {
      final api = context.read<ApiService>();
      final service = InspectionService(api);
      final data = await service.getById(widget.inspectionId);
      setState(() {
        _inspection = data;
        if (data.items != null) {
          for (var item in data.items!) {
            _scores[item.id] = item.score ?? 0.0;
          }
        }
        _notesController.text = data.notes ?? '';
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      setState(() => _isLoading = false);
    }
  }

  double _calculateOverall() {
    if (_inspection?.items == null || _inspection!.items!.isEmpty) return 0.0;
    double total = 0;
    double maxPossible = 0;
    for (var item in _inspection!.items!) {
      total += _scores[item.id] ?? 0.0;
      maxPossible += item.maxScore;
    }
    return (total / maxPossible) * 100;
  }

  Future<void> _submit() async {
    setState(() => _isLoading = true);
    try {
      final api = context.read<ApiService>();
      final service = InspectionService(api);
      
      final List<Map<String, dynamic>> itemsList = _scores.entries.map((e) => {
        'id': e.key,
        'score': e.value,
      }).toList();

      await service.completeInspection(
        widget.inspectionId,
        _calculateOverall(),
        _notesController.text,
        itemsList,
      );

      if (mounted) {
        final loc = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc.translate('success'))));
        context.pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_inspection == null) return Scaffold(body: Center(child: Text(loc.translate('noData'))));

    return Scaffold(
      appBar: AppBar(
        title: Text('${loc.translate('inspectionChecklist')}: ${_inspection!.applicationNumber}'),
        actions: [
          TextButton(
            onPressed: _submit,
            child: Text(loc.translate('submit').toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: AppTheme.primaryGreen.withOpacity(0.1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(loc.translate('overallScore'), style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('${_calculateOverall().toStringAsFixed(1)}%', 
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.primaryGreen)),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _inspection!.items?.length ?? 0,
              itemBuilder: (context, index) {
                final item = _inspection!.items![index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${item.criterionCode}: ${item.description}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: Slider(
                                value: _scores[item.id] ?? 0.0,
                                min: 0,
                                max: item.maxScore,
                                divisions: item.maxScore.toInt() > 0 ? item.maxScore.toInt() : 1,
                                label: (_scores[item.id] ?? 0.0).toString(),
                                onChanged: (val) => setState(() => _scores[item.id] = val),
                              ),
                            ),
                            Text('${_scores[item.id]!.toStringAsFixed(1)} / ${item.maxScore}'),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _notesController,
              decoration: InputDecoration(labelText: loc.translate('generalNotes'), border: const OutlineInputBorder()),
              maxLines: 3,
            ),
          ),
        ],
      ),
    );
  }
}
