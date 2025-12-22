/// User model matching backend API response
class User {
  final String id;
  final String clerkId;
  final String email;
  final String name;
  final String? avatarUrl;
  final String? githubUsername;
  final DateTime createdAt;
  final bool hasCompletedOnboarding;

  const User({
    required this.id,
    required this.clerkId,
    required this.email,
    required this.name,
    this.avatarUrl,
    this.githubUsername,
    required this.createdAt,
    this.hasCompletedOnboarding = false,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? json['_id'] ?? '',
      clerkId: json['clerkId'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      avatarUrl: json['avatarUrl'] ?? json['avatar_url'],
      githubUsername: json['githubUsername'] ?? json['github_username'],
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
      hasCompletedOnboarding: json['hasCompletedOnboarding'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clerkId': clerkId,
      'email': email,
      'name': name,
      'avatarUrl': avatarUrl,
      'githubUsername': githubUsername,
      'createdAt': createdAt.toIso8601String(),
      'hasCompletedOnboarding': hasCompletedOnboarding,
    };
  }

  User copyWith({
    String? id,
    String? clerkId,
    String? email,
    String? name,
    String? avatarUrl,
    String? githubUsername,
    DateTime? createdAt,
    bool? hasCompletedOnboarding,
  }) {
    return User(
      id: id ?? this.id,
      clerkId: clerkId ?? this.clerkId,
      email: email ?? this.email,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      githubUsername: githubUsername ?? this.githubUsername,
      createdAt: createdAt ?? this.createdAt,
      hasCompletedOnboarding: hasCompletedOnboarding ?? this.hasCompletedOnboarding,
    );
  }
}
