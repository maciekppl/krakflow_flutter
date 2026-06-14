import 'task_api_services.dart';
import 'task_local_database.dart';

class TaskSyncService {
  static Future<void> loadInitialDataIfNeeded() async {
    if (!TaskLocalDatabase.isEmpty()) {
      return;
    }

    try {
      final tasks = await TaskApiService.fetchTasks();
      await TaskLocalDatabase.saveTasks(tasks);
    } catch (_) {
      // Przy braku internetu aplikacja zostaje przy danych lokalnych.
    }
  }
}
