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
  };
}
