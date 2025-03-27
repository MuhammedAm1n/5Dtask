import 'package:dio/dio.dart';
import '../models/meal_api.dart';

class MealApiService {
  static const String baseUrl = 'https://www.themealdb.com/api/json/v1/1';
  final Dio _dio;

  MealApiService() : _dio = Dio(BaseOptions(baseUrl: baseUrl));

  Future<List<MealApi>> searchMeals(String query) async {
    try {
      final response =
          await _dio.get('/search.php', queryParameters: {'s': query});

      if (response.statusCode == 200) {
        final data = response.data;

        // Check if meals is null or empty
        if (data['meals'] == null || (data['meals'] as List).isEmpty) {
          return [];
        }

        // Parse the meals list
        final mealsList = data['meals'] as List;
        return mealsList.map((meal) => MealApi.fromJson(meal)).toList();
      } else {
        throw Exception('Failed to search meals: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Error searching meals: $e');
    }
  }

  Future<List<String>> getCategories() async {
    try {
      final response = await _dio.get('/categories.php');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['categories'] == null) return [];

        return (data['categories'] as List)
            .map((category) => category['strCategory'] as String)
            .toList();
      } else {
        throw Exception('Failed to load categories: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Error loading categories: $e');
    }
  }

  Future<List<MealApi>> filterByCategory(String category) async {
    try {
      final response =
          await _dio.get('/filter.php', queryParameters: {'c': category});

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['meals'] == null || (data['meals'] as List).isEmpty) {
          return [];
        }

        return (data['meals'] as List)
            .map((meal) => MealApi.fromJson(meal))
            .toList();
      } else {
        throw Exception('Failed to filter meals: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Error filtering meals: $e');
    }
  }

  Future<MealApi?> getMealDetails(String id) async {
    try {
      final response =
          await _dio.get('/lookup.php', queryParameters: {'i': id});

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['meals'] == null || (data['meals'] as List).isEmpty) {
          return null;
        }
        return MealApi.fromJson(data['meals'][0]);
      } else {
        throw Exception('Failed to get meal details: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Error getting meal details: $e');
    }
  }
}
