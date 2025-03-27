import '../../models/meal.dart';
import '../../widgets/meal_list.dart';

abstract class MealStorageState {}

class MealStorageInitial extends MealStorageState {}

class MealStorageLoading extends MealStorageState {}

class MealStorageLoaded extends MealStorageState {
  final List<Meal> meals;
  final SortOption sortOption;
  final int totalCalories;

  MealStorageLoaded({
    required this.meals,
    required this.sortOption,
    required this.totalCalories,
  });
}

class MealStorageError extends MealStorageState {
  final String message;
  MealStorageError(this.message);
}
