import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubits/meal_api_cubit.dart';
import '../cubits/states/meal_api_state.dart';
import '../screens/meal_detail_screen.dart';
import 'dart:async';

class MealSearchScreen extends StatefulWidget {
  const MealSearchScreen({super.key});

  @override
  State<MealSearchScreen> createState() => _MealSearchScreenState();
}

class _MealSearchScreenState extends State<MealSearchScreen> {
  final _searchController = TextEditingController();
  String? _selectedCategory;
  Timer? _debounceTimer;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    // Load categories when screen is initialized
    context.read<MealApiCubit>().loadCategories();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _isSearching = query.isNotEmpty;
    });

    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (query.isEmpty) {
        setState(() {
          _selectedCategory = null;
        });
        context.read<MealApiCubit>().loadCategories();
      } else {
        context.read<MealApiCubit>().searchMeals(query);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Meals'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search meals...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _isSearching = false;
                            _selectedCategory = null;
                          });
                          context.read<MealApiCubit>().loadCategories();
                        },
                      )
                    : null,
              ),
              onChanged: _onSearchChanged,
            ),
          ),
          BlocBuilder<MealApiCubit, MealApiState>(
            builder: (context, state) {
              if (state is MealApiLoading) {
                return const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (state is MealApiError) {
                return Expanded(
                  child: Center(
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
                          onPressed: () {
                            if (_selectedCategory != null) {
                              context
                                  .read<MealApiCubit>()
                                  .filterByCategory(_selectedCategory!);
                            } else {
                              context
                                  .read<MealApiCubit>()
                                  .searchMeals(_searchController.text);
                            }
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                );
              }
              if (state is MealCategorySuccess && !_isSearching) {
                return SizedBox(
                  height: 50,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemCount: state.categories.length,
                    itemBuilder: (context, index) {
                      final category = state.categories[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: FilterChip(
                          label: Text(category),
                          selected: _selectedCategory == category,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedCategory = category;
                                _searchController.clear();
                                _isSearching = false;
                                context
                                    .read<MealApiCubit>()
                                    .filterByCategory(category);
                              } else {
                                _selectedCategory = null;
                                context.read<MealApiCubit>().loadCategories();
                              }
                            });
                          },
                        ),
                      );
                    },
                  ),
                );
              }
              if (state is MealSearchSuccess) {
                if (state.meals.isEmpty) {
                  return Expanded(
                    child: Center(
                      child: Text(
                        _searchController.text.isEmpty &&
                                _selectedCategory == null
                            ? 'Search for meals or select a category'
                            : 'No meals found',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  );
                }

                return Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(8),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: state.meals.length,
                    itemBuilder: (context, index) {
                      final meal = state.meals[index];
                      return Card(
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    MealDetailScreen(meal: meal),
                              ),
                            );
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Image.network(
                                  meal.thumbnail,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  meal.name,
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              }
              return const Expanded(
                child: Center(
                  child: Text('Search for meals or select a category'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
