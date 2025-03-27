import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../widgets/add_meal_form.dart';
import '../widgets/meal_list.dart';
import '../screens/meal_search_screen.dart';
import '../cubits/meal_storage_cubit.dart';
import '../cubits/states/meal_storage_state.dart';

class HomeScreen extends StatelessWidget {

  const HomeScreen({super.key,});

  void _showAddMealDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Meal'),
        content: AddMealForm(
          onMealAdded: (meal) {
            context.read<MealStorageCubit>().addMeal(meal);
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  void _showSortOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: const Text('Sort by Name'),
            onTap: () {
              context
                  .read<MealStorageCubit>()
                  .updateSortOption(SortOption.name);
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text('Sort by Calories'),
            onTap: () {
              context
                  .read<MealStorageCubit>()
                  .updateSortOption(SortOption.calories);
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text('Sort by Time'),
            onTap: () {
              context
                  .read<MealStorageCubit>()
                  .updateSortOption(SortOption.time);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _navigateToSearch(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const MealSearchScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async => false, // Prevent back button from closing the app
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Meal Tracker'),
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () => _navigateToSearch(context),
            ),
            IconButton(
              icon: const Icon(Icons.sort),
              onPressed: () => _showSortOptions(context),
            ),
          ],
        ),
        body: BlocBuilder<MealStorageCubit, MealStorageState>(
          builder: (context, state) {
            if (state is MealStorageLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is MealStorageError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      state.message,
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () =>
                          context.read<MealStorageCubit>().loadMeals(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }
            if (state is MealStorageLoaded) {
              return MealList(
                meals: state.meals,
                onDelete: (id) =>
                    context.read<MealStorageCubit>().deleteMeal(id),
                sortOption: state.sortOption,
              );
            }
            return const SizedBox.shrink();
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showAddMealDialog(context),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
