class MealApi {
  final String id;
  final String name;
  final String thumbnail;
  final String? category;
  final String? area;
  final String? instructions;
  final Map<String, String>? ingredients;

  MealApi({
    required this.id,
    required this.name,
    required this.thumbnail,
    this.category,
    this.area,
    this.instructions,
    this.ingredients,
  });

  factory MealApi.fromJson(Map<String, dynamic> json) {
    // Extract ingredients and measures
    Map<String, String> ingredients = {};
    for (int i = 1; i <= 20; i++) {
      String ingredient = json['strIngredient$i'] ?? '';
      String measure = json['strMeasure$i'] ?? '';
      if (ingredient.isNotEmpty) {
        ingredients[ingredient] = measure;
      }
    }

    return MealApi(
      id: json['idMeal'] ?? '',
      name: json['strMeal'] ?? '',
      thumbnail: json['strMealThumb'] ?? '',
      category: json['strCategory'],
      area: json['strArea'],
      instructions: json['strInstructions'],
      ingredients: ingredients,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idMeal': id,
      'strMeal': name,
      'strMealThumb': thumbnail,
      'strCategory': category,
      'strArea': area,
      'strInstructions': instructions,
    };
  }
}
