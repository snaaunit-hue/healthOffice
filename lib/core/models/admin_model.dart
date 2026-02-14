class AdminUser {
  final int id;
  final String username;
  final String fullName;
  final String role;

  AdminUser({
    required this.id,
    required this.username,
    required this.fullName,
    required this.role,
  });

  factory AdminUser.fromJson(Map<String, dynamic> json) {
    return AdminUser(
      id: json['id'],
      username: json['username'],
      fullName: json['fullName'],
      role: json['role'] ?? '',
    );
  }
}
