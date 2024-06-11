import 'package:cloud_firestore/cloud_firestore.dart';

class Recipe {
  final String id;
  final String title;
  final String image;
  final Timestamp timestamp;
  final String description;
  final List<String> ingredients;
  final List<String> steps;
  final int numberOfPeople;
  final String cookingTime;
  final String cookingLevel;

  Recipe({
    required this.id,
    required this.title,
    required this.image,
    required this.timestamp,
    required this.description,
    required this.ingredients,
    required this.steps,
    required this.numberOfPeople,
    required this.cookingTime,
    required this.cookingLevel,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'title': title,
      'image': image,
      'timestamp': timestamp,
      'description': description,
      'ingredients': ingredients,
      'steps': steps,
      'numberOfPeople': numberOfPeople,
      'cookingTime': cookingTime,
      'cookingLevel': cookingLevel,
    };
  }

  Future<void> saveToFirestore() async {
    await FirebaseFirestore.instance.collection('recipes').doc(id).set(toFirestore());
  }

  factory Recipe.fromSnapshot(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Recipe(
      id: doc.id,
      title: data['title'] ?? '',
      image: data['image'],
      description: data['description'] ?? '',
      ingredients: List<String>.from(data['ingredients'] ?? []),
      steps: List<String>.from(data['steps'] ?? []),
      timestamp: data['timestamp'] ?? Timestamp.now(),
      numberOfPeople: data['numberOfPeople'] ?? 0,
      cookingTime: data['cookingTime'] ?? '',
      cookingLevel: data['cookingLevel'] ?? '',
    );
  }
}
