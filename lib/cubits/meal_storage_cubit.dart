import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/meal.dart';
import '../services/storage_service.dart';
import '../widgets/meal_list.dart';
import 'states/meal_storage_state.dart';

class MealStorageCubit extends Cubit<MealStorageState> {
  final StorageService storageService;

  MealStorageCubit({required this.storageService})
      : super(MealStorageInitial()) {
    loadMeals();
  }

  void loadMeals() {
    emit(MealStorageLoading());
    storageService.getMeals().then(
      (meals) {
        final totalCalories = meals.fold(0, (sum, meal) => sum + meal.calories);
        emit(MealStorageLoaded(
          meals: meals,
          sortOption: SortOption.time,
          totalCalories: totalCalories,
        ));
      },
      onError: (e) => emit(MealStorageError('Failed to load meals: $e')),
    );
  }

  void addMeal(Meal meal) {
    if (state is MealStorageLoaded) {
      final currentState = state as MealStorageLoaded;
      // Optimistically update the UI
      emit(MealStorageLoaded(
        meals: [...currentState.meals, meal],
        sortOption: currentState.sortOption,
        totalCalories: currentState.totalCalories + meal.calories,
      ));
    }

    // Save to storage
    storageService.addMeal(meal).then(
      (_) {
        // Reload meals to ensure consistency
        loadMeals();
      },
      onError: (e) {
        // Revert optimistic update on error
        loadMeals();
        emit(MealStorageError('Failed to add meal: $e'));
      },
    );
  }

  void deleteMeal(String id) {
    if (state is MealStorageLoaded) {
      final currentState = state as MealStorageLoaded;
      final mealToDelete = currentState.meals.firstWhere((m) => m.id == id);
      // Optimistically update the UI
      emit(MealStorageLoaded(
        meals: currentState.meals.where((m) => m.id != id).toList(),
        sortOption: currentState.sortOption,
        totalCalories: currentState.totalCalories - mealToDelete.calories,
      ));
    }

    // Delete from storage
    storageService.deleteMeal(id).then(
      (_) {
        // Reload meals to ensure consistency
        loadMeals();
      },
      onError: (e) {
        // Revert optimistic update on error
        loadMeals();
        emit(MealStorageError('Failed to delete meal: $e'));
      },
    );
  }

  void updateSortOption(SortOption sortOption) {
    if (state is MealStorageLoaded) {
      final currentState = state as MealStorageLoaded;
      final sortedMeals = _getSortedMeals(currentState.meals, sortOption);
      emit(MealStorageLoaded(
        meals: sortedMeals,
        sortOption: sortOption,
        totalCalories: currentState.totalCalories,
      ));
    }
  }

  List<Meal> _getSortedMeals(List<Meal> meals, SortOption sortOption) {
    final sortedMeals = List<Meal>.from(meals);
    switch (sortOption) {
      case SortOption.name:
        sortedMeals.sort((a, b) => a.name.compareTo(b.name));
        break;
      case SortOption.calories:
        sortedMeals.sort((a, b) => b.calories.compareTo(a.calories));
        break;
      case SortOption.time:
        sortedMeals.sort((a, b) => b.time.compareTo(a.time));
        break;
    }
    return sortedMeals;
  }
}
