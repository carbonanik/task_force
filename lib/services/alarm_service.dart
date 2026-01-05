import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:task_ring/models/todo.dart';

@pragma('vm:entry-point')
class AlarmService {
  static Future<void> init() async {
    await AndroidAlarmManager.initialize();
  }

  static Future<void> scheduleAlarm(Todo todo) async {
    if (todo.isCompleted) return;
    if (todo.scheduledTime.isBefore(DateTime.now())) return;

    await AndroidAlarmManager.oneShotAt(
      todo.scheduledTime,
      todo.id.hashCode,
      alarmCallback,
      exact: true,
      wakeup: true,
      rescheduleOnReboot: true,
      params: {'todoId': todo.id, 'title': todo.title},
    );
  }

  static Future<void> cancelAlarm(Todo todo) async {
    await AndroidAlarmManager.cancel(todo.id.hashCode);
  }
}

@pragma('vm:entry-point')
void alarmCallback(int id, Map<String, dynamic> params) async {
  final String title = params['title'] ?? 'Task Reminder';

  debugPrint("Alarm fired for: $title");

  if (await FlutterOverlayWindow.isPermissionGranted()) {
    await FlutterOverlayWindow.showOverlay(
      enableDrag: true,
      flag: OverlayFlag.defaultFlag,
      alignment: OverlayAlignment.center,
      height: WindowSize.matchParent,
      width: WindowSize.matchParent,
      overlayTitle: title,
      overlayContent: "It's time for your task!",
    );
  } else {
    debugPrint("Overlay permission not granted");
  }
}
