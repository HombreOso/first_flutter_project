import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/scheduled_task.dart';

class FavoriteMealsNotifier extends StateNotifier<List<ScheduledTask>> {
  FavoriteMealsNotifier() : super([]);

  bool toggleMealFavoriteStatus(ScheduledTask scheduledTask) {
    final scheduledTaskIsFavorite = state.contains(scheduledTask);

    if (scheduledTaskIsFavorite) {
      state = state.where((m) => m.id != scheduledTask.id).toList();
      return false;
    } else {
      state = [...state, scheduledTask];
      return true;
    }
  }
}

final favoriteMealsProvider =
    StateNotifierProvider<FavoriteMealsNotifier, List<ScheduledTask>>((ref) {
  return FavoriteMealsNotifier();
});
