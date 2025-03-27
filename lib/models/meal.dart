
class Meal {
  final String id;
  final String name;
  final int calories;
  final DateTime time;
  final String? photoPath;

  Meal({
    required this.id,
    required this.name,
    required this.calories,
    required this.time,
    this.photoPath,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'calories': calories,
      'time': time.toIso8601String(),
      'photoPath': photoPath,
    };
  }

  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      id: json['id'],
      name: json['name'],
      calories: json['calories'],
      time: DateTime.parse(json['time']),
      photoPath: json['photoPath'],
    );
  }
}
