import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:task_ring/models/todo.dart';
import 'package:task_ring/screens/home_screen.dart';
import 'package:task_ring/services/alarm_service.dart';
import 'package:task_ring/widgets/overlay_screen.dart';
import 'package:task_ring/providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(TodoAdapter());
  }

  await AlarmService.init();

  runApp(const ProviderScope(child: MyApp()));
}

@pragma("vm:entry-point")
void overlayMain() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const MaterialApp(debugShowCheckedModeBanner: false, home: OverlayWidget()),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final themeData = ref.read(themeProvider.notifier).getThemeData(themeMode);

    return MaterialApp(
      title: 'Task Ring',
      debugShowCheckedModeBanner: false,
      theme: themeData,
      home: const HomeScreen(),
    );
  }
}
