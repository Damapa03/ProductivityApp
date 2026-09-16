/// Perfil de usuario de Flowly.
///
/// Solo datos de identidad (demo local). NUNCA se guardan contraseñas.
class Profile {
  const Profile({
    required this.name,
    required this.email,
    required this.createdAt,
  });

  final String name;
  final String email;
  final DateTime createdAt;

  Map<String, Object?> toJson() => {
        'name': name,
        'email': email,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Profile.fromJson(Map<String, Object?> json) {
    final raw = json['createdAt'];
    return Profile(
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      createdAt: raw is String
          ? DateTime.tryParse(raw) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
