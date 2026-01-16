class Profile {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? avatarUrl;
  final String? role;
  final Map<String, dynamic> preferences;
  final String? authProvider;

  Profile({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.avatarUrl,
    this.role,
    required this.preferences,
    this.authProvider,
  });

  factory Profile.fromJson(Map<String, dynamic> json) => Profile(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        email: json['email'] ?? '',
        phone: json['phone'],
        avatarUrl: json['avatar_url'],
        role: json['role'],
        preferences: json['preferences'] ?? {},
        authProvider: json['auth_provider'],
      );
}
