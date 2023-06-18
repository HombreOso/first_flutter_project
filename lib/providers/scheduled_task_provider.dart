import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/scheduled_task.dart';

class ScheduledTasksNotifier extends StateNotifier<List<ScheduledTask>> {
  ScheduledTasksNotifier() : super([]);

  bool toggleScheduledTasksStatus(ScheduledTask scheduledTask) {
    final scheduledTaskIs = state.contains(scheduledTask);

    if (scheduledTaskIs) {
      state = state.where((m) => m.id != scheduledTask.id).toList();
      return false;
    } else {
      state = [...state, scheduledTask];
      return true;
    }
  }
}

final scheduledTasksProvider =
    StateNotifierProvider<ScheduledTasksNotifier, List<ScheduledTask>>((ref) {
  return ScheduledTasksNotifier();
});
