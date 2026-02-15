class Facility {
  final int? id;
  final String facilityCode;
  final String nameAr;
  final String? nameEn;
  final String facilityType;
  final String licenseType;
  final String? district;
  final String? area;
  final String? street;
  final double? latitude;
  final double? longitude;
  final String? propertyOwner;
  final int? roomsCount;
  final bool? isActive;
  final String? governorate;
  final String? sector;
  final String? specialty;
  final String? operationalStatus;

  Facility({
    this.id,
    required this.facilityCode,
    required this.nameAr,
    this.nameEn,
    required this.facilityType,
    required this.licenseType,
    this.district,
    this.area,
    this.street,
    this.latitude,
    this.longitude,
    this.propertyOwner,
    this.roomsCount,
    this.isActive,
    this.governorate,
    this.sector,
    this.specialty,
    this.operationalStatus,
  });

  factory Facility.fromJson(Map<String, dynamic> json) {
    return Facility(
      id: json['id'],
      facilityCode: json['facilityCode'] ?? '',
      nameAr: json['nameAr'] ?? '',
      nameEn: json['nameEn'],
      facilityType: json['facilityType'] ?? '',
      licenseType: json['licenseType'] ?? '',
      district: json['district'],
      area: json['area'],
      street: json['street'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      propertyOwner: json['propertyOwner'],
      roomsCount: json['roomsCount'],
      isActive: json['isActive'],
      governorate: json['governorate'],
      sector: json['sector'],
      specialty: json['specialty'],
      operationalStatus: json['operationalStatus'],
    );
  }

  Map<String, dynamic> toJson() => {
    'facilityCode': facilityCode,
    'nameAr': nameAr,
    'nameEn': nameEn,
    'facilityType': facilityType,
    'licenseType': licenseType,
    'district': district,
    'area': area,
    'street': street,
    'latitude': latitude,
    'longitude': longitude,
    'propertyOwner': propertyOwner,
    'roomsCount': roomsCount,
    'isActive': isActive,
    'governorate': governorate,
    'sector': sector,
    'specialty': specialty,
    'operationalStatus': operationalStatus,
  };
}

class FacilityProfile {
  final Facility facility;
  final String? currentLicenseNumber;
  final String? currentLicenseStatus;
  final String? licenseExpiryDate;
  final int inspectionsCount;
  final int applicationsCount;

  FacilityProfile({
    required this.facility,
    this.currentLicenseNumber,
    this.currentLicenseStatus,
    this.licenseExpiryDate,
    this.inspectionsCount = 0,
    this.applicationsCount = 0,
  });

  factory FacilityProfile.fromJson(Map<String, dynamic> json) {
    return FacilityProfile(
      facility: Facility.fromJson(json['facility'] ?? {}),
      currentLicenseNumber: json['currentLicenseNumber'],
      currentLicenseStatus: json['currentLicenseStatus'],
      licenseExpiryDate: json['licenseExpiryDate']?.toString(),
      inspectionsCount: json['inspectionsCount'] ?? 0,
      applicationsCount: json['applicationsCount'] ?? 0,
    );
  }
}
