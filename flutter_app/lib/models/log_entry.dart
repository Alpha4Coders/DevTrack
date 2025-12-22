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
    return LogEntry(
      id: json['id'] ?? json['_id'] ?? '',
      userId: json['userId'] ?? '',
      date: json['date'] != null 
          ? DateTime.parse(json['date']) 
          : DateTime.now(),
      startTime: json['startTime'],
      endTime: json['endTime'],
      description: json['description'] ?? '',
      tags: json['tags'] != null 
          ? List<String>.from(json['tags']) 
          : [],
      mood: json['mood'] ?? '😊',
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : null,
    );
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

  /// Convert to request body for create/update
  Map<String, dynamic> toRequestBody() {
    return {
      'date': date.toIso8601String().split('T')[0],
      'startTime': startTime,
      'endTime': endTime,
      'description': description,
      'tags': tags,
      'mood': mood,
    };
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
  final Map<String, int> tagCounts;
  final List<DailyActivity> weeklyActivity;

  const LogStats({
    this.totalEntries = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.totalHours = 0,
    this.tagCounts = const {},
    this.weeklyActivity = const [],
  });

  factory LogStats.fromJson(Map<String, dynamic> json) {
    return LogStats(
      totalEntries: json['totalEntries'] ?? 0,
      currentStreak: json['currentStreak'] ?? 0,
      longestStreak: json['longestStreak'] ?? 0,
      totalHours: (json['totalHours'] ?? 0).toDouble(),
      tagCounts: json['tagCounts'] != null 
          ? Map<String, int>.from(json['tagCounts']) 
          : {},
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
