class Application {
  final int id;
  final String applicationNumber;
  final int facilityId;
  final String facilityNameAr;
  final String facilityNameEn;
  final String status;
  final String licenseType;
  final String facilityType;
  final String? supervisorName;
  final String? createdAt;
  final String? rejectionReason;
  final List<ApplicationStep> steps;
  final List<ApplicationDocument> documents;
  final License? license;

  Application({
    required this.id,
    required this.applicationNumber,
    required this.facilityId,
    required this.facilityNameAr,
    required this.facilityNameEn,
    required this.status,
    required this.licenseType,
    required this.facilityType,
    this.supervisorName,
    this.createdAt,
    this.rejectionReason,
    this.steps = const [],
    this.documents = const [],
    this.license,
  });

  factory Application.fromJson(Map<String, dynamic> json) {
    return Application(
      id: json['id'],
      applicationNumber: json['applicationNumber'],
      facilityId: json['facilityId'],
      facilityNameAr: json['facilityNameAr'],
      facilityNameEn: json['facilityNameEn'] ?? '',
      status: json['status'],
      licenseType: json['licenseType'],
      facilityType: json['facilityType'],
      supervisorName: json['supervisorName'],
      createdAt: json['createdAt'],
      rejectionReason: json['rejectionReason'],
      steps: (json['steps'] as List?)
              ?.map((s) => ApplicationStep.fromJson(s))
              .toList() ??
          [],
      documents: (json['documents'] as List?)
              ?.map((d) => ApplicationDocument.fromJson(d))
              .toList() ??
          [],
      license: json['license'] != null ? License.fromJson(json['license']) : null,
    );
  }
}

class License {
  final int id;
  final String licenseNumber;
  final String issueDate;
  final String expiryDate;
  final String pdfUrl;
  final String status;

  License({
    required this.id,
    required this.licenseNumber,
    required this.issueDate,
    required this.expiryDate,
    required this.pdfUrl,
    required this.status,
  });

  factory License.fromJson(Map<String, dynamic> json) {
    return License(
      id: json['id'],
      licenseNumber: json['licenseNumber'],
      issueDate: json['issueDate'],
      expiryDate: json['expiryDate'],
      pdfUrl: json['pdfUrl'],
      status: json['status'],
    );
  }
}

class ApplicationStep {
  final int id;
  final int stepOrder;
  final String stepCode;
  final String status;
  final String? performedByName;
  final String? performedAt;
  final String? notes;

  ApplicationStep({
    required this.id,
    required this.stepOrder,
    required this.stepCode,
    required this.status,
    this.performedByName,
    this.performedAt,
    this.notes,
  });

  factory ApplicationStep.fromJson(Map<String, dynamic> json) {
    return ApplicationStep(
      id: json['id'],
      stepOrder: json['stepOrder'],
      stepCode: json['stepCode'],
      status: json['status'],
      performedByName: json['performedByName'],
      performedAt: json['performedAt'],
      notes: json['notes'],
    );
  }
}

class ApplicationDocument {
  final int? id;
  final String documentType;
  final String fileUrl;
  final bool isMandatory;
  final String? uploadedAt;

  ApplicationDocument({
    this.id,
    required this.documentType,
    required this.fileUrl,
    required this.isMandatory,
    this.uploadedAt,
  });

  factory ApplicationDocument.fromJson(Map<String, dynamic> json) {
    return ApplicationDocument(
      id: json['id'],
      documentType: json['documentType'] ?? '',
      fileUrl: json['fileUrl'] ?? '',
      isMandatory: json['isMandatory'] ?? false,
      uploadedAt: json['uploadedAt'],
    );
  }
}
