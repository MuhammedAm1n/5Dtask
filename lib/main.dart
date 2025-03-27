import 'package:flutter/material.dart';
import 'models/meal.dart';
import 'services/storage_service.dart';
import 'widgets/add_meal_form.dart';
import 'widgets/meal_list.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storageService = StorageService();
  runApp(MyApp(storageService: storageService));
}

class MyApp extends StatelessWidget {
  final StorageService storageService;

  const MyApp({super.key, required this.storageService});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Meal Tracker',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: MyHomePage(storageService: storageService),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final StorageService storageService;

  const MyHomePage({super.key, required this.storageService});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Meal> _meals = [];
  SortOption _sortOption = SortOption.time;

  @override
  void initState() {
    super.initState();
    _loadMeals();
  }

  Future<void> _loadMeals() async {
    final meals = await widget.storageService.getMeals();
    setState(() {
      _meals = meals;
    });
  }

  Future<void> _addMeal(Meal meal) async {
    await widget.storageService.addMeal(meal);
    await _loadMeals();
  }

  Future<void> _deleteMeal(String id) async {
    await widget.storageService.deleteMeal(id);
    await _loadMeals();
  }

  void _showAddMealDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Meal'),
        content: AddMealForm(onMealAdded: _addMeal),
      ),
    );
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: const Text('Sort by Name'),
            onTap: () {
              setState(() => _sortOption = SortOption.name);
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text('Sort by Calories'),
            onTap: () {
              setState(() => _sortOption = SortOption.calories);
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text('Sort by Time'),
            onTap: () {
              setState(() => _sortOption = SortOption.time);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meal Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: _showSortOptions,
          ),
        ],
      ),
      body: MealList(
        meals: _meals,
        onDelete: _deleteMeal,
        sortOption: _sortOption,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddMealDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
