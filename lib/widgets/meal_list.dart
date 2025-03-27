import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/meal.dart';
import 'dart:io';

enum SortOption { name, calories, time }

class MealList extends StatelessWidget {
  final List<Meal> meals;
  final Function(String) onDelete;
  final SortOption sortOption;

  const MealList({
    super.key,
    required this.meals,
    required this.onDelete,
    required this.sortOption,
  });

  List<Meal> _getSortedMeals() {
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

  int _getTotalCalories() {
    return meals.fold(0, (sum, meal) => sum + meal.calories);
  }

  @override
  Widget build(BuildContext context) {
    final sortedMeals = _getSortedMeals();
    final totalCalories = _getTotalCalories();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Total Calories: $totalCalories',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: sortedMeals.length,
            itemBuilder: (context, index) {
              final meal = sortedMeals[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: meal.photoPath != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(meal.photoPath!),
                            width: 56,
                            height: 56,
                            fit: BoxFit.cover,
                          ),
                        )
                      : const Icon(Icons.restaurant),
                  title: Text(meal.name),
                  subtitle: Text(
                    '${meal.calories} calories • ${DateFormat('MMM d, y HH:mm').format(meal.time)}',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => onDelete(meal.id),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
