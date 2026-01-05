import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'todo.g.dart';

@HiveType(typeId: 0)
class Todo extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final DateTime scheduledTime;

  @HiveField(4)
  final bool isCompleted;

  Todo({
    String? id,
    required this.title,
    this.description = '',
    required this.scheduledTime,
    this.isCompleted = false,
  }) : id = id ?? const Uuid().v4();

  Todo copyWith({
    String? title,
    String? description,
    DateTime? scheduledTime,
    bool? isCompleted,
  }) {
    return Todo(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
