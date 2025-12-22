import 'package:flutter_test/flutter_test.dart';
import 'package:devtrack_app/services/storage_service.dart';

void main() {
  group('StorageService', () {
    test('singleton returns same instance', () {
      final instance1 = StorageService();
      final instance2 = StorageService();
      expect(identical(instance1, instance2), true);
    });

    test('cache keys are defined', () {
      expect(StorageService.keyUserCache, 'cache_user');
      expect(StorageService.keyLogsCache, 'cache_logs');
      expect(StorageService.keyProjectsCache, 'cache_projects');
      expect(StorageService.keyTasksCache, 'cache_tasks');
    });
  });
}
