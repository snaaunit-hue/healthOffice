/// Centralized validation rules for government-grade data precision.
class Validators {
  // Arabic Unicode range check
  static final _arabicRegex = RegExp(r'^[\u0600-\u06FF\s]+$');
  static final _specialCharRegex = RegExp(r'[!@#$%^&*()+=\[\]{};:"\\|<>/?]');
  static final _phoneRegex = RegExp(r'^(7[0-9]{8}|0[0-9]{9})$');
  static final _nationalIdRegex = RegExp(r'^\d{8,15}$');
  static final _licenseNumRegex = RegExp(r'^[A-Za-z0-9\-\/]+$');

  static String? required(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName مطلوب';
    }
    return null;
  }

  static String? requiredEn(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  static String? arabicName(String? value) {
    if (value == null || value.trim().isEmpty) return 'هذا الحقل مطلوب';
    if (!_arabicRegex.hasMatch(value.trim())) {
      return 'يجب أن يكون النص بالعربية فقط';
    }
    return null;
  }

  static String? noSpecialChars(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    if (_specialCharRegex.hasMatch(value)) {
      return 'لا يجوز استخدام رموز خاصة';
    }
    return null;
  }

  static String? nationalId(String? value) {
    if (value == null || value.trim().isEmpty) return 'رقم الهوية مطلوب';
    if (!_nationalIdRegex.hasMatch(value.trim())) {
      return 'رقم هوية غير صحيح (8-15 رقم)';
    }
    if (_specialCharRegex.hasMatch(value)) {
      return 'لا يجوز استخدام رموز خاصة في رقم الهوية';
    }
    return null;
  }

  static String? phoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) return 'رقم الهاتف مطلوب';
    String cleaned = value.replaceAll(RegExp(r'[\s\-\+]'), '');
    if (cleaned.startsWith('967')) cleaned = cleaned.substring(3);
    if (!_phoneRegex.hasMatch(cleaned)) {
      return 'رقم هاتف غير صحيح (يبدأ بـ 7 يليه 8 أرقام)';
    }
    return null;
  }

  static String? licenseNumber(String? value) {
    if (value == null || value.trim().isEmpty) return 'رقم الترخيص مطلوب';
    if (!_licenseNumRegex.hasMatch(value.trim())) {
      return 'تنسيق رقم ترخيص غير صحيح';
    }
    return null;
  }

  static String? dateMustBeFuture(DateTime? date) {
    if (date == null) return 'التاريخ مطلوب';
    if (date.isBefore(DateTime.now())) {
      return 'يجب أن يكون التاريخ في المستقبل';
    }
    return null;
  }

  static String? dateMustBePast(DateTime? date) {
    if (date == null) return 'التاريخ مطلوب';
    if (date.isAfter(DateTime.now())) {
      return 'يجب أن يكون التاريخ في الماضي';
    }
    return null;
  }

  static String? dateEndAfterStart(DateTime? start, DateTime? end) {
    if (start == null || end == null) return null;
    if (end.isBefore(start) || end.isAtSameMomentAs(start)) {
      return 'تاريخ الانتهاء يجب أن يكون بعد تاريخ البداية';
    }
    return null;
  }

  static String? roomsCount(String? value, String facilityType) {
    if (value == null || value.trim().isEmpty) return 'عدد الغرف مطلوب';
    final count = int.tryParse(value.trim());
    if (count == null || count <= 0) return 'أدخل عدداً صحيحاً';

    if ((facilityType == 'HOSPITAL' || facilityType == 'CENTER') && count < 8) {
      return 'المستشفيات والمراكز تتطلب 8 غرف على الأقل';
    }
    if ((facilityType == 'CLINIC' || facilityType == 'DENTAL_CLINIC' ||
            facilityType == 'LABORATORY') &&
        count < 3) {
      return 'العيادات والمختبرات تتطلب 3 غرف على الأقل';
    }
    return null;
  }

  /// Returns true if the facility type is a "large" facility (hospital/center)
  static bool isLargeFacility(String type) {
    return type == 'HOSPITAL' || type == 'CENTER';
  }

  /// Returns the list of required document types based on facility type
  static List<DocumentRequirement> getRequiredDocuments(String facilityType) {
    final common = <DocumentRequirement>[
      DocumentRequirement('GRADUATION_CERTIFICATE', true),
      DocumentRequirement('TRANSCRIPT', true),
      DocumentRequirement('EQUIVALENCY', true),
      DocumentRequirement('PRACTICE_LICENSE', true),
      DocumentRequirement('SYNDICATE_CARD', true),
      DocumentRequirement('NATIONAL_ID', true),
      DocumentRequirement('MEDICAL_CERTIFICATE', true),
    ];

    if (isLargeFacility(facilityType)) {
      return [
        ...common,
        DocumentRequirement('FEASIBILITY_STUDY', true),
        DocumentRequirement('OWNERSHIP_CONTRACT', true),
        DocumentRequirement('SITE_PLAN', true),
        DocumentRequirement('INVESTMENT_DECISION', false),
        DocumentRequirement('CONSTRUCTION_LICENSE', true),
        DocumentRequirement('CIVIL_DEFENSE_LICENSE', true),
        DocumentRequirement('OWNER_FILE', true),
      ];
    } else {
      return [
        ...common,
        DocumentRequirement('PERSONAL_PHOTOS', true),
        DocumentRequirement('OWNERSHIP_CONTRACT', true),
        DocumentRequirement('NO_OTHER_CLINIC_DECLARATION', true),
        DocumentRequirement('INDEPENDENCE_DECLARATION', true),
      ];
    }
  }

  /// Returns localization key for a document type
  static String docTypeToLocKey(String docType) {
    const map = {
      'GRADUATION_CERTIFICATE': 'graduationCertificate',
      'TRANSCRIPT': 'transcript',
      'EQUIVALENCY': 'equivalency',
      'PRACTICE_LICENSE': 'practiceLicense',
      'SYNDICATE_CARD': 'syndicateCard',
      'NATIONAL_ID': 'nationalId',
      'MEDICAL_CERTIFICATE': 'medicalCertificate',
      'FEASIBILITY_STUDY': 'feasibilityStudy',
      'OWNERSHIP_CONTRACT': 'ownershipContract',
      'SITE_PLAN': 'sitePlan',
      'INVESTMENT_DECISION': 'investmentDecision',
      'CONSTRUCTION_LICENSE': 'constructionLicense',
      'CIVIL_DEFENSE_LICENSE': 'civilDefenseLicense',
      'OWNER_FILE': 'ownerFile',
      'PERSONAL_PHOTOS': 'personalPhotos',
      'NO_OTHER_CLINIC_DECLARATION': 'noOtherClinicDeclaration',
      'INDEPENDENCE_DECLARATION': 'independenceDeclaration',
    };
    return map[docType] ?? docType;
  }
}

class DocumentRequirement {
  final String type;
  final bool mandatory;
  const DocumentRequirement(this.type, this.mandatory);
}
