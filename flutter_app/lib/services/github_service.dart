import '../config/api_config.dart';
import 'api_service.dart';

/// Service for GitHub-related operations
class GitHubService {
  final ApiService _api = ApiService();

  /// Get GitHub profile
  Future<GitHubProfile> getProfile() async {
    try {
      final response = await _api.get(ApiEndpoints.githubProfile);
      return GitHubProfile.fromJson(response.data);
    } catch (e) {
      print('Error fetching GitHub profile: $e');
      rethrow;
    }
  }

  /// Get user's repositories
  Future<List<GitHubRepo>> getRepositories() async {
    try {
      final response = await _api.get(ApiEndpoints.githubRepos);
      final List<dynamic> data = response.data['repos'] ?? response.data ?? [];
      return data.map((e) => GitHubRepo.fromJson(e)).toList();
    } catch (e) {
      print('Error fetching repositories: $e');
      rethrow;
    }
  }

  /// Get programming languages used
  Future<Map<String, int>> getLanguages() async {
    try {
      final response = await _api.get(ApiEndpoints.githubLanguages);
      return Map<String, int>.from(response.data);
    } catch (e) {
      print('Error fetching languages: $e');
      rethrow;
    }
  }

  /// Analyze a specific repository
  Future<RepoAnalysis> analyzeRepo(String owner, String repo) async {
    try {
      final response = await _api.get(ApiEndpoints.githubRepo(owner, repo));
      return RepoAnalysis.fromJson(response.data);
    } catch (e) {
      print('Error analyzing repo $owner/$repo: $e');
      rethrow;
    }
  }

  /// Get recent GitHub activity
  Future<List<GitHubActivity>> getActivity() async {
    try {
      final response = await _api.get(ApiEndpoints.githubActivity);
      final List<dynamic> data = response.data['activity'] ?? response.data ?? [];
      return data.map((e) => GitHubActivity.fromJson(e)).toList();
    } catch (e) {
      print('Error fetching activity: $e');
      rethrow;
    }
  }

  /// Get commit history
  Future<List<GitHubCommit>> getCommits({int limit = 20}) async {
    try {
      final response = await _api.get(
        ApiEndpoints.githubCommits,
        queryParameters: {'limit': limit},
      );
      final List<dynamic> data = response.data['commits'] ?? response.data ?? [];
      return data.map((e) => GitHubCommit.fromJson(e)).toList();
    } catch (e) {
      print('Error fetching commits: $e');
      rethrow;
    }
  }
}

// ==================== MODELS ====================

class GitHubProfile {
  final String login;
  final String name;
  final String? avatarUrl;
  final String? bio;
  final int publicRepos;
  final int followers;
  final int following;

  const GitHubProfile({
    required this.login,
    required this.name,
    this.avatarUrl,
    this.bio,
    this.publicRepos = 0,
    this.followers = 0,
    this.following = 0,
  });

  factory GitHubProfile.fromJson(Map<String, dynamic> json) {
    return GitHubProfile(
      login: json['login'] ?? '',
      name: json['name'] ?? json['login'] ?? '',
      avatarUrl: json['avatar_url'] ?? json['avatarUrl'],
      bio: json['bio'],
      publicRepos: json['public_repos'] ?? json['publicRepos'] ?? 0,
      followers: json['followers'] ?? 0,
      following: json['following'] ?? 0,
    );
  }
}

class GitHubRepo {
  final String name;
  final String fullName;
  final String? description;
  final String htmlUrl;
  final String? language;
  final int stars;
  final int forks;
  final bool isPrivate;
  final DateTime? updatedAt;

  const GitHubRepo({
    required this.name,
    required this.fullName,
    this.description,
    required this.htmlUrl,
    this.language,
    this.stars = 0,
    this.forks = 0,
    this.isPrivate = false,
    this.updatedAt,
  });

  factory GitHubRepo.fromJson(Map<String, dynamic> json) {
    return GitHubRepo(
      name: json['name'] ?? '',
      fullName: json['full_name'] ?? json['fullName'] ?? '',
      description: json['description'],
      htmlUrl: json['html_url'] ?? json['htmlUrl'] ?? '',
      language: json['language'],
      stars: json['stargazers_count'] ?? json['stars'] ?? 0,
      forks: json['forks_count'] ?? json['forks'] ?? 0,
      isPrivate: json['private'] ?? json['isPrivate'] ?? false,
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : null,
    );
  }
}

class RepoAnalysis {
  final String name;
  final List<String> languages;
  final int commits;
  final int contributors;
  final Map<String, int> commitPatterns;
  final List<String> technologies;

  const RepoAnalysis({
    required this.name,
    this.languages = const [],
    this.commits = 0,
    this.contributors = 0,
    this.commitPatterns = const {},
    this.technologies = const [],
  });

  factory RepoAnalysis.fromJson(Map<String, dynamic> json) {
    return RepoAnalysis(
      name: json['name'] ?? '',
      languages: json['languages'] != null 
          ? List<String>.from(json['languages']) 
          : [],
      commits: json['commits'] ?? 0,
      contributors: json['contributors'] ?? 0,
      commitPatterns: json['commitPatterns'] != null 
          ? Map<String, int>.from(json['commitPatterns']) 
          : {},
      technologies: json['technologies'] != null 
          ? List<String>.from(json['technologies']) 
          : [],
    );
  }
}

class GitHubActivity {
  final String type;
  final String repo;
  final String? message;
  final DateTime createdAt;

  const GitHubActivity({
    required this.type,
    required this.repo,
    this.message,
    required this.createdAt,
  });

  factory GitHubActivity.fromJson(Map<String, dynamic> json) {
    return GitHubActivity(
      type: json['type'] ?? '',
      repo: json['repo'] ?? '',
      message: json['message'],
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
    );
  }
}

class GitHubCommit {
  final String sha;
  final String message;
  final String repo;
  final DateTime committedAt;

  const GitHubCommit({
    required this.sha,
    required this.message,
    required this.repo,
    required this.committedAt,
  });

  factory GitHubCommit.fromJson(Map<String, dynamic> json) {
    return GitHubCommit(
      sha: json['sha'] ?? '',
      message: json['message'] ?? '',
      repo: json['repo'] ?? '',
      committedAt: json['committed_at'] != null 
          ? DateTime.parse(json['committed_at']) 
          : DateTime.now(),
    );
  }
}
