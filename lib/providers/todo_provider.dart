import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_ring/models/todo.dart';
import 'package:task_ring/repositories/todo_repository.dart';
import 'package:task_ring/services/alarm_service.dart';

final todoRepositoryProvider = Provider((ref) => TodoRepository());

final todoListProvider = NotifierProvider<TodoNotifier, List<Todo>>(() {
  return TodoNotifier();
});

class TodoNotifier extends Notifier<List<Todo>> {
  TodoRepository get _repository => ref.read(todoRepositoryProvider);

  @override
  List<Todo> build() {
    _loadInitial();
    return [];
  }

  Future<void> _loadInitial() async {
    state = await _repository.getTodos();
  }

  Future<void> addTodo(Todo todo) async {
    await _repository.addTodo(todo);
    await AlarmService.scheduleAlarm(todo);
    state = [...state, todo];
  }

  Future<void> toggleTodo(String id) async {
    final todo = state.firstWhere((t) => t.id == id);
    final updated = todo.copyWith(isCompleted: !todo.isCompleted);
    await _repository.updateTodo(updated);
    if (updated.isCompleted) {
      await AlarmService.cancelAlarm(updated);
    } else {
      await AlarmService.scheduleAlarm(updated);
    }
    state = [
      for (final t in state)
        if (t.id == id) updated else t,
    ];
  }

  Future<void> deleteTodo(String id) async {
    final todo = state.firstWhere((t) => t.id == id);
    await _repository.deleteTodo(id);
    await AlarmService.cancelAlarm(todo);
    state = state.where((t) => t.id != id).toList();
  }
}
