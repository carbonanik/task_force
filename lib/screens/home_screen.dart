import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:task_ring/models/todo.dart';
import 'package:task_ring/providers/todo_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:task_ring/providers/theme_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    if (!await FlutterOverlayWindow.isPermissionGranted()) {
      await FlutterOverlayWindow.requestPermission();
    }
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
  }

  void _addTodo(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddTodoBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final todos = ref.watch(todoListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Task Ring',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          PopupMenuButton<AppThemeMode>(
            icon: const Icon(Icons.palette_outlined),
            tooltip: 'Change Theme',
            onSelected: (AppThemeMode mode) {
              ref.read(themeProvider.notifier).setTheme(mode);
            },
            itemBuilder: (context) => [
              _buildThemeMenuItem(
                AppThemeMode.light,
                Icons.light_mode,
                'Light',
              ),
              _buildThemeMenuItem(AppThemeMode.dark, Icons.dark_mode, 'Dark'),
              _buildThemeMenuItem(AppThemeMode.nature, Icons.eco, 'Nature'),
              _buildThemeMenuItem(AppThemeMode.ocean, Icons.water, 'Ocean'),
            ],
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.surface,
              Theme.of(context).colorScheme.surface.withOpacity(0.8),
            ],
          ),
        ),
        child: todos.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.task_alt_rounded,
                      size: 100,
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.2),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No tasks scheduled',
                      style: TextStyle(
                        fontSize: 18,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.5),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: todos.length,
                itemBuilder: (context, index) {
                  final todo = todos[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Card(
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        title: Text(
                          todo.title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            decoration: todo.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                            color: todo.isCompleted
                                ? Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withOpacity(0.5)
                                : Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        subtitle: Row(
                          children: [
                            Icon(
                              Icons.access_time_filled_rounded,
                              size: 14,
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withOpacity(0.7),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              DateFormat(
                                'MMM d, HH:mm',
                              ).format(todo.scheduledTime),
                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                        trailing: Checkbox(
                          value: todo.isCompleted,
                          activeColor: Theme.of(context).colorScheme.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          onChanged: (value) {
                            ref
                                .read(todoListProvider.notifier)
                                .toggleTodo(todo.id);
                          },
                        ),
                        onLongPress: () {
                          _showDeleteConfirm(context, todo);
                        },
                      ),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addTodo(context),
        label: const Text('Add Task'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  PopupMenuItem<AppThemeMode> _buildThemeMenuItem(
    AppThemeMode mode,
    IconData icon,
    String label,
  ) {
    return PopupMenuItem(
      value: mode,
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 12),
          Text(label),
        ],
      ),
    );
  }

  void _showDeleteConfirm(BuildContext context, Todo todo) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: Text('Are you sure you want to delete "${todo.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(todoListProvider.notifier).deleteTodo(todo.id);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class AddTodoBottomSheet extends ConsumerStatefulWidget {
  const AddTodoBottomSheet({super.key});

  @override
  ConsumerState<AddTodoBottomSheet> createState() => _AddTodoBottomSheetState();
}

class _AddTodoBottomSheetState extends ConsumerState<AddTodoBottomSheet> {
  final _titleController = TextEditingController();
  DateTime _scheduledTime = DateTime.now().add(const Duration(minutes: 5));

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _scheduledTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(
            context,
          ).copyWith(colorScheme: Theme.of(context).colorScheme),
          child: child!,
        );
      },
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_scheduledTime),
    );
    if (time == null) return;

    setState(() {
      _scheduledTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Schedule New Task',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _titleController,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'What needs to be done?',
              filled: true,
              fillColor: Theme.of(
                context,
              ).colorScheme.surfaceVariant.withOpacity(0.3),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              prefixIcon: const Icon(Icons.edit_note_rounded),
            ),
          ),
          const SizedBox(height: 20),
          InkWell(
            onTap: _pickDateTime,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Scheduled for',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                      Text(
                        DateFormat(
                          'EEEE, MMM d @ HH:mm',
                        ).format(_scheduledTime),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.3),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              if (_titleController.text.isNotEmpty) {
                final todo = Todo(
                  title: _titleController.text,
                  scheduledTime: _scheduledTime,
                );
                ref.read(todoListProvider.notifier).addTodo(todo);
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 60),
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              elevation: 4,
              shadowColor: Theme.of(
                context,
              ).colorScheme.primary.withOpacity(0.4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            child: const Text(
              'Schedule Task',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
