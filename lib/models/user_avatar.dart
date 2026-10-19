import 'dart:convert';

class UserAvatar {
  final String id;
  final String imagePath;
  final double? heightCm;
  final String? bodyType; // 'Retangular', 'Ampulheta', 'Triangular', 'Atlético', etc.
  final String? skinTone;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserAvatar({
    required this.id,
    required this.imagePath,
    this.heightCm,
    this.bodyType,
    this.skinTone,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  UserAvatar copyWith({
    String? id,
    String? imagePath,
    double? heightCm,
    String? bodyType,
    String? skinTone,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserAvatar(
      id: id ?? this.id,
      imagePath: imagePath ?? this.imagePath,
      heightCm: heightCm ?? this.heightCm,
      bodyType: bodyType ?? this.bodyType,
      skinTone: skinTone ?? this.skinTone,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'imagePath': imagePath,
      'heightCm': heightCm,
      'bodyType': bodyType,
      'skinTone': skinTone,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory UserAvatar.fromMap(Map<String, dynamic> map) {
    return UserAvatar(
      id: map['id'] as String? ?? 'default_avatar',
      imagePath: map['imagePath'] as String? ?? '',
      heightCm: (map['heightCm'] as num?)?.toDouble(),
      bodyType: map['bodyType'] as String?,
      skinTone: map['skinTone'] as String?,
      notes: map['notes'] as String?,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'] as String)
          : DateTime.now(),
    );
  }

  String toJson() => json.encode(toMap());

  factory UserAvatar.fromJson(String source) =>
      UserAvatar.fromMap(json.decode(source) as Map<String, dynamic>);
}
