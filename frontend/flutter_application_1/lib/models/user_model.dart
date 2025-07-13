class User {
  final String id;
  final String username;
  final String email;
  final bool emailVerified;
  final String? firstName;
  final String? lastName;
  final String? profilePictureUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.emailVerified,
    this.firstName,
    this.lastName,
    this.profilePictureUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  // Create User from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      emailVerified: json['email_verified'] ?? false,
      firstName: json['first_name'],
      lastName: json['last_name'],
      profilePictureUrl: json['profile_picture_url'],
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  // Convert User to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'email_verified': emailVerified,
      'first_name': firstName,
      'last_name': lastName,
      'profile_picture_url': profilePictureUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Create a copy of User with updated fields
  User copyWith({
    String? id,
    String? username,
    String? email,
    bool? emailVerified,
    String? firstName,
    String? lastName,
    String? profilePictureUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      emailVerified: emailVerified ?? this.emailVerified,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Get full name
  String get fullName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    } else if (firstName != null) {
      return firstName!;
    } else if (lastName != null) {
      return lastName!;
    } else {
      return username;
    }
  }

  // Get display name (prioritizes full name, falls back to username)
  String get displayName {
    final name = fullName;
    return name.isNotEmpty ? name : username;
  }

  @override
  String toString() {
    return 'User(id: $id, username: $username, email: $email, emailVerified: $emailVerified)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
} 