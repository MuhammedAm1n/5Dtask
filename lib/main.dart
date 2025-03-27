import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'screens/home_screen.dart';
import 'services/storage_service.dart';
import 'services/meal_api_service.dart';
import 'cubits/meal_storage_cubit.dart';
import 'cubits/meal_api_cubit.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storageService = StorageService();
  final apiService = MealApiService();

  runApp(MyApp(
    storageService: storageService,
    apiService: apiService,
  ));
}

class MyApp extends StatelessWidget {
  final StorageService storageService;
  final MealApiService apiService;

  const MyApp({
    super.key,
    required this.storageService,
    required this.apiService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => MealStorageCubit(storageService: storageService),
        ),
        BlocProvider(
          create: (context) => MealApiCubit(apiService),
        ),
      ],
      child: MaterialApp(
        title: 'Meal Tracker',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        home: const HomeScreen(),
      ),
    );
  }
}
