import 'package:flutter_test/flutter_test.dart';
import 'package:devtrack_app/models/user.dart';
import 'package:devtrack_app/models/log_entry.dart';
import 'package:devtrack_app/models/project.dart';
import 'package:devtrack_app/models/task.dart';

void main() {
  group('User Model', () {
    test('fromJson creates valid user', () {
      final json = {
        'id': '123',
        'clerkId': 'clerk_123',
        'email': 'test@example.com',
        'name': 'Test User',
        'avatarUrl': 'https://example.com/avatar.png',
        'githubUsername': 'testuser',
        'createdAt': '2024-01-01T00:00:00.000Z',
        'hasCompletedOnboarding': true,
      };

      final user = User.fromJson(json);

      expect(user.id, '123');
      expect(user.email, 'test@example.com');
      expect(user.name, 'Test User');
      expect(user.githubUsername, 'testuser');
      expect(user.hasCompletedOnboarding, true);
    });

    test('toJson returns valid map', () {
      final user = User(
        id: '123',
        clerkId: 'clerk_123',
        email: 'test@example.com',
        name: 'Test User',
        createdAt: DateTime(2024, 1, 1),
      );

      final json = user.toJson();

      expect(json['id'], '123');
      expect(json['email'], 'test@example.com');
    });

    test('copyWith creates modified copy', () {
      final user = User(
        id: '123',
        clerkId: 'clerk_123',
        email: 'test@example.com',
        name: 'Test User',
        createdAt: DateTime.now(),
      );

      final updated = user.copyWith(name: 'Updated Name');

      expect(updated.name, 'Updated Name');
      expect(updated.email, user.email);
    });
  });

  group('LogEntry Model', () {
    test('fromJson creates valid log entry', () {
      final json = {
        'id': 'log_123',
        'userId': 'user_123',
        'date': '2024-01-01T00:00:00.000Z',
        'startTime': '09:00',
        'endTime': '11:00',
        'description': 'Learned Flutter',
        'tags': ['Flutter', 'Dart'],
        'mood': '😊',
        'createdAt': '2024-01-01T00:00:00.000Z',
      };

      final entry = LogEntry.fromJson(json);

      expect(entry.id, 'log_123');
      expect(entry.description, 'Learned Flutter');
      expect(entry.tags.length, 2);
      expect(entry.mood, '😊');
    });

    test('durationHours calculates correctly', () {
      final entry = LogEntry(
        id: 'log_123',
        userId: 'user_123',
        date: DateTime.now(),
        startTime: '09:00',
        endTime: '11:30',
        description: 'Test',
        createdAt: DateTime.now(),
      );

      expect(entry.durationHours, 2.5);
    });
  });

  group('Project Model', () {
    test('fromJson creates valid project', () {
      final json = {
        'id': 'proj_123',
        'userId': 'user_123',
        'name': 'My Project',
        'description': 'A test project',
        'githubUrl': 'https://github.com/test/repo',
        'languages': ['Dart', 'JavaScript'],
        'progress': 0.75,
        'createdAt': '2024-01-01T00:00:00.000Z',
      };

      final project = Project.fromJson(json);

      expect(project.id, 'proj_123');
      expect(project.name, 'My Project');
      expect(project.languages.length, 2);
      expect(project.progress, 0.75);
    });
  });

  group('Task Model', () {
    test('fromJson creates valid task', () {
      final json = {
        'id': 'task_123',
        'userId': 'user_123',
        'title': 'Complete feature',
        'dueDate': '2024-01-15T00:00:00.000Z',
        'priority': 'high',
        'isCompleted': false,
        'createdAt': '2024-01-01T00:00:00.000Z',
      };

      final task = Task.fromJson(json);

      expect(task.id, 'task_123');
      expect(task.title, 'Complete feature');
      expect(task.priority, TaskPriority.high);
      expect(task.isCompleted, false);
    });

    test('TaskPriority fromString works correctly', () {
      expect(TaskPriority.fromString('high'), TaskPriority.high);
      expect(TaskPriority.fromString('low'), TaskPriority.low);
      expect(TaskPriority.fromString('invalid'), TaskPriority.medium);
    });
  });
}
