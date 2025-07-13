class UserSocialProfile {
  final String id;
  final String userId;
  final String? displayName;
  final String? bio;
  final String? profilePictureUrl;
  final String? coverPhotoUrl;
  final String? cookingLevel;
  final List<String> favoriteCuisines;
  final List<String> cookingGoals;
  final List<String> dietaryPreferences;
  final String? location;
  final String? websiteUrl;
  final bool isPublic;
  final bool allowFriendRequests;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isCurrentUser;
  final bool isConnected;
  final bool hasRequestPending;

  UserSocialProfile({
    required this.id,
    required this.userId,
    this.displayName,
    this.bio,
    this.profilePictureUrl,
    this.coverPhotoUrl,
    this.cookingLevel,
    this.favoriteCuisines = const [],
    this.cookingGoals = const [],
    this.dietaryPreferences = const [],
    this.location,
    this.websiteUrl,
    this.isPublic = true,
    this.allowFriendRequests = true,
    required this.createdAt,
    required this.updatedAt,
    this.isCurrentUser = false,
    this.isConnected = false,
    this.hasRequestPending = false,
  });

  factory UserSocialProfile.fromJson(Map<String, dynamic> json) {
    return UserSocialProfile(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      displayName: json['display_name'],
      bio: json['bio'],
      profilePictureUrl: json['profile_picture_url'],
      coverPhotoUrl: json['cover_photo_url'],
      cookingLevel: json['cooking_level'],
      favoriteCuisines: List<String>.from(json['favorite_cuisines'] ?? []),
      cookingGoals: List<String>.from(json['cooking_goals'] ?? []),
      dietaryPreferences: List<String>.from(json['dietary_preferences'] ?? []),
      location: json['location'],
      websiteUrl: json['website_url'],
      isPublic: json['is_public'] ?? true,
      allowFriendRequests: json['allow_friend_requests'] ?? true,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
      isCurrentUser: json['is_current_user'] ?? false,
      isConnected: json['is_connected'] ?? false,
      hasRequestPending: json['has_request_pending'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'display_name': displayName,
      'bio': bio,
      'profile_picture_url': profilePictureUrl,
      'cover_photo_url': coverPhotoUrl,
      'cooking_level': cookingLevel,
      'favorite_cuisines': favoriteCuisines,
      'cooking_goals': cookingGoals,
      'dietary_preferences': dietaryPreferences,
      'location': location,
      'website_url': websiteUrl,
      'is_public': isPublic,
      'allow_friend_requests': allowFriendRequests,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_current_user': isCurrentUser,
      'is_connected': isConnected,
      'has_request_pending': hasRequestPending,
    };
  }

  UserSocialProfile copyWith({
    String? id,
    String? userId,
    String? displayName,
    String? bio,
    String? profilePictureUrl,
    String? coverPhotoUrl,
    String? cookingLevel,
    List<String>? favoriteCuisines,
    List<String>? cookingGoals,
    List<String>? dietaryPreferences,
    String? location,
    String? websiteUrl,
    bool? isPublic,
    bool? allowFriendRequests,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isCurrentUser,
    bool? isConnected,
    bool? hasRequestPending,
  }) {
    return UserSocialProfile(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      bio: bio ?? this.bio,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      coverPhotoUrl: coverPhotoUrl ?? this.coverPhotoUrl,
      cookingLevel: cookingLevel ?? this.cookingLevel,
      favoriteCuisines: favoriteCuisines ?? this.favoriteCuisines,
      cookingGoals: cookingGoals ?? this.cookingGoals,
      dietaryPreferences: dietaryPreferences ?? this.dietaryPreferences,
      location: location ?? this.location,
      websiteUrl: websiteUrl ?? this.websiteUrl,
      isPublic: isPublic ?? this.isPublic,
      allowFriendRequests: allowFriendRequests ?? this.allowFriendRequests,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isCurrentUser: isCurrentUser ?? this.isCurrentUser,
      isConnected: isConnected ?? this.isConnected,
      hasRequestPending: hasRequestPending ?? this.hasRequestPending,
    );
  }

  @override
  String toString() {
    return 'UserSocialProfile(id: $id, userId: $userId, displayName: $displayName)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserSocialProfile && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class ConnectionRequest {
  final String id;
  final String senderId;
  final String receiverId;
  final String status;
  final String? message;
  final DateTime createdAt;
  final DateTime? respondedAt;
  final UserSocialProfile? senderProfile;
  final UserSocialProfile? receiverProfile;

  ConnectionRequest({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.status,
    this.message,
    required this.createdAt,
    this.respondedAt,
    this.senderProfile,
    this.receiverProfile,
  });

  factory ConnectionRequest.fromJson(Map<String, dynamic> json) {
    return ConnectionRequest(
      id: json['id']?.toString() ?? '',
      senderId: json['sender_id']?.toString() ?? '',
      receiverId: json['receiver_id']?.toString() ?? '',
      status: json['status'] ?? 'pending',
      message: json['message'],
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      respondedAt: json['responded_at'] != null 
          ? DateTime.parse(json['responded_at'])
          : null,
      senderProfile: json['sender_profile'] != null 
          ? UserSocialProfile.fromJson(json['sender_profile'])
          : null,
      receiverProfile: json['receiver_profile'] != null 
          ? UserSocialProfile.fromJson(json['receiver_profile'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender_id': senderId,
      'receiver_id': receiverId,
      'status': status,
      'message': message,
      'created_at': createdAt.toIso8601String(),
      'responded_at': respondedAt?.toIso8601String(),
      'sender_profile': senderProfile?.toJson(),
      'receiver_profile': receiverProfile?.toJson(),
    };
  }

  bool get isPending => status == 'pending';
  bool get isAccepted => status == 'accepted';
  bool get isDeclined => status == 'declined';

  @override
  String toString() {
    return 'ConnectionRequest(id: $id, status: $status, senderId: $senderId, receiverId: $receiverId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ConnectionRequest && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class ActivityItem {
  final String id;
  final String userId;
  final String activityType;
  final Map<String, dynamic> activityData;
  final String privacyLevel;
  final DateTime createdAt;
  final UserSocialProfile? userProfile;

  ActivityItem({
    required this.id,
    required this.userId,
    required this.activityType,
    required this.activityData,
    required this.privacyLevel,
    required this.createdAt,
    this.userProfile,
  });

  factory ActivityItem.fromJson(Map<String, dynamic> json) {
    return ActivityItem(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      activityType: json['activity_type'] ?? '',
      activityData: Map<String, dynamic>.from(json['activity_data'] ?? {}),
      privacyLevel: json['privacy_level'] ?? 'friends',
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      userProfile: json['user_profile'] != null 
          ? UserSocialProfile.fromJson(json['user_profile'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'activity_type': activityType,
      'activity_data': activityData,
      'privacy_level': privacyLevel,
      'created_at': createdAt.toIso8601String(),
      'user_profile': userProfile?.toJson(),
    };
  }

  bool get isPublic => privacyLevel == 'public';
  bool get isFriendsOnly => privacyLevel == 'friends';
  bool get isPrivate => privacyLevel == 'private';

  @override
  String toString() {
    return 'ActivityItem(id: $id, activityType: $activityType, userId: $userId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ActivityItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class SearchUsersResult {
  final List<UserSocialProfile> users;
  final int totalCount;
  final int page;
  final int totalPages;

  SearchUsersResult({
    required this.users,
    required this.totalCount,
    required this.page,
    required this.totalPages,
  });

  factory SearchUsersResult.fromJson(Map<String, dynamic> json) {
    return SearchUsersResult(
      users: (json['users'] as List<dynamic>? ?? [])
          .map((user) => UserSocialProfile.fromJson(user))
          .toList(),
      totalCount: json['total_count'] ?? 0,
      page: json['page'] ?? 1,
      totalPages: json['total_pages'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'users': users.map((user) => user.toJson()).toList(),
      'total_count': totalCount,
      'page': page,
      'total_pages': totalPages,
    };
  }
}

class ActivityFeedResult {
  final List<ActivityItem> activities;
  final int totalCount;
  final int page;
  final int totalPages;

  ActivityFeedResult({
    required this.activities,
    required this.totalCount,
    required this.page,
    required this.totalPages,
  });

  factory ActivityFeedResult.fromJson(Map<String, dynamic> json) {
    return ActivityFeedResult(
      activities: (json['activities'] as List<dynamic>? ?? [])
          .map((activity) => ActivityItem.fromJson(activity))
          .toList(),
      totalCount: json['total_count'] ?? 0,
      page: json['page'] ?? 1,
      totalPages: json['total_pages'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'activities': activities.map((activity) => activity.toJson()).toList(),
      'total_count': totalCount,
      'page': page,
      'total_pages': totalPages,
    };
  }
}

class ConnectionsResult {
  final List<UserSocialProfile> connections;
  final int totalCount;
  final int page;
  final int totalPages;

  ConnectionsResult({
    required this.connections,
    required this.totalCount,
    required this.page,
    required this.totalPages,
  });

  factory ConnectionsResult.fromJson(Map<String, dynamic> json) {
    return ConnectionsResult(
      connections: (json['connections'] as List<dynamic>? ?? [])
          .map((connection) => UserSocialProfile.fromJson(connection))
          .toList(),
      totalCount: json['total_count'] ?? 0,
      page: json['page'] ?? 1,
      totalPages: json['total_pages'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'connections': connections.map((connection) => connection.toJson()).toList(),
      'total_count': totalCount,
      'page': page,
      'total_pages': totalPages,
    };
  }
} 