import 'dart:convert';

enum AuthMethod { google, email, guest }

class UserProfile {
  final String id;
  final String displayName;
  final String email;
  final String? photoUrl;
  final AuthMethod authMethod;
  final bool isLoggedIn;
  final String? colorPalette; // e.g. 'Outono Quente', 'Verão Suave', 'Inverno Escuro', 'Primavera Brilhante'
  final DateTime? lastSyncAt;
  final DateTime createdAt;

  const UserProfile({
    required this.id,
    required this.displayName,
    required this.email,
    this.photoUrl,
    required this.authMethod,
    required this.isLoggedIn,
    this.colorPalette,
    this.lastSyncAt,
    required this.createdAt,
  });

  UserProfile copyWith({
    String? id,
    String? displayName,
    String? email,
    String? photoUrl,
    AuthMethod? authMethod,
    bool? isLoggedIn,
    String? colorPalette,
    DateTime? lastSyncAt,
    DateTime? createdAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      authMethod: authMethod ?? this.authMethod,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      colorPalette: colorPalette ?? this.colorPalette,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'displayName': displayName,
      'email': email,
      'photoUrl': photoUrl,
      'authMethod': authMethod.name,
      'isLoggedIn': isLoggedIn ? 1 : 0,
      'colorPalette': colorPalette,
      'lastSyncAt': lastSyncAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    AuthMethod method = AuthMethod.guest;
    if (map['authMethod'] == 'google') {
      method = AuthMethod.google;
    } else if (map['authMethod'] == 'email') {
      method = AuthMethod.email;
    }

    return UserProfile(
      id: map['id'] as String? ?? 'guest_user',
      displayName: map['displayName'] as String? ?? 'Visitante Fashion',
      email: map['email'] as String? ?? 'convidado@wardrobe.ai',
      photoUrl: map['photoUrl'] as String?,
      authMethod: method,
      isLoggedIn: (map['isLoggedIn'] is int)
          ? (map['isLoggedIn'] as int) == 1
          : (map['isLoggedIn'] as bool? ?? false),
      colorPalette: map['colorPalette'] as String?,
      lastSyncAt: map['lastSyncAt'] != null
          ? DateTime.tryParse(map['lastSyncAt'] as String)
          : null,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  String toJson() => json.encode(toMap());

  factory UserProfile.fromJson(String source) =>
      UserProfile.fromMap(json.decode(source) as Map<String, dynamic>);

  static UserProfile guest() {
    return UserProfile(
      id: 'guest_${DateTime.now().millisecondsSinceEpoch}',
      displayName: 'Convidado Fashion',
      email: 'guest@wardrobe.ai',
      photoUrl: null,
      authMethod: AuthMethod.guest,
      isLoggedIn: false,
      colorPalette: 'Outono Quente',
      lastSyncAt: null,
      createdAt: DateTime.now(),
    );
  }
}
