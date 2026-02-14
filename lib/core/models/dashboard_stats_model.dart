class DashboardStats {
  final int totalApplications;
  final int pendingReview;
  final int inspectionsScheduled;
  final int activeLicenses;
  final int activeViolations;
  final int expiringLicenses;
  final int totalFacilities;
  final Map<String, int> applicationsByStatus;

  DashboardStats({
    required this.totalApplications,
    required this.pendingReview,
    required this.inspectionsScheduled,
    required this.activeLicenses,
    required this.activeViolations,
    required this.expiringLicenses,
    required this.totalFacilities,
    required this.applicationsByStatus,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalApplications: json['totalApplications'] ?? 0,
      pendingReview: json['pendingReview'] ?? 0,
      inspectionsScheduled: json['inspectionsScheduled'] ?? 0,
      activeLicenses: json['activeLicenses'] ?? 0,
      activeViolations: json['activeViolations'] ?? 0,
      expiringLicenses: json['expiringLicenses'] ?? 0,
      totalFacilities: json['totalFacilities'] ?? 0,
      applicationsByStatus: Map<String, int>.from(json['applicationsByStatus'] ?? {}),
    );
  }
}
