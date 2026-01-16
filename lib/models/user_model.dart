class UserModel {
  final String id;
  final String email;
  final String name;
  final String role;
  final String? avatarUrl;
  final String? authProvider;
  final String? status;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.avatarUrl,
    this.authProvider,
    this.status,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] ?? '',
        email: json['email'] ?? '',
        name: json['name'] ?? '',
        role: json['role'] ?? '',
        avatarUrl: json['avatar_url'],
        authProvider: json['auth_provider'],
        status: json['status'],
      );
}

