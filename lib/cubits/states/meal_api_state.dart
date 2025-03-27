import '../../models/meal_api.dart';

abstract class MealApiState {}

class MealApiInitial extends MealApiState {}

class MealApiLoading extends MealApiState {}

class MealApiError extends MealApiState {
  final String message;
  MealApiError(this.message);
}

class MealSearchSuccess extends MealApiState {
  final List<MealApi> meals;
  MealSearchSuccess(this.meals);
}

class MealCategorySuccess extends MealApiState {
  final List<String> categories;
  MealCategorySuccess(this.categories);
}

class MealDetailSuccess extends MealApiState {
  final MealApi meal;
  MealDetailSuccess(this.meal);
}
