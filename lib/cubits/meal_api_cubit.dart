import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/meal_api_service.dart';
import 'states/meal_api_state.dart';

// Cubit
class MealApiCubit extends Cubit<MealApiState> {
  final MealApiService apiService;

  MealApiCubit(this.apiService) : super(MealApiInitial());

  Future<void> searchMeals(String query) async {
    if (query.isEmpty) {
      emit(MealApiInitial());
      return;
    }

    emit(MealApiLoading());
    try {
      final meals = await apiService.searchMeals(query);
      emit(MealSearchSuccess(meals));
    } catch (e) {
      emit(MealApiError('Failed to search meals: $e'));
    }
  }

  Future<void> loadCategories() async {
    emit(MealApiLoading());
    try {
      final categories = await apiService.getCategories();
      emit(MealCategorySuccess(categories));
    } catch (e) {
      emit(MealApiError('Failed to load categories: $e'));
    }
  }

  Future<void> filterByCategory(String category) async {
    emit(MealApiLoading());
    try {
      final meals = await apiService.filterByCategory(category);
      emit(MealSearchSuccess(meals));
    } catch (e) {
      emit(MealApiError('Failed to filter meals: $e'));
    }
  }
}
