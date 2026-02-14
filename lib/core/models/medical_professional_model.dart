class MedicalProfessional {
  final int? id;
  final String nationalId;
  final String fullNameAr;
  final String? fullNameEn;
  final String? phoneNumber;
  final String? email;
  final String qualification;
  final String specialization;
  final String? university;
  final int? graduationYear;
  final String practiceLicenseNumber;
  final String? licenseIssueDate;
  final String licenseExpiryDate;

  MedicalProfessional({
    this.id,
    required this.nationalId,
    required this.fullNameAr,
    this.fullNameEn,
    this.phoneNumber,
    this.email,
    required this.qualification,
    required this.specialization,
    this.university,
    this.graduationYear,
    required this.practiceLicenseNumber,
    this.licenseIssueDate,
    required this.licenseExpiryDate,
  });

  factory MedicalProfessional.fromJson(Map<String, dynamic> json) {
    return MedicalProfessional(
      id: json['id'],
      nationalId: json['nationalId'],
      fullNameAr: json['fullNameAr'],
      fullNameEn: json['fullNameEn'],
      phoneNumber: json['phoneNumber'],
      email: json['email'],
      qualification: json['qualification'],
      specialization: json['specialization'],
      university: json['university'],
      graduationYear: json['graduationYear'],
      practiceLicenseNumber: json['practiceLicenseNumber'],
      licenseIssueDate: json['licenseIssueDate'],
      licenseExpiryDate: json['licenseExpiryDate'],
    );
  }

  Map<String, dynamic> toJson() => {
    'nationalId': nationalId,
    'fullNameAr': fullNameAr,
    'fullNameEn': fullNameEn,
    'phoneNumber': phoneNumber,
    'email': email,
    'qualification': qualification,
    'specialization': specialization,
    'university': university,
    'graduationYear': graduationYear,
    'practiceLicenseNumber': practiceLicenseNumber,
    'licenseIssueDate': licenseIssueDate,
    'licenseExpiryDate': licenseExpiryDate,
  };
}
