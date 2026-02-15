class FacilityModel {
  final int id;
  final String facilityCode;
  final String nameAr;
  final String? nameEn;
  final String facilityType;
  final String licenseType;
  final String? district;
  final String? area;
  final String? street;
  final String? propertyOwner;
  final double? latitude;
  final double? longitude;
  final int? roomsCount;
  final bool isActive;
  final String? governorate;
  final String? sector;
  final String? specialty;
  final String operationalStatus;

  FacilityModel({
    required this.id,
    required this.facilityCode,
    required this.nameAr,
    this.nameEn,
    required this.facilityType,
    required this.licenseType,
    this.district,
    this.area,
    this.street,
    this.propertyOwner,
    this.latitude,
    this.longitude,
    this.roomsCount,
    required this.isActive,
    this.governorate,
    this.sector,
    this.specialty,
    required this.operationalStatus,
  });

  factory FacilityModel.fromJson(Map<String, dynamic> json) {
    return FacilityModel(
      id: json['id'],
      facilityCode: json['facilityCode'],
      nameAr: json['nameAr'],
      nameEn: json['nameEn'],
      facilityType: json['facilityType'],
      licenseType: json['licenseType'],
      district: json['district'],
      area: json['area'],
      street: json['street'],
      propertyOwner: json['propertyOwner'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      roomsCount: json['roomsCount'],
      isActive: json['isActive'],
      governorate: json['governorate'],
      sector: json['sector'],
      specialty: json['specialty'],
      operationalStatus: json['operationalStatus'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'facilityCode': facilityCode,
      'nameAr': nameAr,
      'nameEn': nameEn,
      'facilityType': facilityType,
      'licenseType': licenseType,
      'district': district,
      'area': area,
      'street': street,
      'propertyOwner': propertyOwner,
      'latitude': latitude,
      'longitude': longitude,
      'roomsCount': roomsCount,
      'isActive': isActive,
      'governorate': governorate,
      'sector': sector,
      'specialty': specialty,
      'operationalStatus': operationalStatus,
    };
  }
}
