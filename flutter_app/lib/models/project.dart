/// Project model matching backend API
class Project {
  final String id;
  final String userId;
  final String name;
  final String? description;
  final String? githubUrl;
  final List<String> languages;
  final double progress;
  final ProjectAnalysis? aiAnalysis;
  final ProjectStats stats;
  final String status;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Project({
    required this.id,
    required this.userId,
    required this.name,
    this.description,
    this.githubUrl,
    this.languages = const [],
    this.progress = 0,
    this.aiAnalysis,
    this.stats = const ProjectStats(),
    this.status = 'Planning',
    required this.createdAt,
    this.updatedAt,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'] ?? json['_id'] ?? '',
      userId: json['userId'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      githubUrl: json['githubUrl'],
      languages:
          json['languages'] != null ? List<String>.from(json['languages']) : [],
      progress: (json['progress'] ?? 0).toDouble(),
      aiAnalysis: json['aiAnalysis'] != null
          ? ProjectAnalysis.fromJson(json['aiAnalysis'])
          : null,
      stats: json['stats'] != null
          ? ProjectStats.fromJson(json['stats'])
          : const ProjectStats(),
      status: json['status'] ?? 'Planning',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'description': description,
      'githubUrl': githubUrl,
      'languages': languages,
      'progress': progress,
      'aiAnalysis': aiAnalysis?.toJson(),
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  Map<String, dynamic> toRequestBody() {
    return {
      'name': name,
      'description': description,
      'githubUrl': githubUrl,
    };
  }

  Project copyWith({
    String? id,
    String? userId,
    String? name,
    String? description,
    String? githubUrl,
    List<String>? languages,
    double? progress,
    ProjectAnalysis? aiAnalysis,
    ProjectStats? stats,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Project(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: description ?? this.description,
      githubUrl: githubUrl ?? this.githubUrl,
      languages: languages ?? this.languages,
      progress: progress ?? this.progress,
      aiAnalysis: aiAnalysis ?? this.aiAnalysis,
      stats: stats ?? this.stats,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class ProjectAnalysis {
  final String summary;
  final List<String> strengths;
  final List<String> suggestions;
  final String overallRating;

  const ProjectAnalysis({
    this.summary = '',
    this.strengths = const [],
    this.suggestions = const [],
    this.overallRating = '',
  });

  factory ProjectAnalysis.fromJson(Map<String, dynamic> json) {
    return ProjectAnalysis(
      summary: json['summary'] ?? '',
      strengths:
          json['strengths'] != null ? List<String>.from(json['strengths']) : [],
      suggestions: json['suggestions'] != null
          ? List<String>.from(json['suggestions'])
          : [],
      overallRating: json['overallRating'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'summary': summary,
      'strengths': strengths,
      'suggestions': suggestions,
      'overallRating': overallRating,
    };
  }
}

class ProjectStats {
  final int commits;
  final int pullRequests;
  final int issues;
  final int stars;
  final int forks;

  const ProjectStats({
    this.commits = 0,
    this.pullRequests = 0,
    this.issues = 0,
    this.stars = 0,
    this.forks = 0,
  });

  factory ProjectStats.fromJson(Map<String, dynamic> json) {
    return ProjectStats(
      commits: json['commits'] ?? 0,
      pullRequests: json['pullRequests'] ?? json['prs'] ?? 0,
      issues: json['issues'] ?? 0,
      stars: json['stars'] ?? 0,
      forks: json['forks'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'commits': commits,
      'pullRequests': pullRequests,
      'issues': issues,
      'stars': stars,
      'forks': forks,
    };
  }
}
