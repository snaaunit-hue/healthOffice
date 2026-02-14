class Inspection {
  final int id;
  final int applicationId;
  final String applicationNumber;
  final String? scheduledDate;
  final String? actualVisitDate;
  final int? inspectorId;
  final String? inspectorName;
  final String status;
  final double? overallScore;
  final String? notes;
  final List<InspectionScore>? items;

  Inspection({
    required this.id,
    required this.applicationId,
    required this.applicationNumber,
    this.scheduledDate,
    this.actualVisitDate,
    this.inspectorId,
    this.inspectorName,
    required this.status,
    this.overallScore,
    this.notes,
    this.items,
  });

  factory Inspection.fromJson(Map<String, dynamic> json) {
    return Inspection(
      id: json['id'],
      applicationId: json['applicationId'],
      applicationNumber: json['applicationNumber'] ?? 'N/A',
      scheduledDate: json['scheduledDate'],
      actualVisitDate: json['actualVisitDate'],
      inspectorId: json['inspectorId'],
      inspectorName: json['inspectorName'],
      status: json['status'],
      overallScore: json['overallScore']?.toDouble(),
      notes: json['notes'],
      items: json['items'] != null
          ? (json['items'] as List).map((i) => InspectionScore.fromJson(i)).toList()
          : null,
    );
  }
}

class InspectionScore {
  final int id;
  final String criterionCode;
  final String description;
  final double? score;
  final double maxScore;

  InspectionScore({
    required this.id,
    required this.criterionCode,
    required this.description,
    this.score,
    required this.maxScore,
  });

  factory InspectionScore.fromJson(Map<String, dynamic> json) {
    return InspectionScore(
      id: json['id'],
      criterionCode: json['criterionCode'],
      description: json['description'],
      score: json['score']?.toDouble(),
      maxScore: json['maxScore'].toDouble(),
    );
  }
}
