import 'package:hive/hive.dart';

abstract class CustomTasksDataSource {
  Future<void> init();
  Future<List<String>> getCustomTasks();
  Future<void> addCustomTask(String title);
  Future<void> removeCustomTask(String title);
}

class CustomTasksDataSourceImpl implements CustomTasksDataSource {
  static const String _boxName = 'custom_worship_tasks_box';
  static const String _key = 'custom_tasks_list';

  late Box _box;

  @override
  Future<void> init() async {
    _box = await Hive.openBox(_boxName);
  }

  @override
  Future<List<String>> getCustomTasks() async {
    final list = _box.get(_key, defaultValue: <String>[]);
    if (list is List) {
      return list.cast<String>();
    }
    return [];
  }

  @override
  Future<void> addCustomTask(String title) async {
    final currentList = await getCustomTasks();
    if (!currentList.contains(title)) {
      currentList.add(title);
      await _box.put(_key, currentList);
    }
  }

  @override
  Future<void> removeCustomTask(String title) async {
    final currentList = await getCustomTasks();
    if (currentList.contains(title)) {
      currentList.remove(title);
      await _box.put(_key, currentList);
    }
  }
}
