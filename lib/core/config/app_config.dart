class AppConfig {
  // Use localhost for local dev, or your machine's IP (192.168.43.200) for mobile testing
  static const String apiBaseUrl = 'https://health-office-backend.onrender.com/api/v1';
  static const String appNameAr = 'مكتب الصحة والبيئة - أمانة العاصمة';
  static const String appNameEn = 'Health & Environment Office – Capital Secretariat';
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
