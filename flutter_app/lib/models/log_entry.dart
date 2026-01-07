/// Learning log entry model matching backend API
class LogEntry {
  final String id;
  final String userId;
  final DateTime date;
  final String? startTime;
  final String? endTime;
  final String description;
  final List<String> tags;
  final String mood;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const LogEntry({
    required this.id,
    required this.userId,
    required this.date,
    this.startTime,
    this.endTime,
    required this.description,
    this.tags = const [],
    this.mood = '😊',
    required this.createdAt,
    this.updatedAt,
  });

  /// Calculate duration in hours
  double get durationHours {
    if (startTime == null || endTime == null) return 0;
    try {
      final start = _parseTime(startTime!);
      final end = _parseTime(endTime!);
      final diff = end.difference(start);
      return diff.inMinutes / 60;
    } catch (_) {
      return 0;
    }
  }

  DateTime _parseTime(String time) {
    final parts = time.split(':');
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, 
        int.parse(parts[0]), int.parse(parts[1]));
  }

  factory LogEntry.fromJson(Map<String, dynamic> json) {
    // Parse date - handle different formats
    DateTime parseDate(dynamic dateValue) {
      if (dateValue == null) return DateTime.now();
      if (dateValue is String) {
        return DateTime.tryParse(dateValue) ?? DateTime.now();
      }
      // Handle Firestore timestamp
      if (dateValue is Map && dateValue['_seconds'] != null) {
        return DateTime.fromMillisecondsSinceEpoch(dateValue['_seconds'] * 1000);
      }
      return DateTime.now();
    }
    
    return LogEntry(
      id: json['id'] ?? json['_id'] ?? '',
      // Server uses 'uid' not 'userId'
      userId: json['uid'] ?? json['userId'] ?? '',
      date: parseDate(json['date']),
      startTime: json['startTime'],
      endTime: json['endTime'],
      // Server uses 'learnedToday' for description
      description: json['learnedToday'] ?? json['description'] ?? '',
      tags: json['tags'] != null 
          ? List<String>.from(json['tags']) 
          : [],
      // Server uses string mood like 'good', 'great', etc. - convert or keep as is
      mood: _convertMood(json['mood']),
      createdAt: parseDate(json['createdAt']),
      updatedAt: json['updatedAt'] != null 
          ? parseDate(json['updatedAt'])
          : null,
    );
  }
  
  /// Convert server mood strings to emoji
  static String _convertMood(dynamic mood) {
    if (mood == null) return '😊';
    if (mood is String) {
      switch (mood.toLowerCase()) {
        case 'great':
          return '🚀';
        case 'good':
          return '😊';
        case 'okay':
          return '😐';
        case 'bad':
          return '😕';
        case 'terrible':
          return '😫';
        default:
          // If it's already an emoji, return it
          if (mood.contains(RegExp(r'[\u{1F600}-\u{1F64F}]', unicode: true))) {
            return mood;
          }
          return '😊';
      }
    }
    return '😊';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'date': date.toIso8601String(),
      'startTime': startTime,
      'endTime': endTime,
      'description': description,
      'tags': tags,
      'mood': mood,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Convert to request body for create/update - matches server API
  Map<String, dynamic> toRequestBody() {
    return {
      'date': date.toIso8601String().split('T')[0],
      'startTime': startTime,
      'endTime': endTime,
      // Server expects 'learnedToday' not 'description'
      'learnedToday': description,
      'tags': tags,
      // Convert emoji mood back to string for server
      'mood': _moodToString(mood),
    };
  }
  
  /// Convert emoji mood to string for server
  static String _moodToString(String emoji) {
    switch (emoji) {
      case '🚀':
        return 'great';
      case '😊':
        return 'good';
      case '😐':
        return 'okay';
      case '😕':
        return 'bad';
      case '😫':
        return 'terrible';
      default:
        return 'good';
    }
  }

  LogEntry copyWith({
    String? id,
    String? userId,
    DateTime? date,
    String? startTime,
    String? endTime,
    String? description,
    List<String>? tags,
    String? mood,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LogEntry(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      description: description ?? this.description,
      tags: tags ?? this.tags,
      mood: mood ?? this.mood,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Stats response for learning logs
class LogStats {
  final int totalEntries;
  final int currentStreak;
  final int longestStreak;
  final double totalHours;
  final int uniqueDays;
  final int weeklyGrowth;
  final Map<String, int> tagCounts;
  final List<DailyActivity> weeklyActivity;
  final List<Map<String, dynamic>> topTags;

  const LogStats({
    this.totalEntries = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.totalHours = 0,
    this.uniqueDays = 0,
    this.weeklyGrowth = 0,
    this.tagCounts = const {},
    this.weeklyActivity = const [],
    this.topTags = const [],
  });

  factory LogStats.fromJson(Map<String, dynamic> json) {
    // Handle top tags from server
    List<Map<String, dynamic>> topTagsList = [];
    if (json['topTags'] != null && json['topTags'] is List) {
      topTagsList = (json['topTags'] as List)
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    
    // Convert topTags to tagCounts map
    Map<String, int> tagCountsMap = {};
    for (var tag in topTagsList) {
      if (tag['tag'] != null && tag['count'] != null) {
        tagCountsMap[tag['tag']] = tag['count'];
      }
    }
    
    return LogStats(
      // Server uses 'totalLogs', fallback to 'totalEntries'
      totalEntries: json['totalLogs'] ?? json['totalEntries'] ?? 0,
      currentStreak: json['currentStreak'] ?? 0,
      // Server doesn't provide longest streak yet, use currentStreak as fallback
      longestStreak: json['longestStreak'] ?? json['currentStreak'] ?? 0,
      // Server doesn't provide totalHours yet
      totalHours: (json['totalHours'] ?? 0).toDouble(),
      uniqueDays: json['uniqueDays'] ?? 0,
      weeklyGrowth: json['weeklyGrowth'] ?? 0,
      tagCounts: tagCountsMap,
      topTags: topTagsList,
      weeklyActivity: json['weeklyActivity'] != null
          ? (json['weeklyActivity'] as List)
              .map((e) => DailyActivity.fromJson(e))
              .toList()
          : [],
    );
  }
}

class DailyActivity {
  final String day;
  final double hours;
  final int entries;

  const DailyActivity({
    required this.day,
    this.hours = 0,
    this.entries = 0,
  });

  factory DailyActivity.fromJson(Map<String, dynamic> json) {
    return DailyActivity(
      day: json['day'] ?? '',
      hours: (json['hours'] ?? 0).toDouble(),
      entries: json['entries'] ?? 0,
    );
  }
}
