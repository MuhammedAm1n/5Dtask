import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/meal_api.dart';
import '../cubits/meal_api_cubit.dart';
import '../cubits/states/meal_api_state.dart';

class MealDetailScreen extends StatefulWidget {
  final MealApi meal;

  const MealDetailScreen({super.key, required this.meal});

  @override
  State<MealDetailScreen> createState() => _MealDetailScreenState();
}

class _MealDetailScreenState extends State<MealDetailScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch full meal details when screen is opened
    context.read<MealApiCubit>().getMealDetails(widget.meal.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.meal.name),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: BlocBuilder<MealApiCubit, MealApiState>(
        builder: (context, state) {
          if (state is MealApiLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is MealApiError) {
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
                    onPressed: () {
                      context
                          .read<MealApiCubit>()
                          .getMealDetails(widget.meal.id);
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          if (state is MealDetailSuccess) {
            final meal = state.meal;
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.network(
                    meal.thumbnail,
                    width: double.infinity,
                    height: 300,
                    fit: BoxFit.cover,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (meal.category != null) ...[
                          _buildInfoRow('Category', meal.category!),
                          const SizedBox(height: 8),
                        ],
                        if (meal.area != null) ...[
                          _buildInfoRow('Cuisine', meal.area!),
                          const SizedBox(height: 8),
                        ],
                        const SizedBox(height: 16),
                        Text(
                          'Ingredients',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        if (meal.ingredients != null) ...[
                          ...meal.ingredients!.entries.map(
                            (entry) => Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 4.0),
                              child: Row(
                                children: [
                                  const Icon(Icons.circle, size: 8),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      '${entry.key} - ${entry.value}',
                                      style:
                                          Theme.of(context).textTheme.bodyLarge,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),
                        Text(
                          'Instructions',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        if (meal.instructions != null)
                          Text(
                            meal.instructions!,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
          // Show initial meal data while loading
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.network(
                  widget.meal.thumbnail,
                  width: double.infinity,
                  height: 300,
                  fit: BoxFit.cover,
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (widget.meal.category != null) ...[
                        _buildInfoRow('Category', widget.meal.category!),
                        const SizedBox(height: 8),
                      ],
                      if (widget.meal.area != null) ...[
                        _buildInfoRow('Cuisine', widget.meal.area!),
                        const SizedBox(height: 8),
                      ],
                      const SizedBox(height: 16),
                      Text(
                        'Ingredients',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      if (widget.meal.ingredients != null) ...[
                        ...widget.meal.ingredients!.entries.map(
                          (entry) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Row(
                              children: [
                                const Icon(Icons.circle, size: 8),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    '${entry.key} - ${entry.value}',
                                    style:
                                        Theme.of(context).textTheme.bodyLarge,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      Text(
                        'Instructions',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      if (widget.meal.instructions != null)
                        Text(
                          widget.meal.instructions!,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(value),
      ],
    );
  }
}
