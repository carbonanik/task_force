import 'package:hive/hive.dart';
import 'package:task_ring/models/todo.dart';

class TodoRepository {
  static const String boxName = 'todos';

  Future<Box<Todo>> _openBox() async {
    return await Hive.openBox<Todo>(boxName);
  }

  Future<List<Todo>> getTodos() async {
    final box = await _openBox();
    return box.values.toList();
  }

  Future<void> addTodo(Todo todo) async {
    final box = await _openBox();
    await box.put(todo.id, todo);
  }

  Future<void> updateTodo(Todo todo) async {
    final box = await _openBox();
    await box.put(todo.id, todo);
  }

  Future<void> deleteTodo(String id) async {
    final box = await _openBox();
    await box.delete(id);
  }
}
